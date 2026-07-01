/// SP 全局配置（架构常量层）
final class PreferenceConfig {
  PreferenceConfig._();

  /// 环境前缀，区分 dev/test/prod，防止多环境数据混淆
  static String envPrefix = '';

  /// 初始化环境前缀
  static void initEnvPrefix(String env) {
    envPrefix = env.isEmpty ? '' : '${env}_';
  }

  /// 拼接带环境隔离的真实 key
  static String getRealKey(String rawKey) => '$envPrefix$rawKey';
}
