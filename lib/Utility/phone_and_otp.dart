import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rusticgram/Bloc/Authentication/authentication_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Utility/otp_field.dart';
import 'package:rusticgram/Utility/phone_number_field.dart';

class PhoneAndOtp extends StatelessWidget {
  const PhoneAndOtp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, state) {
        return Column(
          children: [
            PhoneNumberField(
              autoFocus: true,
              controller: BlocProvider.of<AuthenticationCubit>(context).phoneNumberController,
              focusNode: BlocProvider.of<AuthenticationCubit>(context).phoneNumberFocus,
              enabled: state.dataState != DataState.loading,
              onChanged: (phoneNumber) {
                BlocProvider.of<AuthenticationCubit>(context).phoneNumber = phoneNumber;
                BlocProvider.of<AuthenticationCubit>(context).disableOTPField();
              },
              onSubmitted: (phoneNumber) => BlocProvider.of<AuthenticationCubit>(context).validatingPhoneNumber(),
              errorText: state.phoneError,
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(
                state.phoneError,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.redColor),
              ),
            ),
            const SizedBox(height: 30.0),
            _otpField(context, state: state),
          ],
        );
      },
    );
  }

  Widget _otpField(BuildContext context, {required AuthenticationState state}) => _fadeAnimation(
    firstChild: Column(
      children: [
        OTPField(
          controller: BlocProvider.of<AuthenticationCubit>(context).otpController,
          focusNode: BlocProvider.of<AuthenticationCubit>(context).otpFocus,
          onChanged: (otp) {},
          onSubmitted: (otp) {},
          errorText: state.otpError,
          enabled: state.dataState != DataState.loading,
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "\nDidn’t Receive Code? ", style: Theme.of(context).textTheme.displayMedium),
              TextSpan(
                recognizer: TapGestureRecognizer()..onTap = () => BlocProvider.of<AuthenticationCubit>(context).timer(),
                text: "Resend Code\n",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: state.enableResend ? AppColors.primaryColor : AppColors.dividerColor,
                  decoration: TextDecoration.underline,
                  decorationColor: state.enableResend ? AppColors.primaryColor : AppColors.dividerColor,
                ),
              ),
              TextSpan(text: "\nResend code in ", style: Theme.of(context).textTheme.displayMedium),
              TextSpan(text: state.otpTimer, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
      ],
    ),
    secondChild: const SizedBox.shrink(),
    fadeStatus: state.showOTP,
  );

  Widget _fadeAnimation({required Widget firstChild, required Widget secondChild, required bool fadeStatus}) =>
      AnimatedSwitcher(duration: const Duration(seconds: 1), child: fadeStatus ? firstChild : secondChild);
}
