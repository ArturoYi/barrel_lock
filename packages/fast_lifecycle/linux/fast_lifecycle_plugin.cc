#include "include/fast_lifecycle/fast_lifecycle_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <cstring>
#include <string>

#include "fast_lifecycle_plugin_private.h"

#define FAST_LIFECYCLE_PLUGIN(obj)                                         \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), fast_lifecycle_plugin_get_type(), \
                              FastLifecyclePlugin))

/// Linux EventChannel 流状态：GTK 信号与 FlEventChannel 同生共死。
typedef struct {
  FlEventChannel* channel;
  GtkWidget* widget;
  gulong focus_in_id;
  gulong focus_out_id;
  gulong window_state_id;
  gulong delete_id;
  gchar* window_id;
  gboolean is_main_window;
} FastLifecycleListenState;

struct _FastLifecyclePlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FastLifecycleListenState* listen_state;
};

G_DEFINE_TYPE(FastLifecyclePlugin, fast_lifecycle_plugin, g_object_get_type())

static void fast_lifecycle_plugin_dispose(GObject* object) {
  FastLifecyclePlugin* plugin = FAST_LIFECYCLE_PLUGIN(object);
  if (plugin->listen_state != nullptr) {
    g_free(plugin->listen_state->window_id);
    g_free(plugin->listen_state);
    plugin->listen_state = nullptr;
  }
  G_OBJECT_CLASS(fast_lifecycle_plugin_parent_class)->dispose(object);
}

static void fast_lifecycle_plugin_class_init(FastLifecyclePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = fast_lifecycle_plugin_dispose;
}

static void fast_lifecycle_plugin_init(FastLifecyclePlugin* self) {
  self->listen_state = nullptr;
}

static FlValue* build_lifecycle_payload(const char* raw_state,
                                        const char* lifecycle_scope,
                                        const char* window_id,
                                        gboolean is_main_window) {
  g_autoptr(FlValue) extra = fl_value_new_map();
  fl_value_set_string_take(extra, "lifecycleScope",
                           fl_value_new_string(lifecycle_scope));
  if (window_id != nullptr) {
    fl_value_set_string_take(extra, "windowId",
                             fl_value_new_string(window_id));
  }
  fl_value_set_string(extra, "isMainWindow",
                      fl_value_new_bool(is_main_window));

  g_autoptr(FlValue) payload = fl_value_new_map();
  fl_value_set_string_take(payload, "source",
                           fl_value_new_string("linux"));
  fl_value_set_string_take(payload, "rawState",
                           fl_value_new_string(raw_state));
  fl_value_set_string(payload, "extra", extra);
  return fl_value_ref(payload);
}

static void emit_lifecycle_event(FastLifecycleListenState* state,
                                 const char* raw_state) {
  if (state == nullptr || state->channel == nullptr) {
    return;
  }
  g_autoptr(FlValue) payload =
      build_lifecycle_payload(raw_state, "window", state->window_id,
                              state->is_main_window);
  fl_event_channel_send(state->channel, payload, nullptr);
}

static gboolean on_focus_in(GtkWidget* /*widget*/, GdkEventFocus* /*event*/,
                            gpointer user_data) {
  emit_lifecycle_event(static_cast<FastLifecycleListenState*>(user_data),
                       "window_focus");
  return FALSE;
}

static gboolean on_focus_out(GtkWidget* /*widget*/, GdkEventFocus* /*event*/,
                             gpointer user_data) {
  emit_lifecycle_event(static_cast<FastLifecycleListenState*>(user_data),
                       "window_blur");
  return FALSE;
}

static gboolean on_window_state_event(GtkWidget* /*widget*/,
                                      GdkEventWindowState* event,
                                      gpointer user_data) {
  if (event->changed_mask & GDK_WINDOW_STATE_ICONIFIED) {
    if (event->new_window_state & GDK_WINDOW_STATE_ICONIFIED) {
      emit_lifecycle_event(static_cast<FastLifecycleListenState*>(user_data),
                           "window_minimize");
    } else {
      emit_lifecycle_event(static_cast<FastLifecycleListenState*>(user_data),
                           "window_restore");
    }
  }
  return FALSE;
}

static gboolean on_delete_event(GtkWidget* /*widget*/, GdkEvent* /*event*/,
                                gpointer user_data) {
  emit_lifecycle_event(static_cast<FastLifecycleListenState*>(user_data),
                       "window_close");
  return FALSE;
}

static void stop_gtk_listening(FastLifecycleListenState* state) {
  if (state == nullptr || state->widget == nullptr) {
    return;
  }

  if (state->focus_in_id != 0) {
    g_signal_handler_disconnect(state->widget, state->focus_in_id);
    state->focus_in_id = 0;
  }
  if (state->focus_out_id != 0) {
    g_signal_handler_disconnect(state->widget, state->focus_out_id);
    state->focus_out_id = 0;
  }
  if (state->window_state_id != 0) {
    g_signal_handler_disconnect(state->widget, state->window_state_id);
    state->window_state_id = 0;
  }
  if (state->delete_id != 0) {
    g_signal_handler_disconnect(state->widget, state->delete_id);
    state->delete_id = 0;
  }
}

static void parse_listen_arguments(FlValue* args, FastLifecycleListenState* state) {
  if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return;
  }

  FlValue* window_id_value = fl_value_lookup_string(args, "windowId");
  if (window_id_value != nullptr &&
      fl_value_get_type(window_id_value) == FL_VALUE_TYPE_STRING) {
    g_free(state->window_id);
    state->window_id = g_strdup(fl_value_get_string(window_id_value));
  }

  FlValue* is_main_value = fl_value_lookup_string(args, "isMainWindow");
  if (is_main_value != nullptr &&
      fl_value_get_type(is_main_value) == FL_VALUE_TYPE_BOOL) {
    state->is_main_window = fl_value_get_bool(is_main_value);
  }
}

static FlMethodErrorResponse* on_listen_cb(FlEventChannel* channel,
                                             FlValue* args,
                                             gpointer user_data) {
  FastLifecyclePlugin* plugin = FAST_LIFECYCLE_PLUGIN(user_data);

  if (plugin->listen_state != nullptr) {
    stop_gtk_listening(plugin->listen_state);
    g_free(plugin->listen_state->window_id);
    g_free(plugin->listen_state);
  }

  plugin->listen_state = g_new0(FastLifecycleListenState, 1);
  plugin->listen_state->channel = channel;
  plugin->listen_state->is_main_window = TRUE;
  parse_listen_arguments(args, plugin->listen_state);

  FlView* view = fl_plugin_registrar_get_view(plugin->registrar);
  if (view == nullptr) {
    return fl_method_error_response_new("NO_VIEW",
                                        "FlView is not available.", nullptr);
  }

  GtkWidget* widget = GTK_WIDGET(view);
  plugin->listen_state->widget = widget;

  plugin->listen_state->focus_in_id =
      g_signal_connect(widget, "focus-in-event", G_CALLBACK(on_focus_in),
                       plugin->listen_state);
  plugin->listen_state->focus_out_id =
      g_signal_connect(widget, "focus-out-event", G_CALLBACK(on_focus_out),
                       plugin->listen_state);
  plugin->listen_state->window_state_id = g_signal_connect(
      widget, "window-state-event", G_CALLBACK(on_window_state_event),
      plugin->listen_state);
  plugin->listen_state->delete_id =
      g_signal_connect(widget, "delete-event", G_CALLBACK(on_delete_event),
                       plugin->listen_state);

  return nullptr;
}

static FlMethodErrorResponse* on_cancel_cb(FlEventChannel* /*channel*/,
                                           FlValue* /*args*/,
                                           gpointer user_data) {
  FastLifecyclePlugin* plugin = FAST_LIFECYCLE_PLUGIN(user_data);
  if (plugin->listen_state != nullptr) {
    stop_gtk_listening(plugin->listen_state);
    g_free(plugin->listen_state->window_id);
    g_free(plugin->listen_state);
    plugin->listen_state = nullptr;
  }
  return nullptr;
}

void fast_lifecycle_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FastLifecyclePlugin* plugin = FAST_LIFECYCLE_PLUGIN(
      g_object_new(fast_lifecycle_plugin_get_type(), nullptr));
  plugin->registrar = registrar;

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlEventChannel) channel = fl_event_channel_new(
      fl_plugin_registrar_get_messenger(registrar),
      "fast_lifecycle/events",
      FL_METHOD_CODEC(codec));

  fl_event_channel_set_stream_handlers(channel, on_listen_cb, on_cancel_cb,
                                       g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
