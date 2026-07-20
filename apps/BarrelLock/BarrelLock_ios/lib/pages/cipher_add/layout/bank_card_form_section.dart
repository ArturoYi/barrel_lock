import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import '../../settings/widgets/settings_section_card.dart';
import '../widgets/cipher_add_form_fields.dart';

/// 银行卡（type=2）表单字段区。
final class BankCardFormSection extends StatefulWidget {
  const BankCardFormSection({
    super.key,
    required this.state,
    required this.onTitleChanged,
    required this.onCardholderNameChanged,
    required this.onCardNumberChanged,
    required this.onExpiryMonthChanged,
    required this.onExpiryYearChanged,
    required this.onCvvChanged,
    required this.onPinChanged,
    required this.onNotesChanged,
    required this.onSave,
  });

  final BankCardFormState state;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onCardholderNameChanged;
  final ValueChanged<String> onCardNumberChanged;
  final ValueChanged<String> onExpiryMonthChanged;
  final ValueChanged<String> onExpiryYearChanged;
  final ValueChanged<String> onCvvChanged;
  final ValueChanged<String> onPinChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSave;

  @override
  State<BankCardFormSection> createState() => _BankCardFormSectionState();
}

final class _BankCardFormSectionState extends State<BankCardFormSection> {
  late final TextEditingController _titleController;
  late final TextEditingController _cardholderController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryMonthController;
  late final TextEditingController _expiryYearController;
  late final TextEditingController _cvvController;
  late final TextEditingController _pinController;
  late final TextEditingController _notesController;
  var _obscureCardNumber = true;
  var _obscureCvv = true;
  var _obscurePin = true;

  @override
  void initState() {
    super.initState();
    final s = widget.state;
    _titleController = TextEditingController(text: s.title);
    _cardholderController = TextEditingController(text: s.cardholderName);
    _cardNumberController = TextEditingController(text: s.cardNumber);
    _expiryMonthController = TextEditingController(text: s.expiryMonth);
    _expiryYearController = TextEditingController(text: s.expiryYear);
    _cvvController = TextEditingController(text: s.cvv);
    _pinController = TextEditingController(text: s.pin);
    _notesController = TextEditingController(text: s.notes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    _pinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = widget.state.isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '保存银行卡信息；列表仅展示卡号后四位。',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SettingsSectionCard(
          children: [
            CipherAddField(
              label: '名称',
              controller: _titleController,
              enabled: !isSaving,
              onChanged: widget.onTitleChanged,
            ),
            CipherAddField(
              label: '持卡人',
              controller: _cardholderController,
              enabled: !isSaving,
              onChanged: widget.onCardholderNameChanged,
            ),
            CipherAddObscureField(
              label: '卡号',
              controller: _cardNumberController,
              enabled: !isSaving,
              obscure: _obscureCardNumber,
              keyboardType: TextInputType.number,
              onChanged: widget.onCardNumberChanged,
              onToggleObscure: () =>
                  setState(() => _obscureCardNumber = !_obscureCardNumber),
            ),
            Row(
              children: [
                Expanded(
                  child: CipherAddField(
                    label: '月 MM',
                    controller: _expiryMonthController,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    onChanged: widget.onExpiryMonthChanged,
                  ),
                ),
                Expanded(
                  child: CipherAddField(
                    label: '年 YY',
                    controller: _expiryYearController,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    onChanged: widget.onExpiryYearChanged,
                  ),
                ),
              ],
            ),
            CipherAddObscureField(
              label: 'CVV',
              controller: _cvvController,
              enabled: !isSaving,
              obscure: _obscureCvv,
              keyboardType: TextInputType.number,
              onChanged: widget.onCvvChanged,
              onToggleObscure: () => setState(() => _obscureCvv = !_obscureCvv),
            ),
            CipherAddObscureField(
              label: 'PIN（可选）',
              controller: _pinController,
              enabled: !isSaving,
              obscure: _obscurePin,
              keyboardType: TextInputType.number,
              onChanged: widget.onPinChanged,
              onToggleObscure: () => setState(() => _obscurePin = !_obscurePin),
            ),
            CipherAddField(
              label: '备注',
              controller: _notesController,
              enabled: !isSaving,
              maxLines: 3,
              onChanged: widget.onNotesChanged,
              onSubmitted: isSaving ? null : (_) => widget.onSave(),
            ),
          ],
        ),
      ],
    );
  }
}
