import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:rusticgram/Public/app_colors.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.errorText,
    this.autoFocus = false,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(PhoneNumber) onChanged;
  final void Function(String) onSubmitted;
  final String errorText;
  final bool autoFocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) => IntlPhoneField(
    controller: controller,
    focusNode: focusNode,
    autofocus: autoFocus,
    enabled: enabled,
    cursorColor: AppColors.black,
    initialCountryCode: "IN",
    flagsButtonPadding: const EdgeInsets.only(top: 3.0),
    style: Theme.of(context).textTheme.displaySmall,
    keyboardType: TextInputType.phone,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    textInputAction: TextInputAction.done,
    textAlignVertical: TextAlignVertical.center,
    autovalidateMode: AutovalidateMode.disabled,
    decoration: InputDecoration(labelText: "Phone Number", counterText: ""),
    dropdownTextStyle: Theme.of(context).textTheme.displaySmall,
    pickerDialogStyle: PickerDialogStyle(
      backgroundColor: AppColors.fill1Color,
      countryCodeStyle: Theme.of(context).textTheme.displaySmall,
      countryNameStyle: Theme.of(context).textTheme.displaySmall,
    ),
  );
}
