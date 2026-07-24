// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_error => 'Something went wrong';

  @override
  String get common_back => 'Back';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_loading => 'Loading…';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_done => 'Done';

  @override
  String get common_create => 'Create';

  @override
  String get common_add => 'Add';

  @override
  String get common_show => 'Show';

  @override
  String get common_hide => 'Hide';

  @override
  String get common_showPassword => 'Show password';

  @override
  String get common_hidePassword => 'Hide password';

  @override
  String get common_copy => 'Copy';

  @override
  String get common_favorite => 'Favorite';

  @override
  String get common_unfavorite => 'Unfavorite';

  @override
  String get common_notSet => 'Not set';

  @override
  String get common_set => 'Set';

  @override
  String get common_ungrouped => 'Ungrouped';

  @override
  String get common_other => 'Other';

  @override
  String get common_unnamedVault => 'Unnamed vault';

  @override
  String get common_loadingFolders => 'Loading folders…';

  @override
  String get common_newFolderEllipsis => 'New folder…';

  @override
  String common_loadFailed(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get overlay_loading => 'Loading…';

  @override
  String get overlay_success => 'Operation successful';

  @override
  String get overlay_error => 'Operation failed';

  @override
  String get overlay_please_wait => 'Please wait';

  @override
  String get locale_follow_system => 'System';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_follow_system => 'Follow system language';

  @override
  String get settings_language_summary_system => 'Follow system';

  @override
  String get settings_language_summary_zh_hans => '简体中文';

  @override
  String get settings_language_summary_zh_hant => '繁體中文';

  @override
  String get settings_language_summary_en => 'English';

  @override
  String get settings_language_summary_ar => 'العربية';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_section_data => 'Data';

  @override
  String get settings_section_security => 'Security';

  @override
  String get settings_section_support => 'Support';

  @override
  String get settings_section_appearance => 'Appearance';

  @override
  String get settings_section_about => 'About';

  @override
  String get settings_dataMigration => 'Data migration';

  @override
  String get settings_dataMigrationSubtitle =>
      'Export, import, Bluetooth share, backup & restore';

  @override
  String get settings_appLock => 'App lock';

  @override
  String get settings_appLockSubtitle => 'Biometric unlock & fallback PIN';

  @override
  String get settings_clearData => 'Clear all data';

  @override
  String get settings_clearDataSubtitle => 'Deletes all passwords permanently';

  @override
  String get settings_helpDoc => 'Security help';

  @override
  String get settings_feedback => 'Contact support';

  @override
  String get settings_userAgreement => 'Terms of service';

  @override
  String get settings_privacyPolicy => 'Privacy policy';

  @override
  String get settings_encryptionDoc => 'Encryption details';

  @override
  String get settings_themeDisplay => 'Theme & display';

  @override
  String get settings_themeDisplaySubtitle =>
      'Dark mode, accent color, font size';

  @override
  String get settings_versionInfo => 'Version info';

  @override
  String get settings_themeMode => 'Theme mode';

  @override
  String get settings_themeFollowSystem => 'System';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_accentColor => 'Accent color';

  @override
  String get settings_fontSize => 'Font size';

  @override
  String get settings_fontScale_small => 'Small';

  @override
  String get settings_fontScale_standard => 'Standard';

  @override
  String get settings_fontScale_large => 'Large';

  @override
  String get settings_fontScale_extraLarge => 'Extra large';

  @override
  String get settings_colorScheme_deepPurple => 'Purple';

  @override
  String get settings_colorScheme_blue => 'Blue';

  @override
  String get settings_colorScheme_green => 'Green';

  @override
  String get settings_colorScheme_orange => 'Orange';

  @override
  String get settings_colorScheme_teal => 'Teal';

  @override
  String settings_sectionItemCount(int count) {
    return '$count items';
  }

  @override
  String get settings_sectionHint_theme => 'Adjust appearance and readability.';

  @override
  String get settings_sectionHint_data =>
      'Import, export, and backup actions appear here.';

  @override
  String get settings_sectionHint_security =>
      'App lock and destructive actions require confirmation.';

  @override
  String get settings_sectionHint_support =>
      'Help docs and legal document links.';

  @override
  String get settings_sectionHint_about => 'App version and build info.';

  @override
  String get settings_clearData_stepIdle =>
      'This will permanently delete all passwords and cannot be undone.';

  @override
  String get settings_clearData_stepConfirm1 =>
      'Are you sure you want to clear all data?';

  @override
  String get settings_clearData_stepConfirm2 =>
      'Final confirmation: this cannot be undone.';

  @override
  String get settings_clearData_stepClearing => 'Clearing…';

  @override
  String get settings_clearData_stepDone => 'All passwords have been cleared.';

  @override
  String get settings_clearData_start => 'Start clearing';

  @override
  String get settings_clearData_understandRisk =>
      'I understand the risk, continue';

  @override
  String get settings_clearData_confirmDelete => 'Confirm permanent deletion';

  @override
  String get tab_password => 'Passwords';

  @override
  String get tab_settings => 'Settings';

  @override
  String get tab_filterAll => 'All';

  @override
  String get tab_filterFavorites => 'Favorites';

  @override
  String get tab_filterRecent => 'Recent';

  @override
  String get tab_searchHint => 'Search passwords, sites, usernames';

  @override
  String get tab_switchVault => 'Switch vault';

  @override
  String get tab_newVault => 'New vault';

  @override
  String get tab_createVault => 'Create vault';

  @override
  String get tab_createVaultHint => 'e.g. Work, Personal';

  @override
  String get tab_vaultNameLabel => 'Vault name';

  @override
  String get tab_newFolder => 'New folder';

  @override
  String get tab_folderNameLabel => 'Folder name';

  @override
  String get tab_folderNameHint => 'e.g. Social, Bank cards';

  @override
  String get tab_emptyNoVaultTitle => 'No vault yet';

  @override
  String get tab_emptyNoVaultSubtitle =>
      'Create a vault to start managing passwords';

  @override
  String get tab_emptyNoItemsTitle => 'No passwords yet';

  @override
  String get tab_addPassword => 'Add password';

  @override
  String get tab_nameRequired => 'Enter a name';

  @override
  String get error_page_not_found => '404 — Page not found';

  @override
  String get cipher_addTitle => 'Add password';

  @override
  String get cipher_addedToast => 'Added';

  @override
  String get cipher_saveFailed => 'Save failed, try again later';

  @override
  String get cipher_typeWebsiteLogin => 'Website login';

  @override
  String get cipher_typeBankCard => 'Bank card';

  @override
  String get cipher_typeIdentityDocument => 'Identity document';

  @override
  String get cipher_typeSecureNote => 'Secure note';

  @override
  String get cipher_typeAppAccount => 'App account';

  @override
  String get cipher_typeSshKey => 'SSH key';

  @override
  String cipher_formComingSoon(String type) {
    return '$type form coming soon';
  }

  @override
  String get cipher_defaultVaultName => 'My vault';

  @override
  String get cipher_field_name => 'Name';

  @override
  String get cipher_field_username => 'Username';

  @override
  String get cipher_field_password => 'Password';

  @override
  String get cipher_field_website => 'Website';

  @override
  String get cipher_field_notes => 'Notes';

  @override
  String get cipher_field_folder => 'Folder';

  @override
  String get cipher_field_cardholder => 'Cardholder';

  @override
  String get cipher_field_cardNumber => 'Card number';

  @override
  String get cipher_field_expMonth => 'MM';

  @override
  String get cipher_field_expYear => 'YY';

  @override
  String get cipher_field_cardPinOptional => 'PIN (optional)';

  @override
  String get cipher_field_docType => 'Document type';

  @override
  String get cipher_field_fullName => 'Full name';

  @override
  String get cipher_field_docNumber => 'Document number';

  @override
  String get cipher_field_issueDate => 'Issue date';

  @override
  String get cipher_field_expiryDate => 'Expiry date';

  @override
  String get cipher_field_title => 'Title';

  @override
  String get cipher_field_content => 'Content';

  @override
  String get cipher_field_privateKey => 'Private key';

  @override
  String get cipher_field_publicKeyOptional => 'Public key (optional)';

  @override
  String get cipher_field_passphraseOptional => 'Passphrase (optional)';

  @override
  String get cipher_field_host => 'Host';

  @override
  String get cipher_field_account => 'Account';

  @override
  String get cipher_field_bundleIdOptional => 'Package / Bundle ID (optional)';

  @override
  String get cipher_descWebsiteLogin =>
      'Store login credentials for websites and services. Not your app unlock password.';

  @override
  String get cipher_descBankCard =>
      'Store bank card info; list shows last 4 digits only.';

  @override
  String get cipher_descIdentityDocument =>
      'Store ID documents; list shows type and name summary only.';

  @override
  String get cipher_descSecureNote =>
      'Store encrypted notes; list shows title summary.';

  @override
  String get cipher_descSshKey =>
      'Store SSH keys and connection info; list shows host and user summary.';

  @override
  String get cipher_descAppAccount =>
      'Store app login credentials. Not your app unlock password.';

  @override
  String get cipher_validationWebsiteLogin =>
      'Fill in name, username, and password';

  @override
  String get cipher_validationBankCard =>
      'Fill in name, cardholder, number, expiry, and CVV';

  @override
  String get cipher_validationIdentityDocument =>
      'Fill in name, document type, name, and number';

  @override
  String get cipher_validationSecureNote => 'Fill in title and note content';

  @override
  String get cipher_validationSshKey => 'Fill in name and private key';

  @override
  String get cipher_validationAppAccount =>
      'Fill in name, account, and password';

  @override
  String get cipher_validationRequired => 'Complete required fields';

  @override
  String get cipher_attachmentOptional => 'Attachments (optional)';

  @override
  String get cipher_attachmentHint => 'Add photos such as ID front/back';

  @override
  String get cipher_attachmentTakePhoto => 'Take photo';

  @override
  String get cipher_attachmentFromGallery => 'Choose from gallery';

  @override
  String get app_lock_title => 'App protection';

  @override
  String get app_lock_enableTitle => 'Enable app protection';

  @override
  String get app_lock_enableSubtitle =>
      'Verify identity on launch and when returning to foreground';

  @override
  String get app_lock_manageFallbackPin => 'Manage fallback PIN';

  @override
  String get app_lock_fallbackPinTitle => 'Fallback PIN';

  @override
  String get app_lock_enabledToast => 'App protection enabled';

  @override
  String get app_lock_setupPinTitle => 'Set fallback PIN';

  @override
  String get app_lock_setupHintTitle => 'Set hint';

  @override
  String app_lock_enterPinDigits(int length) {
    return 'Enter a $length-digit PIN';
  }

  @override
  String get app_lock_pinLabel => 'PIN';

  @override
  String get app_lock_hintDescription =>
      'Set a hint to help you remember your fallback PIN if you forget it.';

  @override
  String get app_lock_hintLabel => 'Forgot PIN hint';

  @override
  String get app_lock_confirmEnable => 'Confirm & enable';

  @override
  String get app_lock_previousStep => 'Previous';

  @override
  String get app_lock_enableFailed => 'Failed to enable, please try again';

  @override
  String get app_lock_invalidPinFormat => 'Invalid PIN format';

  @override
  String app_lock_error_enterPinDigits(int length) {
    return 'Enter a $length-digit PIN';
  }

  @override
  String get app_lock_error_pinMismatch => 'PINs do not match';

  @override
  String get app_lock_error_enterHint => 'Enter a hint';

  @override
  String app_lock_error_hintTooLong(int max) {
    return 'Hint cannot exceed $max characters';
  }

  @override
  String get app_lock_error_sameAsCurrent =>
      'New PIN cannot be the same as current PIN';

  @override
  String get app_lock_error_enterCurrentPin => 'Enter current PIN';

  @override
  String get app_lock_error_wrongCurrentPin => 'Incorrect current PIN';

  @override
  String get app_lock_authenticating => 'Verifying identity…';

  @override
  String get app_lock_error_wrongPinRetry => 'Incorrect PIN, try again';

  @override
  String get app_lock_error_wrongAppPinRetry => 'Incorrect app PIN, try again';

  @override
  String get app_lock_error_authUnavailable =>
      'Unable to verify identity, try again';

  @override
  String get app_lock_error_enterPin => 'Enter PIN';

  @override
  String get app_lock_biometricUnavailable =>
      'Biometrics unavailable, enter PIN';

  @override
  String get app_lock_biometricFailed => 'Biometrics failed, enter PIN';

  @override
  String get app_lock_inAppPinLabel => 'In-app PIN';

  @override
  String get app_lock_semantic_biometric => 'Biometrics';

  @override
  String get app_lock_semantic_delete => 'Delete';

  @override
  String get app_lock_cannotClearPinReason =>
      'App lock is on with no other unlock method. Disable app lock or enable biometrics first.';

  @override
  String get app_lock_reason_unlockOnResume =>
      'Verify your identity to continue';

  @override
  String get app_lock_reason_confirmSensitive =>
      'Verify your identity to continue';

  @override
  String get app_lock_reason_setupAppPin =>
      'Verify your identity to set app PIN';

  @override
  String get migration_title => 'Data migration';

  @override
  String get migration_intro =>
      'Securely migrate passwords between devices. Exported files are encrypted.';

  @override
  String get migration_exportFile => 'Export to file';

  @override
  String get migration_exportFileSubtitle => 'Encrypt and save locally';

  @override
  String get migration_importFile => 'Import from file';

  @override
  String get migration_importFileSubtitle => 'Merge or replace existing data';

  @override
  String get migration_bluetoothShare => 'Bluetooth share';

  @override
  String get migration_bluetoothShareSubtitle =>
      'Same-OS nearby or cross-platform BLE';

  @override
  String get migration_localBackup => 'Local backup';

  @override
  String get migration_localBackupSubtitle => 'Keep a snapshot in the app';

  @override
  String get migration_restoreBackup => 'Restore backup';

  @override
  String get migration_restoreBackupSubtitle => 'Restore from latest backup';

  @override
  String get migration_toastRestoreDone => 'Restore complete';

  @override
  String get migration_toastRestoreFailed => 'Restore failed';

  @override
  String get migration_toastImportDone => 'Import complete';

  @override
  String get migration_toastImportFailed => 'Import failed';

  @override
  String get migration_toastBackupCreated => 'Local backup created';

  @override
  String get migration_toastBackupFailed => 'Backup failed';

  @override
  String get migration_toastNoLocalBackup => 'No local backups';

  @override
  String get migration_toastExportDone => 'Backup exported';

  @override
  String get migration_toastExportFailed => 'Export failed';

  @override
  String get migration_restoreTitle => 'Restore backup';

  @override
  String get migration_localBackupDefaultNote => 'Local backup';

  @override
  String get migration_modeMerge => 'Merge';

  @override
  String get migration_modeReplace => 'Replace';

  @override
  String get migration_replaceWarning =>
      'Replace deletes all current passwords and cannot be undone.';

  @override
  String get migration_startRestore => 'Start restore';

  @override
  String get migration_importModeTitle => 'Import mode';

  @override
  String get migration_importModeDescription =>
      'Merge keeps local-only items; replace replaces all password data.';

  @override
  String get migration_importMerge => 'Merge import';

  @override
  String get migration_importReplace => 'Replace import';

  @override
  String get migration_importReplaceDanger => 'Replace import (dangerous)';

  @override
  String get migration_importModeHint =>
      'Merge keeps existing data; replace clears first. Choose carefully.';

  @override
  String get migration_btSheetTitle => 'Bluetooth share';

  @override
  String get migration_btSheetDescription =>
      'Transfer encrypted backup. Same OS uses nearby; cross-platform (iOS↔Android) uses BLE. Keep both devices in foreground.';

  @override
  String get migration_btSameOsTitle => 'Same-OS nearby';

  @override
  String get migration_btSameOsSubtitle => 'Android↔Android or iOS↔iOS';

  @override
  String get migration_btSameOsSend => 'Same OS · Send';

  @override
  String get migration_btSameOsReceive => 'Same OS · Receive';

  @override
  String get migration_btCrossPlatformTitle => 'Cross-platform BLE';

  @override
  String get migration_btCrossPlatformSubtitle =>
      'iOS ↔ Android; large backups may take minutes';

  @override
  String get migration_btCrossPlatformSend => 'Cross-platform · Send';

  @override
  String get migration_btCrossPlatformReceive => 'Cross-platform · Receive';

  @override
  String get migration_btCrossPlatformSendTitle => 'Cross-platform send';

  @override
  String get migration_btCrossPlatformReceiveTitle => 'Cross-platform receive';

  @override
  String get migration_btNearbySendTitle => 'Send to nearby device';

  @override
  String get migration_btNearbyReceiveTitle => 'Receive from nearby device';

  @override
  String migration_btConnectingPeer(String name) {
    return 'Connecting to $name…';
  }

  @override
  String migration_btConnectionFailed(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get migration_btCancelled => 'Cancelled';

  @override
  String migration_btTransferFailed(String error) {
    return 'Transfer failed: $error';
  }

  @override
  String migration_btTransferProgress(int percent) {
    return 'Transfer progress $percent%';
  }

  @override
  String migration_btTransferringBle(int percent) {
    return 'Transferring via BLE… $percent%';
  }

  @override
  String migration_btTransferring(int percent) {
    return 'Transferring encrypted backup… $percent%';
  }

  @override
  String get migration_btScanningCrossPlatformReceiver =>
      'Scanning for cross-platform receivers…';

  @override
  String get migration_btWaitingCrossPlatformSender =>
      'Waiting for cross-platform sender…';

  @override
  String get migration_btSearchingNearby => 'Searching for nearby devices…';

  @override
  String get migration_btWaitingSender => 'Waiting for sender…';

  @override
  String get migration_btConnecting => 'Connecting…';

  @override
  String get migration_btCompleted => 'Transfer complete';

  @override
  String get migration_btSendDoneCrossPlatform =>
      'Backup sent to cross-platform device';

  @override
  String get migration_btSendDoneNearby => 'Backup sent to nearby device';

  @override
  String get migration_btSendDoneToast => 'Send complete';

  @override
  String get migration_btReceivedChooseImport =>
      'Backup received. Choose import mode.';

  @override
  String migration_btRemainingTime(String time) {
    return 'Connection time remaining $time';
  }

  @override
  String get migration_btInstructionCrossPlatformReceive =>
      'On the other device, choose \"Cross-platform · Receive\" and stay in foreground';

  @override
  String get migration_btInstructionCrossPlatformSend =>
      'On the other device, choose \"Cross-platform · Send\" and stay in foreground';

  @override
  String get migration_btInstructionSameOsReceive =>
      'On the other device, choose \"Same OS · Receive\"';

  @override
  String get migration_btInstructionSameOsSend =>
      'On the other device, choose \"Same OS · Send\"';

  @override
  String get migration_btUnknownDevice => 'Unknown device';

  @override
  String get support_feedbackTitle => 'Contact support';

  @override
  String support_feedbackIntro(String email) {
    return 'Describe your issue or suggestion. Tap \"Send feedback email\" to open your mail app. Recipient is preset to $email.';
  }

  @override
  String get support_contactEmailOptional => 'Contact email (optional)';

  @override
  String get support_feedbackContent => 'Feedback';

  @override
  String get support_sendFeedbackEmail => 'Send feedback email';

  @override
  String get support_toastMailOpened =>
      'Mail app opened; confirm recipient and send';

  @override
  String get support_toastMailUnavailableCopied =>
      'Cannot open mail app; feedback copied';

  @override
  String get support_emailSubject => 'BarrelLock user feedback';

  @override
  String get support_docNotFoundTitle => 'Content not found';

  @override
  String get support_docNotFoundBody =>
      'This document is not available. Go back and try again.';

  @override
  String get support_entryNotSupported => 'This entry is not supported';

  @override
  String get support_docSecurityHelp => 'Security help';

  @override
  String get support_docEncryption => 'Encryption details';

  @override
  String get support_docTerms => 'Terms of service';

  @override
  String get support_docPrivacy => 'Privacy policy';

  @override
  String get settings_section_general => 'General';

  @override
  String get settings_sectionHint_general =>
      'Language and regional preferences.';
}
