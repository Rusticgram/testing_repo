import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rusticgram/Public/app_colors.dart';

class OTPField extends StatelessWidget {
  const OTPField({super.key, required this.controller, required this.focusNode, required this.onChanged, required this.onSubmitted, required this.errorText, this.enabled = true});

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final void Function(String) onSubmitted;
  final String errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PinCodeTextField(
          appContext: context,
          length: 6,
          enabled: enabled,
          enablePinAutofill: true,
          autoDisposeControllers: false,
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          keyboardType: TextInputType.number,
          cursorColor: AppColors.black,
          textStyle: Theme.of(context).textTheme.displaySmall,
          pastedTextStyle: Theme.of(context).textTheme.displaySmall,
          textInputAction: TextInputAction.done,
          pinTheme: PinTheme(
            fieldWidth: width * 0.13,
            fieldHeight: width * 0.13,
            borderWidth: 1.0,
            activeBorderWidth: 1.0,
            inactiveBorderWidth: 1.0,
            disabledBorderWidth: 1.0,
            selectedBorderWidth: 1.0,
            errorBorderWidth: 1.0,
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(10.0),
            activeColor: AppColors.primaryColor,
            disabledColor: AppColors.primaryColor,
            inactiveColor: AppColors.primaryColor,
            selectedColor: AppColors.primaryColor,
            errorBorderColor: AppColors.redColor,
          ),
        ),
        Text(
          errorText,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.redColor),
        ),
      ],
    );
  }
}
