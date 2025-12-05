part of 'authentication_cubit.dart';

class AuthenticationState {
  final DataState dataState;
  final bool isNewUser;
  final String phoneNumber;
  final bool profileStatus;
  final String phoneError;
  final String otpError;
  final bool showOTP;
  final String otpTimer;
  final bool enableResend;
  final String errorMessage;

  const AuthenticationState({
    required this.dataState,
    required this.isNewUser,
    required this.phoneNumber,
    required this.profileStatus,
    required this.phoneError,
    required this.otpError,
    required this.showOTP,
    required this.otpTimer,
    required this.enableResend,
    required this.errorMessage,
  });

  factory AuthenticationState.initial() => AuthenticationState(
    dataState: DataState.initial,
    isNewUser: false,
    phoneNumber: public.firebaseAuth.currentUser?.phoneNumber ?? "",
    profileStatus: true,
    phoneError: "",
    otpError: "",
    showOTP: false,
    otpTimer: "00:59",
    enableResend: false,
    errorMessage: "",
  );

  AuthenticationState copyWith({
    DataState? dataState,
    bool? isNewUser,
    String? phoneNumber,
    String? email,
    bool? profileStatus,
    String? phoneError,
    String? otpError,
    bool? showOTP,
    String? otpTimer,
    bool? enableResend,
    String? errorMessage,
  }) {
    return AuthenticationState(
      dataState: dataState ?? this.dataState,
      isNewUser: isNewUser ?? this.isNewUser,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileStatus: profileStatus ?? this.profileStatus,
      phoneError: phoneError ?? this.phoneError,
      otpError: otpError ?? this.otpError,
      showOTP: showOTP ?? this.showOTP,
      otpTimer: otpTimer ?? this.otpTimer,
      enableResend: enableResend ?? this.enableResend,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
