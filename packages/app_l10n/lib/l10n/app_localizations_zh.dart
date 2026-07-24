// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get common_cancel => '取消';

  @override
  String get common_save => '保存';

  @override
  String get common_confirm => '确认';

  @override
  String get common_error => '出错了';

  @override
  String get common_back => '返回';

  @override
  String get common_delete => '删除';

  @override
  String get common_edit => '编辑';

  @override
  String get common_loading => '加载中…';

  @override
  String get common_retry => '重试';

  @override
  String get common_done => '完成';

  @override
  String get common_create => '创建';

  @override
  String get common_add => '添加';

  @override
  String get common_show => '显示';

  @override
  String get common_hide => '隐藏';

  @override
  String get common_showPassword => '显示密码';

  @override
  String get common_hidePassword => '隐藏密码';

  @override
  String get common_copy => '复制';

  @override
  String get common_favorite => '收藏';

  @override
  String get common_unfavorite => '取消收藏';

  @override
  String get common_notSet => '未设置';

  @override
  String get common_set => '已设置';

  @override
  String get common_ungrouped => '未分组';

  @override
  String get common_other => '其他';

  @override
  String get common_unnamedVault => '未命名保险库';

  @override
  String get common_loadingFolders => '加载文件夹…';

  @override
  String get common_newFolderEllipsis => '新建文件夹…';

  @override
  String common_loadFailed(String error) {
    return '加载失败：$error';
  }

  @override
  String get overlay_loading => '加载中…';

  @override
  String get overlay_success => '操作成功';

  @override
  String get overlay_error => '操作失败';

  @override
  String get overlay_please_wait => '请稍候';

  @override
  String get locale_follow_system => '跟随系统';

  @override
  String get settings_language => '语言';

  @override
  String get settings_language_follow_system => '跟随系统语言';

  @override
  String get settings_language_summary_system => '跟随系统';

  @override
  String get settings_language_summary_zh_hans => '简体中文';

  @override
  String get settings_language_summary_zh_hant => '繁體中文';

  @override
  String get settings_language_summary_en => 'English';

  @override
  String get settings_language_summary_ar => 'العربية';

  @override
  String get settings_title => '设置';

  @override
  String get settings_section_data => '数据';

  @override
  String get settings_section_security => '安全';

  @override
  String get settings_section_support => '服务支持';

  @override
  String get settings_section_appearance => '外观';

  @override
  String get settings_section_about => '关于';

  @override
  String get settings_dataMigration => '数据迁移';

  @override
  String get settings_dataMigrationSubtitle => '导出、导入、蓝牙共享、备份恢复';

  @override
  String get settings_appLock => '锁屏保护';

  @override
  String get settings_appLockSubtitle => '后台生物验证与备用密码';

  @override
  String get settings_clearData => '清除所有内容';

  @override
  String get settings_clearDataSubtitle => '删除全部密码，不可恢复';

  @override
  String get settings_helpDoc => '安全帮助文档';

  @override
  String get settings_feedback => '客服反馈';

  @override
  String get settings_userAgreement => '用户协议';

  @override
  String get settings_privacyPolicy => '隐私政策';

  @override
  String get settings_encryptionDoc => '加密说明';

  @override
  String get settings_themeDisplay => '主题与显示';

  @override
  String get settings_themeDisplaySubtitle => '深色模式、主题色、字体大小';

  @override
  String get settings_versionInfo => '版本信息';

  @override
  String get settings_themeMode => '主题模式';

  @override
  String get settings_themeFollowSystem => '跟随系统';

  @override
  String get settings_themeLight => '浅色';

  @override
  String get settings_themeDark => '深色';

  @override
  String get settings_accentColor => '主题色';

  @override
  String get settings_fontSize => '字体大小';

  @override
  String get settings_fontScale_small => '小';

  @override
  String get settings_fontScale_standard => '标准';

  @override
  String get settings_fontScale_large => '大';

  @override
  String get settings_fontScale_extraLarge => '特大';

  @override
  String get settings_colorScheme_deepPurple => '紫色';

  @override
  String get settings_colorScheme_blue => '蓝色';

  @override
  String get settings_colorScheme_green => '绿色';

  @override
  String get settings_colorScheme_orange => '橙色';

  @override
  String get settings_colorScheme_teal => '青色';

  @override
  String settings_sectionItemCount(int count) {
    return '$count 项';
  }

  @override
  String get settings_sectionHint_theme => '调整应用外观与可读性。';

  @override
  String get settings_sectionHint_data => '导入导出与备份相关操作将在此展开。';

  @override
  String get settings_sectionHint_security => '锁屏保护与危险操作需二次确认。';

  @override
  String get settings_sectionHint_support => '帮助文档与法律条款外链入口。';

  @override
  String get settings_sectionHint_about => '应用版本与构建信息。';

  @override
  String get settings_clearData_stepIdle => '此操作将永久删除所有密码，且无法恢复。';

  @override
  String get settings_clearData_stepConfirm1 => '请再次确认：确定要清除所有内容吗？';

  @override
  String get settings_clearData_stepConfirm2 => '最后一次确认：删除后无法撤销。';

  @override
  String get settings_clearData_stepClearing => '正在清除…';

  @override
  String get settings_clearData_stepDone => '所有密码已清除。';

  @override
  String get settings_clearData_start => '开始清除';

  @override
  String get settings_clearData_understandRisk => '我了解风险，继续';

  @override
  String get settings_clearData_confirmDelete => '确认永久删除';

  @override
  String get tab_password => '密码';

  @override
  String get tab_settings => '设置';

  @override
  String get tab_filterAll => '全部';

  @override
  String get tab_filterFavorites => '收藏';

  @override
  String get tab_filterRecent => '最近使用';

  @override
  String get tab_searchHint => '搜索密码、网站、用户名';

  @override
  String get tab_switchVault => '切换保险库';

  @override
  String get tab_newVault => '新建保险库';

  @override
  String get tab_createVault => '创建保险库';

  @override
  String get tab_createVaultHint => '例如：工作、家庭';

  @override
  String get tab_vaultNameLabel => '保险库名称';

  @override
  String get tab_newFolder => '新建文件夹';

  @override
  String get tab_folderNameLabel => '文件夹名称';

  @override
  String get tab_folderNameHint => '例如：社交、银行卡';

  @override
  String get tab_emptyNoVaultTitle => '暂无保险库';

  @override
  String get tab_emptyNoVaultSubtitle => '创建保险库以开始管理密码';

  @override
  String get tab_emptyNoItemsTitle => '暂无密码条目';

  @override
  String get tab_addPassword => '添加密码';

  @override
  String get tab_nameRequired => '请输入名称';

  @override
  String get error_page_not_found => '404 — 页面未找到';

  @override
  String get cipher_addTitle => '添加密码';

  @override
  String get cipher_addedToast => '已添加';

  @override
  String get cipher_saveFailed => '保存失败，请稍后重试';

  @override
  String get cipher_typeWebsiteLogin => '网站登录';

  @override
  String get cipher_typeBankCard => '银行卡';

  @override
  String get cipher_typeIdentityDocument => '身份证件';

  @override
  String get cipher_typeSecureNote => '安全笔记';

  @override
  String get cipher_typeAppAccount => 'App 账户密码';

  @override
  String get cipher_typeSshKey => 'SSH 密钥';

  @override
  String cipher_formComingSoon(String type) {
    return '$type表单即将推出';
  }

  @override
  String get cipher_defaultVaultName => '我的保险库';

  @override
  String get cipher_field_name => '名称';

  @override
  String get cipher_field_username => '用户名';

  @override
  String get cipher_field_password => '密码';

  @override
  String get cipher_field_website => '网站';

  @override
  String get cipher_field_notes => '备注';

  @override
  String get cipher_field_folder => '文件夹';

  @override
  String get cipher_field_cardholder => '持卡人';

  @override
  String get cipher_field_cardNumber => '卡号';

  @override
  String get cipher_field_expMonth => '月 MM';

  @override
  String get cipher_field_expYear => '年 YY';

  @override
  String get cipher_field_cardPinOptional => 'PIN（可选）';

  @override
  String get cipher_field_docType => '证件类型';

  @override
  String get cipher_field_fullName => '姓名';

  @override
  String get cipher_field_docNumber => '证件号码';

  @override
  String get cipher_field_issueDate => '签发日期';

  @override
  String get cipher_field_expiryDate => '有效期';

  @override
  String get cipher_field_title => '标题';

  @override
  String get cipher_field_content => '内容';

  @override
  String get cipher_field_privateKey => '私钥';

  @override
  String get cipher_field_publicKeyOptional => '公钥（可选）';

  @override
  String get cipher_field_passphraseOptional => '口令（可选）';

  @override
  String get cipher_field_host => '主机';

  @override
  String get cipher_field_account => '账号';

  @override
  String get cipher_field_bundleIdOptional => '包名 / Bundle ID（可选）';

  @override
  String get cipher_descWebsiteLogin => '保存第三方网站或服务的登录凭据，与 App 解锁密码无关。';

  @override
  String get cipher_descBankCard => '保存银行卡信息；列表仅展示卡号后四位。';

  @override
  String get cipher_descIdentityDocument => '保存身份证、护照等证件信息；列表仅展示证件类型与姓名摘要。';

  @override
  String get cipher_descSecureNote => '保存加密笔记内容；列表展示标题摘要。';

  @override
  String get cipher_descSshKey => '保存 SSH 私钥与连接信息；列表展示主机与用户摘要。';

  @override
  String get cipher_descAppAccount => '保存本地 App 的登录账号与密码，与 App 解锁密码无关。';

  @override
  String get cipher_validationWebsiteLogin => '请填写名称、用户名和密码';

  @override
  String get cipher_validationBankCard => '请填写名称、持卡人、卡号、有效期和 CVV';

  @override
  String get cipher_validationIdentityDocument => '请填写名称、证件类型、姓名和证件号码';

  @override
  String get cipher_validationSecureNote => '请填写标题和笔记内容';

  @override
  String get cipher_validationSshKey => '请填写名称和私钥';

  @override
  String get cipher_validationAppAccount => '请填写名称、账号和密码';

  @override
  String get cipher_validationRequired => '请完善必填项';

  @override
  String get cipher_attachmentOptional => '附件（可选）';

  @override
  String get cipher_attachmentHint => '可添加身份证正反面等照片';

  @override
  String get cipher_attachmentTakePhoto => '拍照';

  @override
  String get cipher_attachmentFromGallery => '从相册选择';

  @override
  String get app_lock_title => '应用保护';

  @override
  String get app_lock_enableTitle => '启用应用保护';

  @override
  String get app_lock_enableSubtitle => '冷启动与回到前台时需要验证身份';

  @override
  String get app_lock_manageFallbackPin => '管理备用密码';

  @override
  String get app_lock_fallbackPinTitle => '备用密码';

  @override
  String get app_lock_enabledToast => '应用保护已开启';

  @override
  String get app_lock_setupPinTitle => '设置备用密码';

  @override
  String get app_lock_setupHintTitle => '设置提示语';

  @override
  String app_lock_enterPinDigits(int length) {
    return '请输入 $length 位数字密码';
  }

  @override
  String get app_lock_pinLabel => '密码';

  @override
  String get app_lock_hintDescription => '设置一句提示语，忘记密码时可帮助你回忆备用密码。';

  @override
  String get app_lock_hintLabel => '忘记密码提示语';

  @override
  String get app_lock_confirmEnable => '确认开启';

  @override
  String get app_lock_previousStep => '上一步';

  @override
  String get app_lock_enableFailed => '开启失败，请重试';

  @override
  String get app_lock_invalidPinFormat => '密码格式无效';

  @override
  String app_lock_error_enterPinDigits(int length) {
    return '请输入 $length 位数字密码';
  }

  @override
  String get app_lock_error_pinMismatch => '两次输入不一致';

  @override
  String get app_lock_error_enterHint => '请输入提示语';

  @override
  String app_lock_error_hintTooLong(int max) {
    return '提示语不能超过 $max 个字符';
  }

  @override
  String get app_lock_error_sameAsCurrent => '新密码不能与当前密码相同';

  @override
  String get app_lock_error_enterCurrentPin => '请输入当前密码';

  @override
  String get app_lock_error_wrongCurrentPin => '当前密码错误';

  @override
  String get app_lock_authenticating => '正在验证身份…';

  @override
  String get app_lock_error_wrongPinRetry => '密码错误，请重试';

  @override
  String get app_lock_error_wrongAppPinRetry => '应用内密码错误，请重试';

  @override
  String get app_lock_error_authUnavailable => '当前无法验证身份，请重试';

  @override
  String get app_lock_error_enterPin => '请输入密码';

  @override
  String get app_lock_biometricUnavailable => '生物识别不可用，请输入密码';

  @override
  String get app_lock_biometricFailed => '生物识别未通过，请输入密码';

  @override
  String get app_lock_inAppPinLabel => '应用内密码';

  @override
  String get app_lock_semantic_biometric => '生物识别';

  @override
  String get app_lock_semantic_delete => '删除';

  @override
  String get app_lock_cannotClearPinReason => '锁屏保护已开启且无其他解锁方式，请先关闭锁屏保护或启用生物识别';

  @override
  String get app_lock_reason_unlockOnResume => '请验证身份以继续';

  @override
  String get app_lock_reason_confirmSensitive => '请验证身份以继续操作';

  @override
  String get app_lock_reason_setupAppPin => '请验证身份以设置应用密码';

  @override
  String get migration_title => '数据迁移';

  @override
  String get migration_intro => '在设备间安全迁移密码数据。导出文件均经加密处理。';

  @override
  String get migration_exportFile => '导出到文件';

  @override
  String get migration_exportFileSubtitle => '加密打包后保存到本地';

  @override
  String get migration_importFile => '从文件导入';

  @override
  String get migration_importFileSubtitle => '合并或覆盖现有数据';

  @override
  String get migration_bluetoothShare => '蓝牙共享';

  @override
  String get migration_bluetoothShareSubtitle => '同系统附近连接或跨平台 BLE 传输';

  @override
  String get migration_localBackup => '本地备份';

  @override
  String get migration_localBackupSubtitle => '在应用内保留一份快照';

  @override
  String get migration_restoreBackup => '恢复备份';

  @override
  String get migration_restoreBackupSubtitle => '从最近备份还原';

  @override
  String get migration_toastRestoreDone => '恢复完成';

  @override
  String get migration_toastRestoreFailed => '恢复失败';

  @override
  String get migration_toastImportDone => '导入完成';

  @override
  String get migration_toastImportFailed => '导入失败';

  @override
  String get migration_toastBackupCreated => '本地备份已创建';

  @override
  String get migration_toastBackupFailed => '备份失败';

  @override
  String get migration_toastNoLocalBackup => '暂无本地备份';

  @override
  String get migration_toastExportDone => '已导出备份';

  @override
  String get migration_toastExportFailed => '导出失败';

  @override
  String get migration_restoreTitle => '恢复备份';

  @override
  String get migration_localBackupDefaultNote => '本地备份';

  @override
  String get migration_modeMerge => '合并';

  @override
  String get migration_modeReplace => '覆盖';

  @override
  String get migration_replaceWarning => '覆盖将删除当前全部密码数据，且不可撤销。';

  @override
  String get migration_startRestore => '开始恢复';

  @override
  String get migration_importModeTitle => '选择导入方式';

  @override
  String get migration_importModeDescription => '合并会保留本地独有条目；覆盖会用备份替换全部密码数据。';

  @override
  String get migration_importMerge => '合并导入';

  @override
  String get migration_importReplace => '覆盖导入';

  @override
  String get migration_importReplaceDanger => '覆盖导入（危险）';

  @override
  String get migration_importModeHint => '合并会保留本机已有数据；覆盖会先清空再导入，请谨慎选择。';

  @override
  String get migration_btSheetTitle => '蓝牙共享';

  @override
  String get migration_btSheetDescription =>
      '传输完整加密备份。同系统使用附近连接；跨系统（iOS↔Android）使用 BLE，请保持两台设备在前台。';

  @override
  String get migration_btSameOsTitle => '同系统附近连接';

  @override
  String get migration_btSameOsSubtitle => 'Android↔Android 或 iOS↔iOS';

  @override
  String get migration_btSameOsSend => '同系统 · 发送';

  @override
  String get migration_btSameOsReceive => '同系统 · 接收';

  @override
  String get migration_btCrossPlatformTitle => '跨平台 BLE';

  @override
  String get migration_btCrossPlatformSubtitle => 'iOS 与 Android 互传；大备份可能需数分钟';

  @override
  String get migration_btCrossPlatformSend => '跨平台 · 发送';

  @override
  String get migration_btCrossPlatformReceive => '跨平台 · 接收';

  @override
  String get migration_btCrossPlatformSendTitle => '跨平台发送';

  @override
  String get migration_btCrossPlatformReceiveTitle => '跨平台接收';

  @override
  String get migration_btNearbySendTitle => '发送到附近设备';

  @override
  String get migration_btNearbyReceiveTitle => '从附近设备接收';

  @override
  String migration_btConnectingPeer(String name) {
    return '正在连接 $name…';
  }

  @override
  String migration_btConnectionFailed(String error) {
    return '连接失败：$error';
  }

  @override
  String get migration_btCancelled => '已取消';

  @override
  String migration_btTransferFailed(String error) {
    return '传输失败：$error';
  }

  @override
  String migration_btTransferProgress(int percent) {
    return '传输进度 $percent%';
  }

  @override
  String migration_btTransferringBle(int percent) {
    return '正在通过 BLE 传输加密备份… $percent%';
  }

  @override
  String migration_btTransferring(int percent) {
    return '正在传输加密备份… $percent%';
  }

  @override
  String get migration_btScanningCrossPlatformReceiver => '正在扫描跨平台接收端…';

  @override
  String get migration_btWaitingCrossPlatformSender => '等待跨平台发送端连接…';

  @override
  String get migration_btSearchingNearby => '正在搜索附近设备…';

  @override
  String get migration_btWaitingSender => '等待发送端连接…';

  @override
  String get migration_btConnecting => '正在连接…';

  @override
  String get migration_btCompleted => '传输完成';

  @override
  String get migration_btSendDoneCrossPlatform => '备份已发送到跨平台设备';

  @override
  String get migration_btSendDoneNearby => '备份已发送到附近设备';

  @override
  String get migration_btSendDoneToast => '发送完成';

  @override
  String get migration_btReceivedChooseImport => '已收到备份，请选择导入方式';

  @override
  String migration_btRemainingTime(String time) {
    return '剩余连接时间 $time';
  }

  @override
  String get migration_btInstructionCrossPlatformReceive =>
      '请在对端选择「跨平台 · 接收」并保持前台';

  @override
  String get migration_btInstructionCrossPlatformSend =>
      '请在对端选择「跨平台 · 发送」并保持前台';

  @override
  String get migration_btInstructionSameOsReceive => '请在对端选择「同系统 · 接收」';

  @override
  String get migration_btInstructionSameOsSend => '请在对端选择「同系统 · 发送」';

  @override
  String get migration_btUnknownDevice => '未知设备';

  @override
  String get support_feedbackTitle => '客服反馈';

  @override
  String support_feedbackIntro(String email) {
    return '请描述你遇到的问题或建议。点击「发送邮件反馈」将打开系统邮件应用，收件人已预设为 $email，请确认内容后点击发送。';
  }

  @override
  String get support_contactEmailOptional => '联系邮箱（选填）';

  @override
  String get support_feedbackContent => '反馈内容';

  @override
  String get support_sendFeedbackEmail => '发送邮件反馈';

  @override
  String get support_toastMailOpened => '已打开邮件应用，请确认收件人后发送';

  @override
  String get support_toastMailUnavailableCopied => '无法打开邮件应用，已复制反馈内容';

  @override
  String get support_emailSubject => 'BarrelLock 用户反馈';

  @override
  String get support_docNotFoundTitle => '内容不存在';

  @override
  String get support_docNotFoundBody => '该文档暂未提供，请返回后重试。';

  @override
  String get support_entryNotSupported => '暂不支持该入口';

  @override
  String get support_docSecurityHelp => '安全帮助文档';

  @override
  String get support_docEncryption => '加密说明';

  @override
  String get support_docTerms => '用户协议';

  @override
  String get support_docPrivacy => '隐私政策';

  @override
  String get settings_section_general => '通用';

  @override
  String get settings_sectionHint_general => '语言与区域偏好。';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get common_cancel => '取消';

  @override
  String get common_save => '儲存';

  @override
  String get common_confirm => '確認';

  @override
  String get common_error => '出錯了';

  @override
  String get common_back => '返回';

  @override
  String get common_delete => '刪除';

  @override
  String get common_edit => '編輯';

  @override
  String get common_loading => '載入中…';

  @override
  String get common_retry => '重试';

  @override
  String get common_done => '完成';

  @override
  String get common_create => '建立';

  @override
  String get common_add => '新增';

  @override
  String get common_show => '顯示';

  @override
  String get common_hide => '隱藏';

  @override
  String get common_showPassword => '顯示密碼';

  @override
  String get common_hidePassword => '隱藏密碼';

  @override
  String get common_copy => '複製';

  @override
  String get common_favorite => '收藏';

  @override
  String get common_unfavorite => '取消收藏';

  @override
  String get common_notSet => '未設定';

  @override
  String get common_set => '已設定';

  @override
  String get common_ungrouped => '未分組';

  @override
  String get common_other => '其他';

  @override
  String get common_unnamedVault => '未命名保險庫';

  @override
  String get common_loadingFolders => '載入資料夾…';

  @override
  String get common_newFolderEllipsis => '新建資料夾…';

  @override
  String common_loadFailed(String error) {
    return '載入失敗：$error';
  }

  @override
  String get overlay_loading => '載入中…';

  @override
  String get overlay_success => '操作成功';

  @override
  String get overlay_error => '操作失敗';

  @override
  String get overlay_please_wait => '請稍候';

  @override
  String get locale_follow_system => '跟隨系統';

  @override
  String get settings_language => '語言';

  @override
  String get settings_language_follow_system => '跟隨系統語言';

  @override
  String get settings_language_summary_system => '跟隨系統';

  @override
  String get settings_language_summary_zh_hans => '简体中文';

  @override
  String get settings_language_summary_zh_hant => '繁體中文';

  @override
  String get settings_language_summary_en => 'English';

  @override
  String get settings_language_summary_ar => 'العربية';

  @override
  String get settings_title => '設定';

  @override
  String get settings_section_data => '資料';

  @override
  String get settings_section_security => '安全';

  @override
  String get settings_section_support => '服務支援';

  @override
  String get settings_section_appearance => '外觀';

  @override
  String get settings_section_about => '关于';

  @override
  String get settings_dataMigration => '資料遷移';

  @override
  String get settings_dataMigrationSubtitle => '匯出、匯入、藍牙共享、備份恢復';

  @override
  String get settings_appLock => '鎖屏保護';

  @override
  String get settings_appLockSubtitle => '后台生物驗證與备用密碼';

  @override
  String get settings_clearData => '清除所有內容';

  @override
  String get settings_clearDataSubtitle => '刪除全部密碼，不可恢復';

  @override
  String get settings_helpDoc => '安全說明文件';

  @override
  String get settings_feedback => '客服回饋';

  @override
  String get settings_userAgreement => '用户協議';

  @override
  String get settings_privacyPolicy => '隱私政策';

  @override
  String get settings_encryptionDoc => '加密說明';

  @override
  String get settings_themeDisplay => '主題與顯示';

  @override
  String get settings_themeDisplaySubtitle => '深色模式、主題色、字體大小';

  @override
  String get settings_versionInfo => '版本資訊';

  @override
  String get settings_themeMode => '主題模式';

  @override
  String get settings_themeFollowSystem => '跟隨系統';

  @override
  String get settings_themeLight => '淺色';

  @override
  String get settings_themeDark => '深色';

  @override
  String get settings_accentColor => '主題色';

  @override
  String get settings_fontSize => '字體大小';

  @override
  String get settings_fontScale_small => '小';

  @override
  String get settings_fontScale_standard => '標準';

  @override
  String get settings_fontScale_large => '大';

  @override
  String get settings_fontScale_extraLarge => '特大';

  @override
  String get settings_colorScheme_deepPurple => '紫色';

  @override
  String get settings_colorScheme_blue => '藍色';

  @override
  String get settings_colorScheme_green => '綠色';

  @override
  String get settings_colorScheme_orange => '橙色';

  @override
  String get settings_colorScheme_teal => '青色';

  @override
  String settings_sectionItemCount(int count) {
    return '$count 项';
  }

  @override
  String get settings_sectionHint_theme => '调整應用外觀與可读性。';

  @override
  String get settings_sectionHint_data => '匯入匯出與備份相关操作将在此展开。';

  @override
  String get settings_sectionHint_security => '鎖屏保護與危险操作需二次確認。';

  @override
  String get settings_sectionHint_support => '說明文件與法律条款外链入口。';

  @override
  String get settings_sectionHint_about => '應用版本與构建資訊。';

  @override
  String get settings_clearData_stepIdle => '此操作将永久刪除所有密碼，且無法恢復。';

  @override
  String get settings_clearData_stepConfirm1 => '請再次確認：确定要清除所有內容吗？';

  @override
  String get settings_clearData_stepConfirm2 => '最后一次確認：刪除后無法撤销。';

  @override
  String get settings_clearData_stepClearing => '正在清除…';

  @override
  String get settings_clearData_stepDone => '所有密碼已清除。';

  @override
  String get settings_clearData_start => '开始清除';

  @override
  String get settings_clearData_understandRisk => '我了解風險，繼續';

  @override
  String get settings_clearData_confirmDelete => '確認永久刪除';

  @override
  String get tab_password => '密碼';

  @override
  String get tab_settings => '設定';

  @override
  String get tab_filterAll => '全部';

  @override
  String get tab_filterFavorites => '收藏';

  @override
  String get tab_filterRecent => '最近使用';

  @override
  String get tab_searchHint => '搜尋密碼、網站、使用者名稱';

  @override
  String get tab_switchVault => '切換保險庫';

  @override
  String get tab_newVault => '新建保險庫';

  @override
  String get tab_createVault => '建立保險庫';

  @override
  String get tab_createVaultHint => '例如：工作、家庭';

  @override
  String get tab_vaultNameLabel => '保險庫名稱';

  @override
  String get tab_newFolder => '新建資料夾';

  @override
  String get tab_folderNameLabel => '資料夾名稱';

  @override
  String get tab_folderNameHint => '例如：社交、銀行卡';

  @override
  String get tab_emptyNoVaultTitle => '暫無保險庫';

  @override
  String get tab_emptyNoVaultSubtitle => '建立保險庫以开始管理密碼';

  @override
  String get tab_emptyNoItemsTitle => '暫無密碼項目';

  @override
  String get tab_addPassword => '新增密碼';

  @override
  String get tab_nameRequired => '請输入名稱';

  @override
  String get error_page_not_found => '404 — 頁面未找到';

  @override
  String get cipher_addTitle => '新增密碼';

  @override
  String get cipher_addedToast => '已新增';

  @override
  String get cipher_saveFailed => '儲存失敗，請稍後重试';

  @override
  String get cipher_typeWebsiteLogin => '網站登入';

  @override
  String get cipher_typeBankCard => '銀行卡';

  @override
  String get cipher_typeIdentityDocument => '身分證件';

  @override
  String get cipher_typeSecureNote => '安全筆記';

  @override
  String get cipher_typeAppAccount => 'App 帳戶密碼';

  @override
  String get cipher_typeSshKey => 'SSH 密钥';

  @override
  String cipher_formComingSoon(String type) {
    return '$type表單即將推出';
  }

  @override
  String get cipher_defaultVaultName => '我的保險庫';

  @override
  String get cipher_field_name => '名稱';

  @override
  String get cipher_field_username => '使用者名稱';

  @override
  String get cipher_field_password => '密碼';

  @override
  String get cipher_field_website => '網站';

  @override
  String get cipher_field_notes => '備註';

  @override
  String get cipher_field_folder => '資料夾';

  @override
  String get cipher_field_cardholder => '持卡人';

  @override
  String get cipher_field_cardNumber => '卡号';

  @override
  String get cipher_field_expMonth => '月 MM';

  @override
  String get cipher_field_expYear => '年 YY';

  @override
  String get cipher_field_cardPinOptional => 'PIN（可選）';

  @override
  String get cipher_field_docType => '證件類型';

  @override
  String get cipher_field_fullName => '姓名';

  @override
  String get cipher_field_docNumber => '證件號碼';

  @override
  String get cipher_field_issueDate => '簽發日期';

  @override
  String get cipher_field_expiryDate => '有效期';

  @override
  String get cipher_field_title => '標題';

  @override
  String get cipher_field_content => '內容';

  @override
  String get cipher_field_privateKey => '私鑰';

  @override
  String get cipher_field_publicKeyOptional => '公鑰（可選）';

  @override
  String get cipher_field_passphraseOptional => '口令（可選）';

  @override
  String get cipher_field_host => '主機';

  @override
  String get cipher_field_account => '帳號';

  @override
  String get cipher_field_bundleIdOptional => '套件名 / Bundle ID（可選）';

  @override
  String get cipher_descWebsiteLogin => '儲存第三方網站或服务的登入憑證，與 App 解鎖密碼無關。';

  @override
  String get cipher_descBankCard => '儲存銀行卡資訊；清單仅展示卡号後四位。';

  @override
  String get cipher_descIdentityDocument => '儲存身分证、護照等證件資訊；清單仅展示證件類型與姓名摘要。';

  @override
  String get cipher_descSecureNote => '儲存加密筆記內容；清單展示標題摘要。';

  @override
  String get cipher_descSshKey => '儲存 SSH 私鑰與連線資訊；清單展示主機與用户摘要。';

  @override
  String get cipher_descAppAccount => '儲存本機 App 的登入帳號與密碼，與 App 解鎖密碼無關。';

  @override
  String get cipher_validationWebsiteLogin => '請填寫名稱、使用者名稱和密碼';

  @override
  String get cipher_validationBankCard => '請填寫名稱、持卡人、卡号、有效期和 CVV';

  @override
  String get cipher_validationIdentityDocument => '請填寫名稱、證件類型、姓名和證件號碼';

  @override
  String get cipher_validationSecureNote => '請填寫標題和筆記內容';

  @override
  String get cipher_validationSshKey => '請填寫名稱和私鑰';

  @override
  String get cipher_validationAppAccount => '請填寫名稱、帳號和密碼';

  @override
  String get cipher_validationRequired => '請完善必填项';

  @override
  String get cipher_attachmentOptional => '附件（可選）';

  @override
  String get cipher_attachmentHint => '可新增身分证正反面等照片';

  @override
  String get cipher_attachmentTakePhoto => '拍照';

  @override
  String get cipher_attachmentFromGallery => '从相簿選擇';

  @override
  String get app_lock_title => '應用保護';

  @override
  String get app_lock_enableTitle => '启用應用保護';

  @override
  String get app_lock_enableSubtitle => '冷启动與回到前台时需要驗證身分';

  @override
  String get app_lock_manageFallbackPin => '管理备用密碼';

  @override
  String get app_lock_fallbackPinTitle => '备用密碼';

  @override
  String get app_lock_enabledToast => '應用保護已開啟';

  @override
  String get app_lock_setupPinTitle => '設定备用密碼';

  @override
  String get app_lock_setupHintTitle => '設定提示語';

  @override
  String app_lock_enterPinDigits(int length) {
    return '請输入 $length 位数字密碼';
  }

  @override
  String get app_lock_pinLabel => '密碼';

  @override
  String get app_lock_hintDescription => '設定一句提示語，忘记密碼时可說明你回忆备用密碼。';

  @override
  String get app_lock_hintLabel => '忘记密碼提示語';

  @override
  String get app_lock_confirmEnable => '確認開啟';

  @override
  String get app_lock_previousStep => '上一步';

  @override
  String get app_lock_enableFailed => '開啟失敗，請重试';

  @override
  String get app_lock_invalidPinFormat => '密碼格式无效';

  @override
  String app_lock_error_enterPinDigits(int length) {
    return '請输入 $length 位数字密碼';
  }

  @override
  String get app_lock_error_pinMismatch => '两次输入不一致';

  @override
  String get app_lock_error_enterHint => '請输入提示語';

  @override
  String app_lock_error_hintTooLong(int max) {
    return '提示語不能超过 $max 个字符';
  }

  @override
  String get app_lock_error_sameAsCurrent => '新密碼不能與当前密碼相同';

  @override
  String get app_lock_error_enterCurrentPin => '請输入当前密碼';

  @override
  String get app_lock_error_wrongCurrentPin => '当前密碼错误';

  @override
  String get app_lock_authenticating => '正在驗證身分…';

  @override
  String get app_lock_error_wrongPinRetry => '密碼错误，請重试';

  @override
  String get app_lock_error_wrongAppPinRetry => '應用内密碼错误，請重试';

  @override
  String get app_lock_error_authUnavailable => '当前無法驗證身分，請重试';

  @override
  String get app_lock_error_enterPin => '請输入密碼';

  @override
  String get app_lock_biometricUnavailable => '生物辨識不可用，請输入密碼';

  @override
  String get app_lock_biometricFailed => '生物辨識未通过，請输入密碼';

  @override
  String get app_lock_inAppPinLabel => '應用内密碼';

  @override
  String get app_lock_semantic_biometric => '生物辨識';

  @override
  String get app_lock_semantic_delete => '刪除';

  @override
  String get app_lock_cannotClearPinReason => '鎖屏保護已開啟且无其他解鎖方式，請先关闭鎖屏保護或启用生物辨識';

  @override
  String get app_lock_reason_unlockOnResume => '請驗證身分以繼續';

  @override
  String get app_lock_reason_confirmSensitive => '請驗證身分以繼續操作';

  @override
  String get app_lock_reason_setupAppPin => '請驗證身分以設定應用密碼';

  @override
  String get migration_title => '資料遷移';

  @override
  String get migration_intro => '在裝置间安全遷移密碼資料。匯出文件均经加密处理。';

  @override
  String get migration_exportFile => '匯出到文件';

  @override
  String get migration_exportFileSubtitle => '加密打包后儲存到本機';

  @override
  String get migration_importFile => '从文件匯入';

  @override
  String get migration_importFileSubtitle => '合併或覆寫现有資料';

  @override
  String get migration_bluetoothShare => '藍牙共享';

  @override
  String get migration_bluetoothShareSubtitle => '同系統附近連線或跨平台 BLE 傳輸';

  @override
  String get migration_localBackup => '本機備份';

  @override
  String get migration_localBackupSubtitle => '在應用内保留一份快照';

  @override
  String get migration_restoreBackup => '恢復備份';

  @override
  String get migration_restoreBackupSubtitle => '从最近備份还原';

  @override
  String get migration_toastRestoreDone => '恢復完成';

  @override
  String get migration_toastRestoreFailed => '恢復失敗';

  @override
  String get migration_toastImportDone => '匯入完成';

  @override
  String get migration_toastImportFailed => '匯入失敗';

  @override
  String get migration_toastBackupCreated => '本機備份已建立';

  @override
  String get migration_toastBackupFailed => '備份失敗';

  @override
  String get migration_toastNoLocalBackup => '暫無本機備份';

  @override
  String get migration_toastExportDone => '已匯出備份';

  @override
  String get migration_toastExportFailed => '匯出失敗';

  @override
  String get migration_restoreTitle => '恢復備份';

  @override
  String get migration_localBackupDefaultNote => '本機備份';

  @override
  String get migration_modeMerge => '合併';

  @override
  String get migration_modeReplace => '覆寫';

  @override
  String get migration_replaceWarning => '覆寫将刪除当前全部密碼資料，且不可撤销。';

  @override
  String get migration_startRestore => '开始恢復';

  @override
  String get migration_importModeTitle => '選擇匯入方式';

  @override
  String get migration_importModeDescription => '合併会保留本機独有項目；覆寫会用備份替换全部密碼資料。';

  @override
  String get migration_importMerge => '合併匯入';

  @override
  String get migration_importReplace => '覆寫匯入';

  @override
  String get migration_importReplaceDanger => '覆寫匯入（危险）';

  @override
  String get migration_importModeHint => '合併会保留本機已有資料；覆寫会先清空再匯入，請謹慎選擇。';

  @override
  String get migration_btSheetTitle => '藍牙共享';

  @override
  String get migration_btSheetDescription =>
      '傳輸完整加密備份。同系統使用附近連線；跨系统（iOS↔Android）使用 BLE，請保持两台裝置在前台。';

  @override
  String get migration_btSameOsTitle => '同系統附近連線';

  @override
  String get migration_btSameOsSubtitle => 'Android↔Android 或 iOS↔iOS';

  @override
  String get migration_btSameOsSend => '同系統 · 傳送';

  @override
  String get migration_btSameOsReceive => '同系統 · 接收';

  @override
  String get migration_btCrossPlatformTitle => '跨平台 BLE';

  @override
  String get migration_btCrossPlatformSubtitle => 'iOS 與 Android 互传；大備份可能需数分钟';

  @override
  String get migration_btCrossPlatformSend => '跨平台 · 傳送';

  @override
  String get migration_btCrossPlatformReceive => '跨平台 · 接收';

  @override
  String get migration_btCrossPlatformSendTitle => '跨平台傳送';

  @override
  String get migration_btCrossPlatformReceiveTitle => '跨平台接收';

  @override
  String get migration_btNearbySendTitle => '傳送到附近裝置';

  @override
  String get migration_btNearbyReceiveTitle => '从附近裝置接收';

  @override
  String migration_btConnectingPeer(String name) {
    return '正在連線 $name…';
  }

  @override
  String migration_btConnectionFailed(String error) {
    return '連線失敗：$error';
  }

  @override
  String get migration_btCancelled => '已取消';

  @override
  String migration_btTransferFailed(String error) {
    return '傳輸失敗：$error';
  }

  @override
  String migration_btTransferProgress(int percent) {
    return '傳輸進度 $percent%';
  }

  @override
  String migration_btTransferringBle(int percent) {
    return '正在通过 BLE 傳輸加密備份… $percent%';
  }

  @override
  String migration_btTransferring(int percent) {
    return '正在傳輸加密備份… $percent%';
  }

  @override
  String get migration_btScanningCrossPlatformReceiver => '正在掃描跨平台接收端…';

  @override
  String get migration_btWaitingCrossPlatformSender => '等待跨平台傳送端連線…';

  @override
  String get migration_btSearchingNearby => '正在搜尋附近裝置…';

  @override
  String get migration_btWaitingSender => '等待傳送端連線…';

  @override
  String get migration_btConnecting => '正在連線…';

  @override
  String get migration_btCompleted => '傳輸完成';

  @override
  String get migration_btSendDoneCrossPlatform => '備份已傳送到跨平台裝置';

  @override
  String get migration_btSendDoneNearby => '備份已傳送到附近裝置';

  @override
  String get migration_btSendDoneToast => '傳送完成';

  @override
  String get migration_btReceivedChooseImport => '已收到備份，請選擇匯入方式';

  @override
  String migration_btRemainingTime(String time) {
    return '剩餘連線时间 $time';
  }

  @override
  String get migration_btInstructionCrossPlatformReceive =>
      '請在對端選擇「跨平台 · 接收」并保持前台';

  @override
  String get migration_btInstructionCrossPlatformSend =>
      '請在對端選擇「跨平台 · 傳送」并保持前台';

  @override
  String get migration_btInstructionSameOsReceive => '請在對端選擇「同系統 · 接收」';

  @override
  String get migration_btInstructionSameOsSend => '請在對端選擇「同系統 · 傳送」';

  @override
  String get migration_btUnknownDevice => '未知裝置';

  @override
  String get support_feedbackTitle => '客服回饋';

  @override
  String support_feedbackIntro(String email) {
    return '請描述你遇到的问题或建议。点击「傳送邮件回饋」将開啟系统邮件應用，收件人已預設为 $email，請確認內容后点击傳送。';
  }

  @override
  String get support_contactEmailOptional => '聯絡電子郵件（选填）';

  @override
  String get support_feedbackContent => '回饋內容';

  @override
  String get support_sendFeedbackEmail => '傳送邮件回饋';

  @override
  String get support_toastMailOpened => '已開啟邮件應用，請確認收件人后傳送';

  @override
  String get support_toastMailUnavailableCopied => '無法開啟邮件應用，已複製回饋內容';

  @override
  String get support_emailSubject => 'BarrelLock 用户回饋';

  @override
  String get support_docNotFoundTitle => '內容不存在';

  @override
  String get support_docNotFoundBody => '该文件暂未提供，請返回后重试。';

  @override
  String get support_entryNotSupported => '暂不支援該入口';

  @override
  String get support_docSecurityHelp => '安全說明文件';

  @override
  String get support_docEncryption => '加密說明';

  @override
  String get support_docTerms => '用户協議';

  @override
  String get support_docPrivacy => '隱私政策';

  @override
  String get settings_section_general => '通用';

  @override
  String get settings_sectionHint_general => '語言與區域偏好。';
}
