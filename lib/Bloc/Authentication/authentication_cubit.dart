import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart' as public;
import 'package:rusticgram/firebase_initialization.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  PhoneNumber phoneNumber = PhoneNumber.fromCompleteNumber(completeNumber: "");
  TextEditingController phoneNumberController = TextEditingController();
  FocusNode phoneNumberFocus = FocusNode();
  TextEditingController otpController = TextEditingController();
  FocusNode otpFocus = FocusNode();

  DateTime duration = DateTime(DateTime.now().year, 1, 1, 0, 0, 59, 0, 0);
  Timer _timer = Timer(const Duration(), () {});
  String verifyID = "";

  AuthenticationCubit() : super(AuthenticationState.initial());

  void disableOTPField() {
    otpController.clear();
    if (_timer.isActive) {
      _timer.cancel();
      duration = DateTime(DateTime.now().year, 1, 1, 0, 0, 59, 0, 0);
      _timer = Timer(const Duration(), () {});
    }
    emit(state.copyWith(showOTP: false, phoneError: "", otpError: "", otpTimer: "00:59", enableResend: true, dataState: DataState.loaded));
  }

  Future<void> validatingPhoneNumber() async {
    if (phoneNumberFocus.hasFocus) {
      phoneNumberFocus.unfocus();
    }
    if (phoneNumber.number.isNotEmpty) {
      bool numberValidator = false;
      try {
        numberValidator = phoneNumber.isValidNumber();
      } on NumberTooLongException catch (exception, stack) {
        numberValidator = false;
        await CommonFunction.recordingError(
          exception: exception,
          stack: stack,
          functionName: "validatingPhoneNumber()",
          error: "Phone number validation failed.",
          input: phoneNumberController.text,
        );
      } on NumberTooShortException catch (exception, stack) {
        numberValidator = false;
        await CommonFunction.recordingError(
          exception: exception,
          stack: stack,
          functionName: "validatingPhoneNumber()",
          error: "Phone number validation failed.",
          input: phoneNumberController.text,
        );
      }
      if (numberValidator) {
        emit(state.copyWith(dataState: DataState.loading));
        public.phoneNumber = phoneNumber.completeNumber;
        emit(state.copyWith(phoneError: "", showOTP: true, enableResend: true, dataState: DataState.loaded));
        if (!_timer.isActive) {
          await timer();
        }
        if (!otpFocus.hasFocus) {
          otpFocus.requestFocus();
        }
      } else {
        emit(state.copyWith(phoneError: "Please Enter Valid Mobile Number", showOTP: false, dataState: DataState.loaded));
      }
    } else {
      emit(state.copyWith(phoneError: "Please Enter Your Mobile Number", showOTP: false, dataState: DataState.loaded));
    }
  }

  Future<void> timer() async {
    if (state.enableResend) {
      if (!_timer.isActive) {
        emit(state.copyWith(enableResend: false));
      }
      await sendingOTP();
      duration = DateTime(DateTime.now().year, 1, 1, 0, 0, 59, 0, 0);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timer.tick > 59 && state.dataState != DataState.success) {
          emit(state.copyWith(otpTimer: "00:59", enableResend: true));
          timer.cancel();
        } else if (_timer.isActive) {
          duration = duration.subtract(const Duration(seconds: 1));
          String tick = "${duration.second}".padLeft(2, "0");
          emit(state.copyWith(otpTimer: "00:$tick", enableResend: false, errorMessage: state.errorMessage));
        }
      });
    }
  }

  Future<void> sendingOTP() async {
    try {
      await public.firebaseAuth.verifyPhoneNumber(
        phoneNumber: public.phoneNumber,
        verificationCompleted: (phoneAuth) async => phoneAuth = phoneAuth,
        verificationFailed: (exception) {},
        codeSent: (code, id) {
          verifyID = code;
        },
        timeout: const Duration(minutes: 1),
        codeAutoRetrievalTimeout: (expTime) {},
      );
    } on FirebaseAuthException catch (exception, stack) {
      await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "sendingOTP()", error: "Failed to send OTP. Please Try Again", input: phoneNumberController.text);
      emit(state.copyWith(phoneError: "Failed to send OTP. Please try again.", dataState: DataState.loaded));
    }
  }

  Future<bool> verifyOTP({required AccountCubit accountCubit, required OrderDetailsCubit orderDetailsCubit}) async {
    if (otpController.text.isNotEmpty && otpController.text.length == 6) {
      try {
        emit(state.copyWith(dataState: DataState.loading));
        PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verifyID, smsCode: otpController.text);
        await public.firebaseAuth.signInWithCredential(phoneAuthCredential);
        await accountCubit.fetchingUserDetails();
        bool isNewUser = accountCubit.state.name.isEmpty;
        bool profileStatus = public.userDetailsModel.userDetails.profileStatus;
        if (!isNewUser && profileStatus) {
          await orderDetailsCubit.fetchingOrderDetails();
          public.prefs.setString("rustic_phone", phoneNumber.completeNumber);
        }
        await sendingFcmToken();
        await public.firebaseCrashlytics.setUserIdentifier(public.phoneNumber);
        await public.firebaseAnalytics.setUserId(id: public.phoneNumber);
        await public.firebaseAnalytics.logLogin(parameters: {"user_phone": phoneNumber.completeNumber});
        emit(state.copyWith(isNewUser: isNewUser, profileStatus: profileStatus, otpError: "", phoneError: "", dataState: DataState.loaded));
        return true;
      } on FirebaseAuthException catch (exception, stack) {
        String errorMessage;
        if (exception.code == "credential-already-in-use") {
          errorMessage = "Phone Number Associated with another Account";
        } else if (exception.code == "invalid-verification-code") {
          errorMessage = "Please enter valid OTP";
        } else if (exception.code == "channel-error") {
          errorMessage = "We couldn’t verify the OTP. Please try again.";
        } else if (exception.code == "session-expired") {
          errorMessage = "OTP Expired. Please try again.";
        } else {
          errorMessage = "Something went wrong. Please try again.";
        }
        emit(state.copyWith(otpError: errorMessage, dataState: DataState.loaded));
        await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "verifyOTP()", error: errorMessage, input: phoneNumber.completeNumber);
      }
    } else if (otpController.text.isEmpty) {
      emit(state.copyWith(otpError: "Please enter OTP", dataState: DataState.loaded));
    } else {
      emit(state.copyWith(otpError: "Please enter valid OTP", dataState: DataState.loaded));
    }
    return false;
  }

  @override
  Future<void> close() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    return super.close();
  }
}
