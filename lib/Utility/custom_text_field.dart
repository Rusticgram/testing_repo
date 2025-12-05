import 'package:flutter/material.dart';
import 'package:rusticgram/Public/app_colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    required this.textInputType,
    this.labelText,
    this.hintText,
    required this.errorText,
    this.maxLength,
    this.maxLines,
    this.readOnly = false,
    this.textCapitalization = TextCapitalization.none,
    this.onTap,
    this.suffixIcon,
    this.isFilled = true,
    this.isRequired = true,
    this.textInputAction,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String)? onChanged;
  final TextInputType textInputType;
  final String? labelText;
  final String? hintText;
  final String errorText;
  final int? maxLength;
  final int? maxLines;
  final bool readOnly;
  final TextCapitalization textCapitalization;
  final void Function()? onTap;
  final Widget? suffixIcon;
  final bool isFilled;
  final bool isRequired;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    focusNode: focusNode,
    cursorColor: AppColors.primaryColor,
    style: Theme.of(context).textTheme.displaySmall,
    keyboardType: textInputType,
    onTap: onTap,
    onChanged: onChanged,
    maxLines: maxLines,
    maxLength: maxLength,
    readOnly: readOnly,
    textCapitalization: textCapitalization,
    onTapOutside: (event) => focusNode.unfocus(),
    textInputAction: textInputAction,
    decoration: InputDecoration(
      filled: isFilled,
      fillColor: AppColors.fillColor,
      label: labelText != null ? _labelText(context, isRequired: isRequired) : null,
      hintText: hintText,
      errorText: errorText.isEmpty ? null : errorText,
      counterText: "",
      suffixIcon: suffixIcon,
    ),
  );

  Widget _labelText(BuildContext context, {required bool isRequired}) => Text.rich(
    TextSpan(
      children: [TextSpan(text: labelText, style: Theme.of(context).textTheme.displayMedium), if (isRequired) const TextSpan(text: " *", style: TextStyle(color: AppColors.redColor))],
    ),
  );
}
