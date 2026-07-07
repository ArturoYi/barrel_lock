import 'identity_auth_method.dart';

/// 身份验证结果。
final class IdentityAuthResult {
  const IdentityAuthResult._({required this.status, this.method, this.message});

  /// 验证成功。
  factory IdentityAuthResult.success({required IdentityAuthMethod method}) {
    return IdentityAuthResult._(
      status: IdentityAuthStatus.success,
      method: method,
    );
  }

  /// 用户主动取消（生物识别弹窗或 PIN 输入页）。
  factory IdentityAuthResult.cancelled({String? message}) {
    return IdentityAuthResult._(
      status: IdentityAuthStatus.cancelled,
      message: message,
    );
  }

  /// 验证失败（如 PIN 错误、生物识别未通过）。
  factory IdentityAuthResult.failure({String? message}) {
    return IdentityAuthResult._(
      status: IdentityAuthStatus.failure,
      message: message,
    );
  }

  /// 当前环境无法验证（无生物识别且未设置应用内密码）。
  factory IdentityAuthResult.unavailable({String? message}) {
    return IdentityAuthResult._(
      status: IdentityAuthStatus.unavailable,
      message: message,
    );
  }

  final IdentityAuthStatus status;
  final IdentityAuthMethod? method;
  final String? message;

  bool get isSuccess => status == IdentityAuthStatus.success;

  bool get isCancelled => status == IdentityAuthStatus.cancelled;

  bool get isFailure => status == IdentityAuthStatus.failure;

  bool get isUnavailable => status == IdentityAuthStatus.unavailable;
}

enum IdentityAuthStatus { success, cancelled, failure, unavailable }
