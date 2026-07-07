#include <flutter_linux/flutter_linux.h>
#include <gtest/gtest.h>

#include "include/fast_lifecycle/fast_lifecycle_plugin.h"

namespace fast_lifecycle {
namespace test {

TEST(FastLifecyclePlugin, PluginGTypeIsRegistered) {
  EXPECT_NE(fast_lifecycle_plugin_get_type(), static_cast<GType>(0));
}

}  // namespace test
}  // namespace fast_lifecycle
