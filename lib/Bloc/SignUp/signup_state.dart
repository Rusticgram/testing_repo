part of 'signup_cubit.dart';

class SignupState {
  final DataState dataState;
  final String nameError;
  final String emailError;
  final String errorMessage;

  const SignupState({required this.dataState, required this.nameError, required this.emailError, required this.errorMessage});

  factory SignupState.initial() => const SignupState(dataState: DataState.initial, nameError: "", emailError: "", errorMessage: "");

  SignupState copyWith({DataState? dataState, String? nameError, String? emailError, String? errorMessage}) =>
      SignupState(dataState: dataState ?? this.dataState, nameError: nameError ?? this.nameError, emailError: emailError ?? this.emailError, errorMessage: errorMessage ?? this.errorMessage);
}
