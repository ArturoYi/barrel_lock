// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get common_cancel => 'إلغاء';

  @override
  String get common_save => 'حفظ';

  @override
  String get common_confirm => 'تأكيد';

  @override
  String get common_error => 'حدث خطأ ما';

  @override
  String get common_back => 'رجوع';

  @override
  String get common_delete => 'حذف';

  @override
  String get common_edit => 'تعديل';

  @override
  String get common_loading => 'جارٍ التحميل…';

  @override
  String get common_retry => 'إعادة المحاولة';

  @override
  String get common_done => 'تم';

  @override
  String get common_create => 'إنشاء';

  @override
  String get common_add => 'إضافة';

  @override
  String get common_show => 'إظهار';

  @override
  String get common_hide => 'إخفاء';

  @override
  String get common_showPassword => 'إظهار كلمة المرور';

  @override
  String get common_hidePassword => 'إخفاء كلمة المرور';

  @override
  String get common_copy => 'نسخ';

  @override
  String get common_favorite => 'إضافة إلى المفضلة';

  @override
  String get common_unfavorite => 'إزالة من المفضلة';

  @override
  String get common_notSet => 'غير محدد';

  @override
  String get common_set => 'محدد';

  @override
  String get common_ungrouped => 'غير مصنّف';

  @override
  String get common_other => 'أخرى';

  @override
  String get common_unnamedVault => 'خزنة بدون اسم';

  @override
  String get common_loadingFolders => 'جارٍ تحميل المجلدات…';

  @override
  String get common_newFolderEllipsis => 'مجلد جديد…';

  @override
  String common_loadFailed(String error) {
    return 'فشل التحميل: $error';
  }

  @override
  String get overlay_loading => 'جارٍ التحميل…';

  @override
  String get overlay_success => 'تمت العملية بنجاح';

  @override
  String get overlay_error => 'فشلت العملية';

  @override
  String get overlay_please_wait => 'يُرجى الانتظار';

  @override
  String get locale_follow_system => 'النظام';

  @override
  String get settings_language => 'اللغة';

  @override
  String get settings_language_follow_system => 'اتباع لغة النظام';

  @override
  String get settings_language_summary_system => 'اتباع النظام';

  @override
  String get settings_language_summary_zh_hans => '简体中文';

  @override
  String get settings_language_summary_zh_hant => '繁體中文';

  @override
  String get settings_language_summary_en => 'English';

  @override
  String get settings_language_summary_ar => 'العربية';

  @override
  String get settings_title => 'الإعدادات';

  @override
  String get settings_section_data => 'البيانات';

  @override
  String get settings_section_security => 'الأمان';

  @override
  String get settings_section_support => 'الدعم';

  @override
  String get settings_section_appearance => 'المظهر';

  @override
  String get settings_section_about => 'حول التطبيق';

  @override
  String get settings_dataMigration => 'ترحيل البيانات';

  @override
  String get settings_dataMigrationSubtitle =>
      'تصدير، استيراد، مشاركة عبر Bluetooth، نسخ احتياطي واستعادة';

  @override
  String get settings_appLock => 'قفل التطبيق';

  @override
  String get settings_appLockSubtitle =>
      'فتح بالقياسات الحيوية ورمز PIN احتياطي';

  @override
  String get settings_clearData => 'مسح جميع البيانات';

  @override
  String get settings_clearDataSubtitle => 'يحذف جميع كلمات المرور نهائيًا';

  @override
  String get settings_helpDoc => 'مساعدة الأمان';

  @override
  String get settings_feedback => 'التواصل مع الدعم';

  @override
  String get settings_userAgreement => 'شروط الخدمة';

  @override
  String get settings_privacyPolicy => 'سياسة الخصوصية';

  @override
  String get settings_encryptionDoc => 'تفاصيل التشفير';

  @override
  String get settings_themeDisplay => 'السمة والعرض';

  @override
  String get settings_themeDisplaySubtitle =>
      'الوضع الداكن، لون التمييز، حجم الخط';

  @override
  String get settings_versionInfo => 'معلومات الإصدار';

  @override
  String get settings_themeMode => 'وضع السمة';

  @override
  String get settings_themeFollowSystem => 'النظام';

  @override
  String get settings_themeLight => 'فاتح';

  @override
  String get settings_themeDark => 'داكن';

  @override
  String get settings_accentColor => 'لون التمييز';

  @override
  String get settings_fontSize => 'حجم الخط';

  @override
  String get settings_fontScale_small => 'صغير';

  @override
  String get settings_fontScale_standard => 'قياسي';

  @override
  String get settings_fontScale_large => 'كبير';

  @override
  String get settings_fontScale_extraLarge => 'كبير جدًا';

  @override
  String get settings_colorScheme_deepPurple => 'بنفسجي';

  @override
  String get settings_colorScheme_blue => 'أزرق';

  @override
  String get settings_colorScheme_green => 'أخضر';

  @override
  String get settings_colorScheme_orange => 'برتقالي';

  @override
  String get settings_colorScheme_teal => 'تركواز';

  @override
  String settings_sectionItemCount(int count) {
    return '$count عنصر';
  }

  @override
  String get settings_sectionHint_theme => 'اضبط مظهر التطبيق وسهولة القراءة.';

  @override
  String get settings_sectionHint_data =>
      'تظهر هنا عمليات الاستيراد والتصدير والنسخ الاحتياطي.';

  @override
  String get settings_sectionHint_security =>
      'يتطلب قفل التطبيق والإجراءات الخطرة تأكيدًا.';

  @override
  String get settings_sectionHint_support =>
      'روابط المساعدة والمستندات القانونية.';

  @override
  String get settings_sectionHint_about => 'إصدار التطبيق ومعلومات البناء.';

  @override
  String get settings_clearData_stepIdle =>
      'سيؤدي هذا إلى حذف جميع كلمات المرور نهائيًا ولا يمكن التراجع عنه.';

  @override
  String get settings_clearData_stepConfirm1 =>
      'هل أنت متأكد أنك تريد مسح جميع البيانات؟';

  @override
  String get settings_clearData_stepConfirm2 =>
      'تأكيد نهائي: لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get settings_clearData_stepClearing => 'جارٍ المسح…';

  @override
  String get settings_clearData_stepDone => 'تم مسح جميع كلمات المرور.';

  @override
  String get settings_clearData_start => 'بدء المسح';

  @override
  String get settings_clearData_understandRisk => 'أدرك المخاطر، متابعة';

  @override
  String get settings_clearData_confirmDelete => 'تأكيد الحذف النهائي';

  @override
  String get tab_password => 'كلمات المرور';

  @override
  String get tab_settings => 'الإعدادات';

  @override
  String get tab_filterAll => 'الكل';

  @override
  String get tab_filterFavorites => 'المفضلة';

  @override
  String get tab_filterRecent => 'الأحدث';

  @override
  String get tab_searchHint =>
      'ابحث في كلمات المرور والمواقع وأسماء المستخدمين';

  @override
  String get tab_switchVault => 'تبديل الخزنة';

  @override
  String get tab_newVault => 'خزنة جديدة';

  @override
  String get tab_createVault => 'إنشاء خزنة';

  @override
  String get tab_createVaultHint => 'مثل: العمل، الشخصي';

  @override
  String get tab_vaultNameLabel => 'اسم الخزنة';

  @override
  String get tab_newFolder => 'مجلد جديد';

  @override
  String get tab_folderNameLabel => 'اسم المجلد';

  @override
  String get tab_folderNameHint => 'مثل: التواصل، البطاقات البنكية';

  @override
  String get tab_emptyNoVaultTitle => 'لا توجد خزنة بعد';

  @override
  String get tab_emptyNoVaultSubtitle => 'أنشئ خزنة لبدء إدارة كلمات المرور';

  @override
  String get tab_emptyNoItemsTitle => 'لا توجد كلمات مرور بعد';

  @override
  String get tab_addPassword => 'إضافة كلمة مرور';

  @override
  String get tab_nameRequired => 'أدخل اسمًا';

  @override
  String get error_page_not_found => '404 — الصفحة غير موجودة';

  @override
  String get cipher_addTitle => 'إضافة كلمة مرور';

  @override
  String get cipher_addedToast => 'تمت الإضافة';

  @override
  String get cipher_saveFailed => 'فشل الحفظ، حاول مرة أخرى لاحقًا';

  @override
  String get cipher_typeWebsiteLogin => 'تسجيل دخول موقع';

  @override
  String get cipher_typeBankCard => 'بطاقة بنكية';

  @override
  String get cipher_typeIdentityDocument => 'وثيقة هوية';

  @override
  String get cipher_typeSecureNote => 'ملاحظة آمنة';

  @override
  String get cipher_typeAppAccount => 'حساب تطبيق';

  @override
  String get cipher_typeSshKey => 'مفتاح SSH';

  @override
  String cipher_formComingSoon(String type) {
    return 'نموذج $type قريبًا';
  }

  @override
  String get cipher_defaultVaultName => 'خزنتي';

  @override
  String get cipher_field_name => 'الاسم';

  @override
  String get cipher_field_username => 'اسم المستخدم';

  @override
  String get cipher_field_password => 'كلمة المرور';

  @override
  String get cipher_field_website => 'الموقع';

  @override
  String get cipher_field_notes => 'ملاحظات';

  @override
  String get cipher_field_folder => 'المجلد';

  @override
  String get cipher_field_cardholder => 'اسم حامل البطاقة';

  @override
  String get cipher_field_cardNumber => 'رقم البطاقة';

  @override
  String get cipher_field_expMonth => 'MM';

  @override
  String get cipher_field_expYear => 'YY';

  @override
  String get cipher_field_cardPinOptional => 'رمز PIN (اختياري)';

  @override
  String get cipher_field_docType => 'نوع الوثيقة';

  @override
  String get cipher_field_fullName => 'الاسم الكامل';

  @override
  String get cipher_field_docNumber => 'رقم الوثيقة';

  @override
  String get cipher_field_issueDate => 'تاريخ الإصدار';

  @override
  String get cipher_field_expiryDate => 'تاريخ الانتهاء';

  @override
  String get cipher_field_title => 'العنوان';

  @override
  String get cipher_field_content => 'المحتوى';

  @override
  String get cipher_field_privateKey => 'المفتاح الخاص';

  @override
  String get cipher_field_publicKeyOptional => 'المفتاح العام (اختياري)';

  @override
  String get cipher_field_passphraseOptional => 'عبارة المرور (اختياري)';

  @override
  String get cipher_field_host => 'المضيف';

  @override
  String get cipher_field_account => 'الحساب';

  @override
  String get cipher_field_bundleIdOptional =>
      'معرّف الحزمة / Bundle ID (اختياري)';

  @override
  String get cipher_descWebsiteLogin =>
      'احفظ بيانات تسجيل الدخول للمواقع والخدمات. ليست كلمة مرور فتح التطبيق.';

  @override
  String get cipher_descBankCard =>
      'احفظ معلومات البطاقة البنكية؛ تعرض القائمة آخر 4 أرقام فقط.';

  @override
  String get cipher_descIdentityDocument =>
      'احفظ وثائق الهوية؛ تعرض القائمة النوع وملخص الاسم فقط.';

  @override
  String get cipher_descSecureNote =>
      'احفظ ملاحظات مشفّرة؛ تعرض القائمة ملخص العنوان.';

  @override
  String get cipher_descSshKey =>
      'احفظ مفاتيح SSH ومعلومات الاتصال؛ تعرض القائمة ملخص المضيف والمستخدم.';

  @override
  String get cipher_descAppAccount =>
      'احفظ بيانات تسجيل دخول التطبيقات. ليست كلمة مرور فتح التطبيق.';

  @override
  String get cipher_validationWebsiteLogin =>
      'أكمل الاسم واسم المستخدم وكلمة المرور';

  @override
  String get cipher_validationBankCard =>
      'أكمل الاسم واسم حامل البطاقة والرقم وتاريخ الانتهاء ورمز CVV';

  @override
  String get cipher_validationIdentityDocument =>
      'أكمل الاسم ونوع الوثيقة والاسم والرقم';

  @override
  String get cipher_validationSecureNote => 'أكمل العنوان ومحتوى الملاحظة';

  @override
  String get cipher_validationSshKey => 'أكمل الاسم والمفتاح الخاص';

  @override
  String get cipher_validationAppAccount => 'أكمل الاسم والحساب وكلمة المرور';

  @override
  String get cipher_validationRequired => 'أكمل الحقول المطلوبة';

  @override
  String get cipher_attachmentOptional => 'مرفقات (اختياري)';

  @override
  String get cipher_attachmentHint => 'أضف صورًا مثل وجه وظهر الهوية';

  @override
  String get cipher_attachmentTakePhoto => 'التقاط صورة';

  @override
  String get cipher_attachmentFromGallery => 'اختيار من المعرض';

  @override
  String get app_lock_title => 'حماية التطبيق';

  @override
  String get app_lock_enableTitle => 'تفعيل حماية التطبيق';

  @override
  String get app_lock_enableSubtitle =>
      'التحقق من الهوية عند التشغيل وعند العودة إلى الواجهة';

  @override
  String get app_lock_manageFallbackPin => 'إدارة رمز PIN الاحتياطي';

  @override
  String get app_lock_fallbackPinTitle => 'رمز PIN الاحتياطي';

  @override
  String get app_lock_enabledToast => 'تم تفعيل حماية التطبيق';

  @override
  String get app_lock_setupPinTitle => 'تعيين رمز PIN الاحتياطي';

  @override
  String get app_lock_setupHintTitle => 'تعيين تلميح';

  @override
  String app_lock_enterPinDigits(int length) {
    return 'أدخل رمز PIN مكوّنًا من $length أرقام';
  }

  @override
  String get app_lock_pinLabel => 'رمز PIN';

  @override
  String get app_lock_hintDescription =>
      'عيّن تلميحًا لمساعدتك على تذكّر رمز PIN الاحتياطي إذا نسيته.';

  @override
  String get app_lock_hintLabel => 'تلميح عند نسيان رمز PIN';

  @override
  String get app_lock_confirmEnable => 'تأكيد وتفعيل';

  @override
  String get app_lock_previousStep => 'السابق';

  @override
  String get app_lock_enableFailed => 'فشل التفعيل، يُرجى المحاولة مرة أخرى';

  @override
  String get app_lock_invalidPinFormat => 'صيغة رمز PIN غير صالحة';

  @override
  String app_lock_error_enterPinDigits(int length) {
    return 'أدخل رمز PIN مكوّنًا من $length أرقام';
  }

  @override
  String get app_lock_error_pinMismatch => 'رمزا PIN غير متطابقين';

  @override
  String get app_lock_error_enterHint => 'أدخل تلميحًا';

  @override
  String app_lock_error_hintTooLong(int max) {
    return 'لا يمكن أن يتجاوز التلميح $max حرفًا';
  }

  @override
  String get app_lock_error_sameAsCurrent =>
      'لا يمكن أن يكون رمز PIN الجديد مطابقًا للرمز الحالي';

  @override
  String get app_lock_error_enterCurrentPin => 'أدخل رمز PIN الحالي';

  @override
  String get app_lock_error_wrongCurrentPin => 'رمز PIN الحالي غير صحيح';

  @override
  String get app_lock_authenticating => 'جارٍ التحقق من الهوية…';

  @override
  String get app_lock_error_wrongPinRetry => 'رمز PIN غير صحيح، حاول مرة أخرى';

  @override
  String get app_lock_error_wrongAppPinRetry =>
      'رمز PIN للتطبيق غير صحيح، حاول مرة أخرى';

  @override
  String get app_lock_error_authUnavailable =>
      'تعذّر التحقق من الهوية، حاول مرة أخرى';

  @override
  String get app_lock_error_enterPin => 'أدخل رمز PIN';

  @override
  String get app_lock_biometricUnavailable =>
      'القياسات الحيوية غير متاحة، أدخل رمز PIN';

  @override
  String get app_lock_biometricFailed =>
      'فشل التحقق بالقياسات الحيوية، أدخل رمز PIN';

  @override
  String get app_lock_inAppPinLabel => 'رمز PIN داخل التطبيق';

  @override
  String get app_lock_semantic_biometric => 'القياسات الحيوية';

  @override
  String get app_lock_semantic_delete => 'حذف';

  @override
  String get app_lock_cannotClearPinReason =>
      'قفل التطبيق مفعّل ولا توجد طريقة فتح أخرى. عطّل قفل التطبيق أو فعّل القياسات الحيوية أولًا.';

  @override
  String get app_lock_reason_unlockOnResume => 'تحقّق من هويتك للمتابعة';

  @override
  String get app_lock_reason_confirmSensitive => 'تحقّق من هويتك للمتابعة';

  @override
  String get app_lock_reason_setupAppPin =>
      'تحقّق من هويتك لتعيين رمز PIN للتطبيق';

  @override
  String get migration_title => 'ترحيل البيانات';

  @override
  String get migration_intro =>
      'انقل كلمات المرور بين الأجهزة بأمان. الملفات المُصدَّرة مشفّرة.';

  @override
  String get migration_exportFile => 'تصدير إلى ملف';

  @override
  String get migration_exportFileSubtitle => 'تشفير وحفظ محليًا';

  @override
  String get migration_importFile => 'استيراد من ملف';

  @override
  String get migration_importFileSubtitle => 'دمج أو استبدال البيانات الحالية';

  @override
  String get migration_bluetoothShare => 'مشاركة عبر Bluetooth';

  @override
  String get migration_bluetoothShareSubtitle =>
      'أجهزة قريبة بنفس النظام أو BLE عبر الأنظمة';

  @override
  String get migration_localBackup => 'نسخ احتياطي محلي';

  @override
  String get migration_localBackupSubtitle => 'احتفظ بلقطة داخل التطبيق';

  @override
  String get migration_restoreBackup => 'استعادة النسخ الاحتياطي';

  @override
  String get migration_restoreBackupSubtitle => 'استعادة من أحدث نسخة احتياطية';

  @override
  String get migration_toastRestoreDone => 'اكتملت الاستعادة';

  @override
  String get migration_toastRestoreFailed => 'فشلت الاستعادة';

  @override
  String get migration_toastImportDone => 'اكتمل الاستيراد';

  @override
  String get migration_toastImportFailed => 'فشل الاستيراد';

  @override
  String get migration_toastBackupCreated => 'تم إنشاء نسخة احتياطية محلية';

  @override
  String get migration_toastBackupFailed => 'فشل النسخ الاحتياطي';

  @override
  String get migration_toastNoLocalBackup => 'لا توجد نسخ احتياطية محلية';

  @override
  String get migration_toastExportDone => 'تم تصدير النسخة الاحتياطية';

  @override
  String get migration_toastExportFailed => 'فشل التصدير';

  @override
  String get migration_restoreTitle => 'استعادة النسخ الاحتياطي';

  @override
  String get migration_localBackupDefaultNote => 'نسخة احتياطية محلية';

  @override
  String get migration_modeMerge => 'دمج';

  @override
  String get migration_modeReplace => 'استبدال';

  @override
  String get migration_replaceWarning =>
      'يحذف الاستبدال جميع كلمات المرور الحالية ولا يمكن التراجع عنه.';

  @override
  String get migration_startRestore => 'بدء الاستعادة';

  @override
  String get migration_importModeTitle => 'وضع الاستيراد';

  @override
  String get migration_importModeDescription =>
      'يحافظ الدمج على العناصر المحلية فقط؛ يستبدل الاستبدال جميع بيانات كلمات المرور.';

  @override
  String get migration_importMerge => 'استيراد بالدمج';

  @override
  String get migration_importReplace => 'استيراد بالاستبدال';

  @override
  String get migration_importReplaceDanger => 'استيراد بالاستبدال (خطير)';

  @override
  String get migration_importModeHint =>
      'يحافظ الدمج على البيانات الحالية؛ يمسح الاستبدال أولًا. اختر بعناية.';

  @override
  String get migration_btSheetTitle => 'مشاركة عبر Bluetooth';

  @override
  String get migration_btSheetDescription =>
      'انقل نسخة احتياطية مشفّرة. يستخدم نفس النظام الأجهزة القريبة؛ عبر الأنظمة (iOS↔Android) يستخدم BLE. أبقِ كلا الجهازين في الواجهة.';

  @override
  String get migration_btSameOsTitle => 'أجهزة قريبة بنفس النظام';

  @override
  String get migration_btSameOsSubtitle => 'Android↔Android أو iOS↔iOS';

  @override
  String get migration_btSameOsSend => 'نفس النظام · إرسال';

  @override
  String get migration_btSameOsReceive => 'نفس النظام · استقبال';

  @override
  String get migration_btCrossPlatformTitle => 'BLE عبر الأنظمة';

  @override
  String get migration_btCrossPlatformSubtitle =>
      'iOS ↔ Android؛ قد تستغرق النسخ الكبيرة دقائق';

  @override
  String get migration_btCrossPlatformSend => 'عبر الأنظمة · إرسال';

  @override
  String get migration_btCrossPlatformReceive => 'عبر الأنظمة · استقبال';

  @override
  String get migration_btCrossPlatformSendTitle => 'إرسال عبر الأنظمة';

  @override
  String get migration_btCrossPlatformReceiveTitle => 'استقبال عبر الأنظمة';

  @override
  String get migration_btNearbySendTitle => 'إرسال إلى جهاز قريب';

  @override
  String get migration_btNearbyReceiveTitle => 'استقبال من جهاز قريب';

  @override
  String migration_btConnectingPeer(String name) {
    return 'جارٍ الاتصال بـ $name…';
  }

  @override
  String migration_btConnectionFailed(String error) {
    return 'فشل الاتصال: $error';
  }

  @override
  String get migration_btCancelled => 'تم الإلغاء';

  @override
  String migration_btTransferFailed(String error) {
    return 'فشل النقل: $error';
  }

  @override
  String migration_btTransferProgress(int percent) {
    return 'تقدّم النقل $percent%';
  }

  @override
  String migration_btTransferringBle(int percent) {
    return 'جارٍ النقل عبر BLE… $percent%';
  }

  @override
  String migration_btTransferring(int percent) {
    return 'جارٍ نقل النسخة الاحتياطية المشفّرة… $percent%';
  }

  @override
  String get migration_btScanningCrossPlatformReceiver =>
      'جارٍ البحث عن مستقبلات عبر الأنظمة…';

  @override
  String get migration_btWaitingCrossPlatformSender =>
      'بانتظار مرسل عبر الأنظمة…';

  @override
  String get migration_btSearchingNearby => 'جارٍ البحث عن أجهزة قريبة…';

  @override
  String get migration_btWaitingSender => 'بانتظار المرسل…';

  @override
  String get migration_btConnecting => 'جارٍ الاتصال…';

  @override
  String get migration_btCompleted => 'اكتمل النقل';

  @override
  String get migration_btSendDoneCrossPlatform =>
      'تم إرسال النسخة الاحتياطية إلى جهاز عبر الأنظمة';

  @override
  String get migration_btSendDoneNearby =>
      'تم إرسال النسخة الاحتياطية إلى جهاز قريب';

  @override
  String get migration_btSendDoneToast => 'اكتمل الإرسال';

  @override
  String get migration_btReceivedChooseImport =>
      'تم استلام النسخة الاحتياطية. اختر وضع الاستيراد.';

  @override
  String migration_btRemainingTime(String time) {
    return 'الوقت المتبقي للاتصال $time';
  }

  @override
  String get migration_btInstructionCrossPlatformReceive =>
      'على الجهاز الآخر، اختر \"عبر الأنظمة · استقبال\" وأبقِ التطبيق في الواجهة';

  @override
  String get migration_btInstructionCrossPlatformSend =>
      'على الجهاز الآخر، اختر \"عبر الأنظمة · إرسال\" وأبقِ التطبيق في الواجهة';

  @override
  String get migration_btInstructionSameOsReceive =>
      'على الجهاز الآخر، اختر \"نفس النظام · استقبال\"';

  @override
  String get migration_btInstructionSameOsSend =>
      'على الجهاز الآخر، اختر \"نفس النظام · إرسال\"';

  @override
  String get migration_btUnknownDevice => 'جهاز غير معروف';

  @override
  String get support_feedbackTitle => 'التواصل مع الدعم';

  @override
  String support_feedbackIntro(String email) {
    return 'صف مشكلتك أو اقتراحك. اضغط \"إرسال بريد الملاحظات\" لفتح تطبيق البريد. المستلم مُحدَّد مسبقًا إلى $email.';
  }

  @override
  String get support_contactEmailOptional =>
      'البريد الإلكتروني للتواصل (اختياري)';

  @override
  String get support_feedbackContent => 'الملاحظات';

  @override
  String get support_sendFeedbackEmail => 'إرسال بريد الملاحظات';

  @override
  String get support_toastMailOpened =>
      'تم فتح تطبيق البريد؛ أكّد المستلم ثم أرسل';

  @override
  String get support_toastMailUnavailableCopied =>
      'تعذّر فتح تطبيق البريد؛ تم نسخ الملاحظات';

  @override
  String get support_emailSubject => 'ملاحظات مستخدم BarrelLock';

  @override
  String get support_docNotFoundTitle => 'المحتوى غير موجود';

  @override
  String get support_docNotFoundBody =>
      'هذا المستند غير متاح. ارجع وحاول مرة أخرى.';

  @override
  String get support_entryNotSupported => 'هذا الإدخال غير مدعوم';

  @override
  String get support_docSecurityHelp => 'مساعدة الأمان';

  @override
  String get support_docEncryption => 'تفاصيل التشفير';

  @override
  String get support_docTerms => 'شروط الخدمة';

  @override
  String get support_docPrivacy => 'سياسة الخصوصية';

  @override
  String get settings_section_general => 'عام';

  @override
  String get settings_sectionHint_general => 'تفضيلات اللغة والمنطقة.';
}
