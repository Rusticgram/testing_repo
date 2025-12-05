import 'dart:convert';

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/user_response.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  TextEditingController nameController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  TextEditingController emailController = TextEditingController();
  FocusNode emailFocus = FocusNode();

  final UserResponse _userResponse = UserResponse();

  final AccountCubit accountCubit;

  SignupCubit(this.accountCubit) : super(SignupState.initial());

  Future<void> validatingName() async {
    if (nameController.text.isNotEmpty) {
      emit(state.copyWith(nameError: ""));
    } else {
      emit(state.copyWith(nameError: "Please Enter Your Name"));
    }
  }

  Future<void> validatingEmail() async {
    if (emailController.text.isNotEmpty) {
      if (RegExp(r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+\.([a-zA-Z0-9!#$%&*+/=?^_`{|}~-]+)$').hasMatch(emailController.text.trim())) {
        emit(state.copyWith(emailError: ""));
      } else {
        emit(state.copyWith(emailError: "Please Enter Valid Email ID"));
      }
    } else {
      emit(state.copyWith(emailError: "Please Enter Your Email ID"));
    }
  }

  Future<bool> creatingProfile() async {
    await validatingName();
    await validatingEmail();
    if (state.emailError.isEmpty && state.nameError.isEmpty) {
      emit(state.copyWith(dataState: DataState.loading));
      String source = "Android";
      if (Platform.isIOS) {
        source = "IOS";
      }
      Map<String, dynamic> newUserDetails = {"name": nameController.text.trim(), "mobile": firebaseAuth.currentUser!.phoneNumber, "email": emailController.text.trim(), "source": source};
      try {
        Response response = await _userResponse.newUserResponse(jsonEncode(newUserDetails));
        if (response.data["code"] == "success") {
          Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
          if (result["status"]) {
            await accountCubit.fetchingUserDetails();
            prefs.setString("rustic_phone", phoneNumber);
            await firebaseAnalytics.logSignUp(signUpMethod: "ZOHO CRM API: newUser", parameters: {"mobileNumber": phoneNumber, "fromWhatsApp": "false"});
            emit(state.copyWith(dataState: DataState.loaded, errorMessage: ""));
            return true;
          } else {
            emit(state.copyWith(errorMessage: result["message"] ?? "Something Went Wrong. Please Try Again", dataState: DataState.failure));
          }
        } else {
          emit(state.copyWith(errorMessage: response.data["message"] ?? "Something Went Wrong. Please Try Again", dataState: DataState.failure));
        }

        _resettingStatus();
      } on DioException catch (exception, stack) {
        String error = "Something went wrong. Please try again.";
        if (exception.response != null) {
          error = exception.response!.data["message"] ?? error;
          if (error.contains("DUPLICATE_DATA") && error.contains("Email")) {
            error = "Email associated with another account.";
          }
        }
        await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "_creatingProfile()", error: error, input: phoneNumber);
        emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
        _resettingStatus();
      } catch (exception, stack) {
        await CommonFunction.recordingError(
          exception: Exception(exception),
          stack: stack,
          functionName: "_creatingProfile()",
          error: "Something Went Wrong. Please Try Again",
          input: phoneNumber,
        );
        emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", dataState: DataState.failure));
        _resettingStatus();
      }
    }
    return false;
  }

  void _resettingStatus() => Future.delayed(const Duration(seconds: 2), () => emit(state.copyWith(errorMessage: "", dataState: DataState.loaded)));
}
