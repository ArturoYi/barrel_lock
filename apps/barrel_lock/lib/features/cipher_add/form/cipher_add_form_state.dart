/// 添加页表单与提交态（按 [cipherType] 分态；子类见同目录各 `*_form_state.dart`）。
abstract base class CipherAddFormState {
  const CipherAddFormState({
    this.isSaving = false,
    this.errorMessage,
    this.validationMessage,
  });

  int get cipherType;

  final bool isSaving;
  final String? errorMessage;
  final String? validationMessage;

  bool get canSave;
}
