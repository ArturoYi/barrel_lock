import 'package:flutter/material.dart';

import '../domain/app_color_scheme.dart';

extension AppColorSchemeX on AppColorScheme {
  Color get seedColor => switch (this) {
    AppColorScheme.deepPurple => Colors.deepPurple,
    AppColorScheme.blue => Colors.blue,
    AppColorScheme.green => Colors.green,
    AppColorScheme.orange => Colors.orange,
    AppColorScheme.teal => Colors.teal,
  };

  String get displayName => switch (this) {
    AppColorScheme.deepPurple => '紫色',
    AppColorScheme.blue => '蓝色',
    AppColorScheme.green => '绿色',
    AppColorScheme.orange => '橙色',
    AppColorScheme.teal => '青色',
  };
}
