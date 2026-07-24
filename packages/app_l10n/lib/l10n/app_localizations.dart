import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @common_cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get common_save;

  /// No description provided for @common_confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get common_confirm;

  /// No description provided for @common_error.
  ///
  /// In zh, this message translates to:
  /// **'出错了'**
  String get common_error;

  /// No description provided for @common_back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get common_back;

  /// No description provided for @common_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get common_edit;

  /// No description provided for @common_loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get common_loading;

  /// No description provided for @common_retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get common_retry;

  /// No description provided for @common_done.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get common_done;

  /// No description provided for @common_create.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get common_create;

  /// No description provided for @common_add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get common_add;

  /// No description provided for @common_show.
  ///
  /// In zh, this message translates to:
  /// **'显示'**
  String get common_show;

  /// No description provided for @common_hide.
  ///
  /// In zh, this message translates to:
  /// **'隐藏'**
  String get common_hide;

  /// No description provided for @common_showPassword.
  ///
  /// In zh, this message translates to:
  /// **'显示密码'**
  String get common_showPassword;

  /// No description provided for @common_hidePassword.
  ///
  /// In zh, this message translates to:
  /// **'隐藏密码'**
  String get common_hidePassword;

  /// No description provided for @common_copy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get common_copy;

  /// No description provided for @common_favorite.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get common_favorite;

  /// No description provided for @common_unfavorite.
  ///
  /// In zh, this message translates to:
  /// **'取消收藏'**
  String get common_unfavorite;

  /// No description provided for @common_notSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get common_notSet;

  /// No description provided for @common_set.
  ///
  /// In zh, this message translates to:
  /// **'已设置'**
  String get common_set;

  /// No description provided for @common_ungrouped.
  ///
  /// In zh, this message translates to:
  /// **'未分组'**
  String get common_ungrouped;

  /// No description provided for @common_other.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get common_other;

  /// No description provided for @common_unnamedVault.
  ///
  /// In zh, this message translates to:
  /// **'未命名保险库'**
  String get common_unnamedVault;

  /// No description provided for @common_loadingFolders.
  ///
  /// In zh, this message translates to:
  /// **'加载文件夹…'**
  String get common_loadingFolders;

  /// No description provided for @common_newFolderEllipsis.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹…'**
  String get common_newFolderEllipsis;

  /// No description provided for @common_loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败：{error}'**
  String common_loadFailed(String error);

  /// No description provided for @overlay_loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get overlay_loading;

  /// No description provided for @overlay_success.
  ///
  /// In zh, this message translates to:
  /// **'操作成功'**
  String get overlay_success;

  /// No description provided for @overlay_error.
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get overlay_error;

  /// No description provided for @overlay_please_wait.
  ///
  /// In zh, this message translates to:
  /// **'请稍候'**
  String get overlay_please_wait;

  /// No description provided for @locale_follow_system.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get locale_follow_system;

  /// No description provided for @settings_language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settings_language;

  /// No description provided for @settings_language_follow_system.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统语言'**
  String get settings_language_follow_system;

  /// No description provided for @settings_language_summary_system.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settings_language_summary_system;

  /// No description provided for @settings_language_summary_zh_hans.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get settings_language_summary_zh_hans;

  /// No description provided for @settings_language_summary_zh_hant.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get settings_language_summary_zh_hant;

  /// No description provided for @settings_language_summary_en.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get settings_language_summary_en;

  /// No description provided for @settings_language_summary_ar.
  ///
  /// In zh, this message translates to:
  /// **'العربية'**
  String get settings_language_summary_ar;

  /// No description provided for @settings_title.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings_title;

  /// No description provided for @settings_section_data.
  ///
  /// In zh, this message translates to:
  /// **'数据'**
  String get settings_section_data;

  /// No description provided for @settings_section_security.
  ///
  /// In zh, this message translates to:
  /// **'安全'**
  String get settings_section_security;

  /// No description provided for @settings_section_support.
  ///
  /// In zh, this message translates to:
  /// **'服务支持'**
  String get settings_section_support;

  /// No description provided for @settings_section_appearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get settings_section_appearance;

  /// No description provided for @settings_section_about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settings_section_about;

  /// No description provided for @settings_dataMigration.
  ///
  /// In zh, this message translates to:
  /// **'数据迁移'**
  String get settings_dataMigration;

  /// No description provided for @settings_dataMigrationSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'导出、导入、蓝牙共享、备份恢复'**
  String get settings_dataMigrationSubtitle;

  /// No description provided for @settings_appLock.
  ///
  /// In zh, this message translates to:
  /// **'锁屏保护'**
  String get settings_appLock;

  /// No description provided for @settings_appLockSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'后台生物验证与备用密码'**
  String get settings_appLockSubtitle;

  /// No description provided for @settings_clearData.
  ///
  /// In zh, this message translates to:
  /// **'清除所有内容'**
  String get settings_clearData;

  /// No description provided for @settings_clearDataSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'删除全部密码，不可恢复'**
  String get settings_clearDataSubtitle;

  /// No description provided for @settings_helpDoc.
  ///
  /// In zh, this message translates to:
  /// **'安全帮助文档'**
  String get settings_helpDoc;

  /// No description provided for @settings_feedback.
  ///
  /// In zh, this message translates to:
  /// **'客服反馈'**
  String get settings_feedback;

  /// No description provided for @settings_userAgreement.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get settings_userAgreement;

  /// No description provided for @settings_privacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get settings_privacyPolicy;

  /// No description provided for @settings_encryptionDoc.
  ///
  /// In zh, this message translates to:
  /// **'加密说明'**
  String get settings_encryptionDoc;

  /// No description provided for @settings_themeDisplay.
  ///
  /// In zh, this message translates to:
  /// **'主题与显示'**
  String get settings_themeDisplay;

  /// No description provided for @settings_themeDisplaySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'深色模式、主题色、字体大小'**
  String get settings_themeDisplaySubtitle;

  /// No description provided for @settings_versionInfo.
  ///
  /// In zh, this message translates to:
  /// **'版本信息'**
  String get settings_versionInfo;

  /// No description provided for @settings_themeMode.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get settings_themeMode;

  /// No description provided for @settings_themeFollowSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settings_themeFollowSystem;

  /// No description provided for @settings_themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get settings_themeLight;

  /// No description provided for @settings_themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get settings_themeDark;

  /// No description provided for @settings_accentColor.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get settings_accentColor;

  /// No description provided for @settings_fontSize.
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get settings_fontSize;

  /// No description provided for @settings_fontScale_small.
  ///
  /// In zh, this message translates to:
  /// **'小'**
  String get settings_fontScale_small;

  /// No description provided for @settings_fontScale_standard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get settings_fontScale_standard;

  /// No description provided for @settings_fontScale_large.
  ///
  /// In zh, this message translates to:
  /// **'大'**
  String get settings_fontScale_large;

  /// No description provided for @settings_fontScale_extraLarge.
  ///
  /// In zh, this message translates to:
  /// **'特大'**
  String get settings_fontScale_extraLarge;

  /// No description provided for @settings_colorScheme_deepPurple.
  ///
  /// In zh, this message translates to:
  /// **'紫色'**
  String get settings_colorScheme_deepPurple;

  /// No description provided for @settings_colorScheme_blue.
  ///
  /// In zh, this message translates to:
  /// **'蓝色'**
  String get settings_colorScheme_blue;

  /// No description provided for @settings_colorScheme_green.
  ///
  /// In zh, this message translates to:
  /// **'绿色'**
  String get settings_colorScheme_green;

  /// No description provided for @settings_colorScheme_orange.
  ///
  /// In zh, this message translates to:
  /// **'橙色'**
  String get settings_colorScheme_orange;

  /// No description provided for @settings_colorScheme_teal.
  ///
  /// In zh, this message translates to:
  /// **'青色'**
  String get settings_colorScheme_teal;

  /// No description provided for @settings_sectionItemCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 项'**
  String settings_sectionItemCount(int count);

  /// No description provided for @settings_sectionHint_theme.
  ///
  /// In zh, this message translates to:
  /// **'调整应用外观与可读性。'**
  String get settings_sectionHint_theme;

  /// No description provided for @settings_sectionHint_data.
  ///
  /// In zh, this message translates to:
  /// **'导入导出与备份相关操作将在此展开。'**
  String get settings_sectionHint_data;

  /// No description provided for @settings_sectionHint_security.
  ///
  /// In zh, this message translates to:
  /// **'锁屏保护与危险操作需二次确认。'**
  String get settings_sectionHint_security;

  /// No description provided for @settings_sectionHint_support.
  ///
  /// In zh, this message translates to:
  /// **'帮助文档与法律条款外链入口。'**
  String get settings_sectionHint_support;

  /// No description provided for @settings_sectionHint_about.
  ///
  /// In zh, this message translates to:
  /// **'应用版本与构建信息。'**
  String get settings_sectionHint_about;

  /// No description provided for @settings_clearData_stepIdle.
  ///
  /// In zh, this message translates to:
  /// **'此操作将永久删除所有密码，且无法恢复。'**
  String get settings_clearData_stepIdle;

  /// No description provided for @settings_clearData_stepConfirm1.
  ///
  /// In zh, this message translates to:
  /// **'请再次确认：确定要清除所有内容吗？'**
  String get settings_clearData_stepConfirm1;

  /// No description provided for @settings_clearData_stepConfirm2.
  ///
  /// In zh, this message translates to:
  /// **'最后一次确认：删除后无法撤销。'**
  String get settings_clearData_stepConfirm2;

  /// No description provided for @settings_clearData_stepClearing.
  ///
  /// In zh, this message translates to:
  /// **'正在清除…'**
  String get settings_clearData_stepClearing;

  /// No description provided for @settings_clearData_stepDone.
  ///
  /// In zh, this message translates to:
  /// **'所有密码已清除。'**
  String get settings_clearData_stepDone;

  /// No description provided for @settings_clearData_start.
  ///
  /// In zh, this message translates to:
  /// **'开始清除'**
  String get settings_clearData_start;

  /// No description provided for @settings_clearData_understandRisk.
  ///
  /// In zh, this message translates to:
  /// **'我了解风险，继续'**
  String get settings_clearData_understandRisk;

  /// No description provided for @settings_clearData_confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认永久删除'**
  String get settings_clearData_confirmDelete;

  /// No description provided for @tab_password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get tab_password;

  /// No description provided for @tab_settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get tab_settings;

  /// No description provided for @tab_filterAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get tab_filterAll;

  /// No description provided for @tab_filterFavorites.
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get tab_filterFavorites;

  /// No description provided for @tab_filterRecent.
  ///
  /// In zh, this message translates to:
  /// **'最近使用'**
  String get tab_filterRecent;

  /// No description provided for @tab_searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索密码、网站、用户名'**
  String get tab_searchHint;

  /// No description provided for @tab_switchVault.
  ///
  /// In zh, this message translates to:
  /// **'切换保险库'**
  String get tab_switchVault;

  /// No description provided for @tab_newVault.
  ///
  /// In zh, this message translates to:
  /// **'新建保险库'**
  String get tab_newVault;

  /// No description provided for @tab_createVault.
  ///
  /// In zh, this message translates to:
  /// **'创建保险库'**
  String get tab_createVault;

  /// No description provided for @tab_createVaultHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：工作、家庭'**
  String get tab_createVaultHint;

  /// No description provided for @tab_vaultNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'保险库名称'**
  String get tab_vaultNameLabel;

  /// No description provided for @tab_newFolder.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get tab_newFolder;

  /// No description provided for @tab_folderNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'文件夹名称'**
  String get tab_folderNameLabel;

  /// No description provided for @tab_folderNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：社交、银行卡'**
  String get tab_folderNameHint;

  /// No description provided for @tab_emptyNoVaultTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无保险库'**
  String get tab_emptyNoVaultTitle;

  /// No description provided for @tab_emptyNoVaultSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'创建保险库以开始管理密码'**
  String get tab_emptyNoVaultSubtitle;

  /// No description provided for @tab_emptyNoItemsTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无密码条目'**
  String get tab_emptyNoItemsTitle;

  /// No description provided for @tab_addPassword.
  ///
  /// In zh, this message translates to:
  /// **'添加密码'**
  String get tab_addPassword;

  /// No description provided for @tab_nameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入名称'**
  String get tab_nameRequired;

  /// No description provided for @error_page_not_found.
  ///
  /// In zh, this message translates to:
  /// **'404 — 页面未找到'**
  String get error_page_not_found;

  /// No description provided for @cipher_addTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加密码'**
  String get cipher_addTitle;

  /// No description provided for @cipher_addedToast.
  ///
  /// In zh, this message translates to:
  /// **'已添加'**
  String get cipher_addedToast;

  /// No description provided for @cipher_saveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，请稍后重试'**
  String get cipher_saveFailed;

  /// No description provided for @cipher_typeWebsiteLogin.
  ///
  /// In zh, this message translates to:
  /// **'网站登录'**
  String get cipher_typeWebsiteLogin;

  /// No description provided for @cipher_typeBankCard.
  ///
  /// In zh, this message translates to:
  /// **'银行卡'**
  String get cipher_typeBankCard;

  /// No description provided for @cipher_typeIdentityDocument.
  ///
  /// In zh, this message translates to:
  /// **'身份证件'**
  String get cipher_typeIdentityDocument;

  /// No description provided for @cipher_typeSecureNote.
  ///
  /// In zh, this message translates to:
  /// **'安全笔记'**
  String get cipher_typeSecureNote;

  /// No description provided for @cipher_typeAppAccount.
  ///
  /// In zh, this message translates to:
  /// **'App 账户密码'**
  String get cipher_typeAppAccount;

  /// No description provided for @cipher_typeSshKey.
  ///
  /// In zh, this message translates to:
  /// **'SSH 密钥'**
  String get cipher_typeSshKey;

  /// No description provided for @cipher_formComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'{type}表单即将推出'**
  String cipher_formComingSoon(String type);

  /// No description provided for @cipher_defaultVaultName.
  ///
  /// In zh, this message translates to:
  /// **'我的保险库'**
  String get cipher_defaultVaultName;

  /// No description provided for @cipher_field_name.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get cipher_field_name;

  /// No description provided for @cipher_field_username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get cipher_field_username;

  /// No description provided for @cipher_field_password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get cipher_field_password;

  /// No description provided for @cipher_field_website.
  ///
  /// In zh, this message translates to:
  /// **'网站'**
  String get cipher_field_website;

  /// No description provided for @cipher_field_notes.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get cipher_field_notes;

  /// No description provided for @cipher_field_folder.
  ///
  /// In zh, this message translates to:
  /// **'文件夹'**
  String get cipher_field_folder;

  /// No description provided for @cipher_field_cardholder.
  ///
  /// In zh, this message translates to:
  /// **'持卡人'**
  String get cipher_field_cardholder;

  /// No description provided for @cipher_field_cardNumber.
  ///
  /// In zh, this message translates to:
  /// **'卡号'**
  String get cipher_field_cardNumber;

  /// No description provided for @cipher_field_expMonth.
  ///
  /// In zh, this message translates to:
  /// **'月 MM'**
  String get cipher_field_expMonth;

  /// No description provided for @cipher_field_expYear.
  ///
  /// In zh, this message translates to:
  /// **'年 YY'**
  String get cipher_field_expYear;

  /// No description provided for @cipher_field_cardPinOptional.
  ///
  /// In zh, this message translates to:
  /// **'PIN（可选）'**
  String get cipher_field_cardPinOptional;

  /// No description provided for @cipher_field_docType.
  ///
  /// In zh, this message translates to:
  /// **'证件类型'**
  String get cipher_field_docType;

  /// No description provided for @cipher_field_fullName.
  ///
  /// In zh, this message translates to:
  /// **'姓名'**
  String get cipher_field_fullName;

  /// No description provided for @cipher_field_docNumber.
  ///
  /// In zh, this message translates to:
  /// **'证件号码'**
  String get cipher_field_docNumber;

  /// No description provided for @cipher_field_issueDate.
  ///
  /// In zh, this message translates to:
  /// **'签发日期'**
  String get cipher_field_issueDate;

  /// No description provided for @cipher_field_expiryDate.
  ///
  /// In zh, this message translates to:
  /// **'有效期'**
  String get cipher_field_expiryDate;

  /// No description provided for @cipher_field_title.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get cipher_field_title;

  /// No description provided for @cipher_field_content.
  ///
  /// In zh, this message translates to:
  /// **'内容'**
  String get cipher_field_content;

  /// No description provided for @cipher_field_privateKey.
  ///
  /// In zh, this message translates to:
  /// **'私钥'**
  String get cipher_field_privateKey;

  /// No description provided for @cipher_field_publicKeyOptional.
  ///
  /// In zh, this message translates to:
  /// **'公钥（可选）'**
  String get cipher_field_publicKeyOptional;

  /// No description provided for @cipher_field_passphraseOptional.
  ///
  /// In zh, this message translates to:
  /// **'口令（可选）'**
  String get cipher_field_passphraseOptional;

  /// No description provided for @cipher_field_host.
  ///
  /// In zh, this message translates to:
  /// **'主机'**
  String get cipher_field_host;

  /// No description provided for @cipher_field_account.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get cipher_field_account;

  /// No description provided for @cipher_field_bundleIdOptional.
  ///
  /// In zh, this message translates to:
  /// **'包名 / Bundle ID（可选）'**
  String get cipher_field_bundleIdOptional;

  /// No description provided for @cipher_descWebsiteLogin.
  ///
  /// In zh, this message translates to:
  /// **'保存第三方网站或服务的登录凭据，与 App 解锁密码无关。'**
  String get cipher_descWebsiteLogin;

  /// No description provided for @cipher_descBankCard.
  ///
  /// In zh, this message translates to:
  /// **'保存银行卡信息；列表仅展示卡号后四位。'**
  String get cipher_descBankCard;

  /// No description provided for @cipher_descIdentityDocument.
  ///
  /// In zh, this message translates to:
  /// **'保存身份证、护照等证件信息；列表仅展示证件类型与姓名摘要。'**
  String get cipher_descIdentityDocument;

  /// No description provided for @cipher_descSecureNote.
  ///
  /// In zh, this message translates to:
  /// **'保存加密笔记内容；列表展示标题摘要。'**
  String get cipher_descSecureNote;

  /// No description provided for @cipher_descSshKey.
  ///
  /// In zh, this message translates to:
  /// **'保存 SSH 私钥与连接信息；列表展示主机与用户摘要。'**
  String get cipher_descSshKey;

  /// No description provided for @cipher_descAppAccount.
  ///
  /// In zh, this message translates to:
  /// **'保存本地 App 的登录账号与密码，与 App 解锁密码无关。'**
  String get cipher_descAppAccount;

  /// No description provided for @cipher_validationWebsiteLogin.
  ///
  /// In zh, this message translates to:
  /// **'请填写名称、用户名和密码'**
  String get cipher_validationWebsiteLogin;

  /// No description provided for @cipher_validationBankCard.
  ///
  /// In zh, this message translates to:
  /// **'请填写名称、持卡人、卡号、有效期和 CVV'**
  String get cipher_validationBankCard;

  /// No description provided for @cipher_validationIdentityDocument.
  ///
  /// In zh, this message translates to:
  /// **'请填写名称、证件类型、姓名和证件号码'**
  String get cipher_validationIdentityDocument;

  /// No description provided for @cipher_validationSecureNote.
  ///
  /// In zh, this message translates to:
  /// **'请填写标题和笔记内容'**
  String get cipher_validationSecureNote;

  /// No description provided for @cipher_validationSshKey.
  ///
  /// In zh, this message translates to:
  /// **'请填写名称和私钥'**
  String get cipher_validationSshKey;

  /// No description provided for @cipher_validationAppAccount.
  ///
  /// In zh, this message translates to:
  /// **'请填写名称、账号和密码'**
  String get cipher_validationAppAccount;

  /// No description provided for @cipher_validationRequired.
  ///
  /// In zh, this message translates to:
  /// **'请完善必填项'**
  String get cipher_validationRequired;

  /// No description provided for @cipher_attachmentOptional.
  ///
  /// In zh, this message translates to:
  /// **'附件（可选）'**
  String get cipher_attachmentOptional;

  /// No description provided for @cipher_attachmentHint.
  ///
  /// In zh, this message translates to:
  /// **'可添加身份证正反面等照片'**
  String get cipher_attachmentHint;

  /// No description provided for @cipher_attachmentTakePhoto.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get cipher_attachmentTakePhoto;

  /// No description provided for @cipher_attachmentFromGallery.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择'**
  String get cipher_attachmentFromGallery;

  /// No description provided for @app_lock_title.
  ///
  /// In zh, this message translates to:
  /// **'应用保护'**
  String get app_lock_title;

  /// No description provided for @app_lock_enableTitle.
  ///
  /// In zh, this message translates to:
  /// **'启用应用保护'**
  String get app_lock_enableTitle;

  /// No description provided for @app_lock_enableSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'冷启动与回到前台时需要验证身份'**
  String get app_lock_enableSubtitle;

  /// No description provided for @app_lock_manageFallbackPin.
  ///
  /// In zh, this message translates to:
  /// **'管理备用密码'**
  String get app_lock_manageFallbackPin;

  /// No description provided for @app_lock_fallbackPinTitle.
  ///
  /// In zh, this message translates to:
  /// **'备用密码'**
  String get app_lock_fallbackPinTitle;

  /// No description provided for @app_lock_enabledToast.
  ///
  /// In zh, this message translates to:
  /// **'应用保护已开启'**
  String get app_lock_enabledToast;

  /// No description provided for @app_lock_setupPinTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置备用密码'**
  String get app_lock_setupPinTitle;

  /// No description provided for @app_lock_setupHintTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置提示语'**
  String get app_lock_setupHintTitle;

  /// No description provided for @app_lock_enterPinDigits.
  ///
  /// In zh, this message translates to:
  /// **'请输入 {length} 位数字密码'**
  String app_lock_enterPinDigits(int length);

  /// No description provided for @app_lock_pinLabel.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get app_lock_pinLabel;

  /// No description provided for @app_lock_hintDescription.
  ///
  /// In zh, this message translates to:
  /// **'设置一句提示语，忘记密码时可帮助你回忆备用密码。'**
  String get app_lock_hintDescription;

  /// No description provided for @app_lock_hintLabel.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码提示语'**
  String get app_lock_hintLabel;

  /// No description provided for @app_lock_confirmEnable.
  ///
  /// In zh, this message translates to:
  /// **'确认开启'**
  String get app_lock_confirmEnable;

  /// No description provided for @app_lock_previousStep.
  ///
  /// In zh, this message translates to:
  /// **'上一步'**
  String get app_lock_previousStep;

  /// No description provided for @app_lock_enableFailed.
  ///
  /// In zh, this message translates to:
  /// **'开启失败，请重试'**
  String get app_lock_enableFailed;

  /// No description provided for @app_lock_invalidPinFormat.
  ///
  /// In zh, this message translates to:
  /// **'密码格式无效'**
  String get app_lock_invalidPinFormat;

  /// No description provided for @app_lock_error_enterPinDigits.
  ///
  /// In zh, this message translates to:
  /// **'请输入 {length} 位数字密码'**
  String app_lock_error_enterPinDigits(int length);

  /// No description provided for @app_lock_error_pinMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入不一致'**
  String get app_lock_error_pinMismatch;

  /// No description provided for @app_lock_error_enterHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入提示语'**
  String get app_lock_error_enterHint;

  /// No description provided for @app_lock_error_hintTooLong.
  ///
  /// In zh, this message translates to:
  /// **'提示语不能超过 {max} 个字符'**
  String app_lock_error_hintTooLong(int max);

  /// No description provided for @app_lock_error_sameAsCurrent.
  ///
  /// In zh, this message translates to:
  /// **'新密码不能与当前密码相同'**
  String get app_lock_error_sameAsCurrent;

  /// No description provided for @app_lock_error_enterCurrentPin.
  ///
  /// In zh, this message translates to:
  /// **'请输入当前密码'**
  String get app_lock_error_enterCurrentPin;

  /// No description provided for @app_lock_error_wrongCurrentPin.
  ///
  /// In zh, this message translates to:
  /// **'当前密码错误'**
  String get app_lock_error_wrongCurrentPin;

  /// No description provided for @app_lock_authenticating.
  ///
  /// In zh, this message translates to:
  /// **'正在验证身份…'**
  String get app_lock_authenticating;

  /// No description provided for @app_lock_error_wrongPinRetry.
  ///
  /// In zh, this message translates to:
  /// **'密码错误，请重试'**
  String get app_lock_error_wrongPinRetry;

  /// No description provided for @app_lock_error_wrongAppPinRetry.
  ///
  /// In zh, this message translates to:
  /// **'应用内密码错误，请重试'**
  String get app_lock_error_wrongAppPinRetry;

  /// No description provided for @app_lock_error_authUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'当前无法验证身份，请重试'**
  String get app_lock_error_authUnavailable;

  /// No description provided for @app_lock_error_enterPin.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get app_lock_error_enterPin;

  /// No description provided for @app_lock_biometricUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'生物识别不可用，请输入密码'**
  String get app_lock_biometricUnavailable;

  /// No description provided for @app_lock_biometricFailed.
  ///
  /// In zh, this message translates to:
  /// **'生物识别未通过，请输入密码'**
  String get app_lock_biometricFailed;

  /// No description provided for @app_lock_inAppPinLabel.
  ///
  /// In zh, this message translates to:
  /// **'应用内密码'**
  String get app_lock_inAppPinLabel;

  /// No description provided for @app_lock_semantic_biometric.
  ///
  /// In zh, this message translates to:
  /// **'生物识别'**
  String get app_lock_semantic_biometric;

  /// No description provided for @app_lock_semantic_delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get app_lock_semantic_delete;

  /// No description provided for @app_lock_cannotClearPinReason.
  ///
  /// In zh, this message translates to:
  /// **'锁屏保护已开启且无其他解锁方式，请先关闭锁屏保护或启用生物识别'**
  String get app_lock_cannotClearPinReason;

  /// No description provided for @app_lock_reason_unlockOnResume.
  ///
  /// In zh, this message translates to:
  /// **'请验证身份以继续'**
  String get app_lock_reason_unlockOnResume;

  /// No description provided for @app_lock_reason_confirmSensitive.
  ///
  /// In zh, this message translates to:
  /// **'请验证身份以继续操作'**
  String get app_lock_reason_confirmSensitive;

  /// No description provided for @app_lock_reason_setupAppPin.
  ///
  /// In zh, this message translates to:
  /// **'请验证身份以设置应用密码'**
  String get app_lock_reason_setupAppPin;

  /// No description provided for @migration_title.
  ///
  /// In zh, this message translates to:
  /// **'数据迁移'**
  String get migration_title;

  /// No description provided for @migration_intro.
  ///
  /// In zh, this message translates to:
  /// **'在设备间安全迁移密码数据。导出文件均经加密处理。'**
  String get migration_intro;

  /// No description provided for @migration_exportFile.
  ///
  /// In zh, this message translates to:
  /// **'导出到文件'**
  String get migration_exportFile;

  /// No description provided for @migration_exportFileSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'加密打包后保存到本地'**
  String get migration_exportFileSubtitle;

  /// No description provided for @migration_importFile.
  ///
  /// In zh, this message translates to:
  /// **'从文件导入'**
  String get migration_importFile;

  /// No description provided for @migration_importFileSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'合并或覆盖现有数据'**
  String get migration_importFileSubtitle;

  /// No description provided for @migration_bluetoothShare.
  ///
  /// In zh, this message translates to:
  /// **'蓝牙共享'**
  String get migration_bluetoothShare;

  /// No description provided for @migration_bluetoothShareSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'同系统附近连接或跨平台 BLE 传输'**
  String get migration_bluetoothShareSubtitle;

  /// No description provided for @migration_localBackup.
  ///
  /// In zh, this message translates to:
  /// **'本地备份'**
  String get migration_localBackup;

  /// No description provided for @migration_localBackupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在应用内保留一份快照'**
  String get migration_localBackupSubtitle;

  /// No description provided for @migration_restoreBackup.
  ///
  /// In zh, this message translates to:
  /// **'恢复备份'**
  String get migration_restoreBackup;

  /// No description provided for @migration_restoreBackupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'从最近备份还原'**
  String get migration_restoreBackupSubtitle;

  /// No description provided for @migration_toastRestoreDone.
  ///
  /// In zh, this message translates to:
  /// **'恢复完成'**
  String get migration_toastRestoreDone;

  /// No description provided for @migration_toastRestoreFailed.
  ///
  /// In zh, this message translates to:
  /// **'恢复失败'**
  String get migration_toastRestoreFailed;

  /// No description provided for @migration_toastImportDone.
  ///
  /// In zh, this message translates to:
  /// **'导入完成'**
  String get migration_toastImportDone;

  /// No description provided for @migration_toastImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get migration_toastImportFailed;

  /// No description provided for @migration_toastBackupCreated.
  ///
  /// In zh, this message translates to:
  /// **'本地备份已创建'**
  String get migration_toastBackupCreated;

  /// No description provided for @migration_toastBackupFailed.
  ///
  /// In zh, this message translates to:
  /// **'备份失败'**
  String get migration_toastBackupFailed;

  /// No description provided for @migration_toastNoLocalBackup.
  ///
  /// In zh, this message translates to:
  /// **'暂无本地备份'**
  String get migration_toastNoLocalBackup;

  /// No description provided for @migration_toastExportDone.
  ///
  /// In zh, this message translates to:
  /// **'已导出备份'**
  String get migration_toastExportDone;

  /// No description provided for @migration_toastExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get migration_toastExportFailed;

  /// No description provided for @migration_restoreTitle.
  ///
  /// In zh, this message translates to:
  /// **'恢复备份'**
  String get migration_restoreTitle;

  /// No description provided for @migration_localBackupDefaultNote.
  ///
  /// In zh, this message translates to:
  /// **'本地备份'**
  String get migration_localBackupDefaultNote;

  /// No description provided for @migration_modeMerge.
  ///
  /// In zh, this message translates to:
  /// **'合并'**
  String get migration_modeMerge;

  /// No description provided for @migration_modeReplace.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get migration_modeReplace;

  /// No description provided for @migration_replaceWarning.
  ///
  /// In zh, this message translates to:
  /// **'覆盖将删除当前全部密码数据，且不可撤销。'**
  String get migration_replaceWarning;

  /// No description provided for @migration_startRestore.
  ///
  /// In zh, this message translates to:
  /// **'开始恢复'**
  String get migration_startRestore;

  /// No description provided for @migration_importModeTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择导入方式'**
  String get migration_importModeTitle;

  /// No description provided for @migration_importModeDescription.
  ///
  /// In zh, this message translates to:
  /// **'合并会保留本地独有条目；覆盖会用备份替换全部密码数据。'**
  String get migration_importModeDescription;

  /// No description provided for @migration_importMerge.
  ///
  /// In zh, this message translates to:
  /// **'合并导入'**
  String get migration_importMerge;

  /// No description provided for @migration_importReplace.
  ///
  /// In zh, this message translates to:
  /// **'覆盖导入'**
  String get migration_importReplace;

  /// No description provided for @migration_importReplaceDanger.
  ///
  /// In zh, this message translates to:
  /// **'覆盖导入（危险）'**
  String get migration_importReplaceDanger;

  /// No description provided for @migration_importModeHint.
  ///
  /// In zh, this message translates to:
  /// **'合并会保留本机已有数据；覆盖会先清空再导入，请谨慎选择。'**
  String get migration_importModeHint;

  /// No description provided for @migration_btSheetTitle.
  ///
  /// In zh, this message translates to:
  /// **'蓝牙共享'**
  String get migration_btSheetTitle;

  /// No description provided for @migration_btSheetDescription.
  ///
  /// In zh, this message translates to:
  /// **'传输完整加密备份。同系统使用附近连接；跨系统（iOS↔Android）使用 BLE，请保持两台设备在前台。'**
  String get migration_btSheetDescription;

  /// No description provided for @migration_btSameOsTitle.
  ///
  /// In zh, this message translates to:
  /// **'同系统附近连接'**
  String get migration_btSameOsTitle;

  /// No description provided for @migration_btSameOsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'Android↔Android 或 iOS↔iOS'**
  String get migration_btSameOsSubtitle;

  /// No description provided for @migration_btSameOsSend.
  ///
  /// In zh, this message translates to:
  /// **'同系统 · 发送'**
  String get migration_btSameOsSend;

  /// No description provided for @migration_btSameOsReceive.
  ///
  /// In zh, this message translates to:
  /// **'同系统 · 接收'**
  String get migration_btSameOsReceive;

  /// No description provided for @migration_btCrossPlatformTitle.
  ///
  /// In zh, this message translates to:
  /// **'跨平台 BLE'**
  String get migration_btCrossPlatformTitle;

  /// No description provided for @migration_btCrossPlatformSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'iOS 与 Android 互传；大备份可能需数分钟'**
  String get migration_btCrossPlatformSubtitle;

  /// No description provided for @migration_btCrossPlatformSend.
  ///
  /// In zh, this message translates to:
  /// **'跨平台 · 发送'**
  String get migration_btCrossPlatformSend;

  /// No description provided for @migration_btCrossPlatformReceive.
  ///
  /// In zh, this message translates to:
  /// **'跨平台 · 接收'**
  String get migration_btCrossPlatformReceive;

  /// No description provided for @migration_btCrossPlatformSendTitle.
  ///
  /// In zh, this message translates to:
  /// **'跨平台发送'**
  String get migration_btCrossPlatformSendTitle;

  /// No description provided for @migration_btCrossPlatformReceiveTitle.
  ///
  /// In zh, this message translates to:
  /// **'跨平台接收'**
  String get migration_btCrossPlatformReceiveTitle;

  /// No description provided for @migration_btNearbySendTitle.
  ///
  /// In zh, this message translates to:
  /// **'发送到附近设备'**
  String get migration_btNearbySendTitle;

  /// No description provided for @migration_btNearbyReceiveTitle.
  ///
  /// In zh, this message translates to:
  /// **'从附近设备接收'**
  String get migration_btNearbyReceiveTitle;

  /// No description provided for @migration_btConnectingPeer.
  ///
  /// In zh, this message translates to:
  /// **'正在连接 {name}…'**
  String migration_btConnectingPeer(String name);

  /// No description provided for @migration_btConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败：{error}'**
  String migration_btConnectionFailed(String error);

  /// No description provided for @migration_btCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get migration_btCancelled;

  /// No description provided for @migration_btTransferFailed.
  ///
  /// In zh, this message translates to:
  /// **'传输失败：{error}'**
  String migration_btTransferFailed(String error);

  /// No description provided for @migration_btTransferProgress.
  ///
  /// In zh, this message translates to:
  /// **'传输进度 {percent}%'**
  String migration_btTransferProgress(int percent);

  /// No description provided for @migration_btTransferringBle.
  ///
  /// In zh, this message translates to:
  /// **'正在通过 BLE 传输加密备份… {percent}%'**
  String migration_btTransferringBle(int percent);

  /// No description provided for @migration_btTransferring.
  ///
  /// In zh, this message translates to:
  /// **'正在传输加密备份… {percent}%'**
  String migration_btTransferring(int percent);

  /// No description provided for @migration_btScanningCrossPlatformReceiver.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描跨平台接收端…'**
  String get migration_btScanningCrossPlatformReceiver;

  /// No description provided for @migration_btWaitingCrossPlatformSender.
  ///
  /// In zh, this message translates to:
  /// **'等待跨平台发送端连接…'**
  String get migration_btWaitingCrossPlatformSender;

  /// No description provided for @migration_btSearchingNearby.
  ///
  /// In zh, this message translates to:
  /// **'正在搜索附近设备…'**
  String get migration_btSearchingNearby;

  /// No description provided for @migration_btWaitingSender.
  ///
  /// In zh, this message translates to:
  /// **'等待发送端连接…'**
  String get migration_btWaitingSender;

  /// No description provided for @migration_btConnecting.
  ///
  /// In zh, this message translates to:
  /// **'正在连接…'**
  String get migration_btConnecting;

  /// No description provided for @migration_btCompleted.
  ///
  /// In zh, this message translates to:
  /// **'传输完成'**
  String get migration_btCompleted;

  /// No description provided for @migration_btSendDoneCrossPlatform.
  ///
  /// In zh, this message translates to:
  /// **'备份已发送到跨平台设备'**
  String get migration_btSendDoneCrossPlatform;

  /// No description provided for @migration_btSendDoneNearby.
  ///
  /// In zh, this message translates to:
  /// **'备份已发送到附近设备'**
  String get migration_btSendDoneNearby;

  /// No description provided for @migration_btSendDoneToast.
  ///
  /// In zh, this message translates to:
  /// **'发送完成'**
  String get migration_btSendDoneToast;

  /// No description provided for @migration_btReceivedChooseImport.
  ///
  /// In zh, this message translates to:
  /// **'已收到备份，请选择导入方式'**
  String get migration_btReceivedChooseImport;

  /// No description provided for @migration_btRemainingTime.
  ///
  /// In zh, this message translates to:
  /// **'剩余连接时间 {time}'**
  String migration_btRemainingTime(String time);

  /// No description provided for @migration_btInstructionCrossPlatformReceive.
  ///
  /// In zh, this message translates to:
  /// **'请在对端选择「跨平台 · 接收」并保持前台'**
  String get migration_btInstructionCrossPlatformReceive;

  /// No description provided for @migration_btInstructionCrossPlatformSend.
  ///
  /// In zh, this message translates to:
  /// **'请在对端选择「跨平台 · 发送」并保持前台'**
  String get migration_btInstructionCrossPlatformSend;

  /// No description provided for @migration_btInstructionSameOsReceive.
  ///
  /// In zh, this message translates to:
  /// **'请在对端选择「同系统 · 接收」'**
  String get migration_btInstructionSameOsReceive;

  /// No description provided for @migration_btInstructionSameOsSend.
  ///
  /// In zh, this message translates to:
  /// **'请在对端选择「同系统 · 发送」'**
  String get migration_btInstructionSameOsSend;

  /// No description provided for @migration_btUnknownDevice.
  ///
  /// In zh, this message translates to:
  /// **'未知设备'**
  String get migration_btUnknownDevice;

  /// No description provided for @support_feedbackTitle.
  ///
  /// In zh, this message translates to:
  /// **'客服反馈'**
  String get support_feedbackTitle;

  /// No description provided for @support_feedbackIntro.
  ///
  /// In zh, this message translates to:
  /// **'请描述你遇到的问题或建议。点击「发送邮件反馈」将打开系统邮件应用，收件人已预设为 {email}，请确认内容后点击发送。'**
  String support_feedbackIntro(String email);

  /// No description provided for @support_contactEmailOptional.
  ///
  /// In zh, this message translates to:
  /// **'联系邮箱（选填）'**
  String get support_contactEmailOptional;

  /// No description provided for @support_feedbackContent.
  ///
  /// In zh, this message translates to:
  /// **'反馈内容'**
  String get support_feedbackContent;

  /// No description provided for @support_sendFeedbackEmail.
  ///
  /// In zh, this message translates to:
  /// **'发送邮件反馈'**
  String get support_sendFeedbackEmail;

  /// No description provided for @support_toastMailOpened.
  ///
  /// In zh, this message translates to:
  /// **'已打开邮件应用，请确认收件人后发送'**
  String get support_toastMailOpened;

  /// No description provided for @support_toastMailUnavailableCopied.
  ///
  /// In zh, this message translates to:
  /// **'无法打开邮件应用，已复制反馈内容'**
  String get support_toastMailUnavailableCopied;

  /// No description provided for @support_emailSubject.
  ///
  /// In zh, this message translates to:
  /// **'BarrelLock 用户反馈'**
  String get support_emailSubject;

  /// No description provided for @support_docNotFoundTitle.
  ///
  /// In zh, this message translates to:
  /// **'内容不存在'**
  String get support_docNotFoundTitle;

  /// No description provided for @support_docNotFoundBody.
  ///
  /// In zh, this message translates to:
  /// **'该文档暂未提供，请返回后重试。'**
  String get support_docNotFoundBody;

  /// No description provided for @support_entryNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'暂不支持该入口'**
  String get support_entryNotSupported;

  /// No description provided for @support_docSecurityHelp.
  ///
  /// In zh, this message translates to:
  /// **'安全帮助文档'**
  String get support_docSecurityHelp;

  /// No description provided for @support_docEncryption.
  ///
  /// In zh, this message translates to:
  /// **'加密说明'**
  String get support_docEncryption;

  /// No description provided for @support_docTerms.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get support_docTerms;

  /// No description provided for @support_docPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get support_docPrivacy;

  /// No description provided for @settings_section_general.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settings_section_general;

  /// No description provided for @settings_sectionHint_general.
  ///
  /// In zh, this message translates to:
  /// **'语言与区域偏好。'**
  String get settings_sectionHint_general;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
