import 'package:app_fonts/app_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 应用级 M3 排版语义层，通过 [ThemeExtension] 注入 [ThemeData.extensions]。
///
/// ## 设计原则
///
/// 1. **不手抄数值**：几何（字号/字重/行高/字距/baseline）委托给 Flutter SDK
///    的 [Typography.material2021]，SDK 升级时自动对齐官方 M3 规范。
/// 2. **CJK 几何**：中文主字体 Noto Sans SC 使用 [ScriptCategory.dense]（`dense2021`），
///    含 [TextBaseline.ideographic] 与 [TextLeadingDistribution.even]。
/// 3. **颜色与几何分离**：token 仅含字号/字重/行高/字距/baseline，不含 `color`。
///    文字色由 [ColorScheme] 角色在消费侧决定（如 `onSurface`、`onPrimary`），
///    或由 Material 组件（Button、AppBar 等）通过 `DefaultTextStyle` 注入。
/// 4. **双通道消费**：业务层用 [AppTypographyX.typography]；Material 组件走
///    [ThemeData.textTheme]（[toTextTheme] 保持两者一致）。
///
/// ## 与 ThemeData 的对齐关系
///
/// Flutter 在 [ThemeData.new] 中会 merge 颜色层与几何层；本模块只取
/// [Typography.geometryThemeFor]（[ScriptCategory.dense]），等同
/// [ThemeData.localize] 对 CJK locale 的几何处理，再替换 [AppFonts.notoSansSC]。
/// 颜色层由 [ThemeData.colorScheme] 与各组件主题负责，不在排版 token 中 baked。
@immutable
final class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  /// 基于官方 M3 Typography 构建应用默认排版（仅几何，不含颜色）。
  ///
  /// [colorScheme] 保留供 [AppTheme] 调用对齐；几何层不依赖其颜色语义。
  /// [fontFamily] 默认 [AppFonts.notoSansSC]；
  /// [platform] 影响 [Typography.material2021] 的平台分支，几何数值不受影响。
  factory AppTypography.standard({
    required ColorScheme colorScheme,
    String fontFamily = AppFonts.notoSansSC,
    TargetPlatform? platform,
  }) {
    final textTheme = _buildM3TextTheme(
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      platform: platform,
    );
    return AppTypography.fromTextTheme(textTheme);
  }

  /// 从已合并的 [TextTheme] 提取 15 个 M3 token。
  ///
  /// 供 [standard] 与测试使用；若某 token 为 null 则触发 assert（M3 完整集不应缺失）。
  factory AppTypography.fromTextTheme(TextTheme textTheme) {
    return AppTypography(
      displayLarge: _requireToken(textTheme.displayLarge, 'displayLarge'),
      displayMedium: _requireToken(textTheme.displayMedium, 'displayMedium'),
      displaySmall: _requireToken(textTheme.displaySmall, 'displaySmall'),
      headlineLarge: _requireToken(textTheme.headlineLarge, 'headlineLarge'),
      headlineMedium: _requireToken(textTheme.headlineMedium, 'headlineMedium'),
      headlineSmall: _requireToken(textTheme.headlineSmall, 'headlineSmall'),
      titleLarge: _requireToken(textTheme.titleLarge, 'titleLarge'),
      titleMedium: _requireToken(textTheme.titleMedium, 'titleMedium'),
      titleSmall: _requireToken(textTheme.titleSmall, 'titleSmall'),
      bodyLarge: _requireToken(textTheme.bodyLarge, 'bodyLarge'),
      bodyMedium: _requireToken(textTheme.bodyMedium, 'bodyMedium'),
      bodySmall: _requireToken(textTheme.bodySmall, 'bodySmall'),
      labelLarge: _requireToken(textTheme.labelLarge, 'labelLarge'),
      labelMedium: _requireToken(textTheme.labelMedium, 'labelMedium'),
      labelSmall: _requireToken(textTheme.labelSmall, 'labelSmall'),
    );
  }

  /// 组装 M3 几何 [TextTheme]（不含颜色），逻辑镜像 [ThemeData.localize] CJK 分支。
  ///
  /// ```text
  /// Typography.material2021(platform)
  ///   → geometryThemeFor(ScriptCategory.dense)（CJK 几何层）
  ///   → .apply(fontFamily: NotoSansSC)（替换平台默认 Roboto）
  /// ```
  static TextTheme _buildM3TextTheme({
    required ColorScheme colorScheme,
    required String fontFamily,
    TargetPlatform? platform,
  }) {
    // colorScheme 参数保留以稳定 [standard] 签名；几何层不读取颜色语义。
    final typography = Typography.material2021(
      platform: platform ?? defaultTargetPlatform,
      colorScheme: colorScheme,
    );

    // CJK 几何（ScriptCategory.dense）：Noto Sans SC 为中日韩字体，应使用 dense2021：
    //   - textBaseline: TextBaseline.ideographic（表意文字基线）
    //   - leadingDistribution: TextLeadingDistribution.even（均匀行距）
    // 等价于 MaterialLocalizations.scriptCategory == ScriptCategory.dense
    // 时 ThemeData.localize 注入的 localTextGeometry。
    final geometryTheme = typography.geometryThemeFor(ScriptCategory.dense);

    return geometryTheme.apply(fontFamily: fontFamily);
  }

  /// M3 token 非空断言，避免 silent fallback 掩盖 SDK 变更。
  static TextStyle _requireToken(TextStyle? style, String tokenName) {
    assert(
      style != null,
      'AppTypography: M3 TextTheme.$tokenName is null. '
      'Check Typography.material2021 dense merge pipeline.',
    );
    return style!;
  }

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  /// 回写 [ThemeData.textTheme]，保证 Material 组件与业务层样式同源。
  TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }

  @override
  AppTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) {
    return AppTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }

  @override
  AppTypography lerp(AppTypography? other, double t) {
    if (other == null) {
      return this;
    }

    TextStyle? lerpStyle(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t);

    return AppTypography(
      displayLarge: lerpStyle(displayLarge, other.displayLarge)!,
      displayMedium: lerpStyle(displayMedium, other.displayMedium)!,
      displaySmall: lerpStyle(displaySmall, other.displaySmall)!,
      headlineLarge: lerpStyle(headlineLarge, other.headlineLarge)!,
      headlineMedium: lerpStyle(headlineMedium, other.headlineMedium)!,
      headlineSmall: lerpStyle(headlineSmall, other.headlineSmall)!,
      titleLarge: lerpStyle(titleLarge, other.titleLarge)!,
      titleMedium: lerpStyle(titleMedium, other.titleMedium)!,
      titleSmall: lerpStyle(titleSmall, other.titleSmall)!,
      bodyLarge: lerpStyle(bodyLarge, other.bodyLarge)!,
      bodyMedium: lerpStyle(bodyMedium, other.bodyMedium)!,
      bodySmall: lerpStyle(bodySmall, other.bodySmall)!,
      labelLarge: lerpStyle(labelLarge, other.labelLarge)!,
      labelMedium: lerpStyle(labelMedium, other.labelMedium)!,
      labelSmall: lerpStyle(labelSmall, other.labelSmall)!,
    );
  }
}
