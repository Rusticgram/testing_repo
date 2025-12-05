part of 'delete_account_cubit.dart';

class DeleteAccountState {
  final double finalAmount;
  final DataState dataState;
  final PaymentState paymentState;
  final String reasonError;
  final String errorMessage;
  final String paymentErrorTitle;
  final String paymentErrorMessage;

  const DeleteAccountState({
    required this.finalAmount,
    required this.dataState,
    required this.paymentState,
    required this.reasonError,
    required this.errorMessage,
    required this.paymentErrorTitle,
    required this.paymentErrorMessage,
  });

  factory DeleteAccountState.initial() => DeleteAccountState(
    finalAmount: 199900,
    dataState: DataState.initial,
    paymentState: PaymentState.initial,
    reasonError: "",
    errorMessage: "",
    paymentErrorTitle: "",
    paymentErrorMessage: "",
  );

  DeleteAccountState copyWith({
    double? finalAmount,
    DataState? dataState,
    PaymentState? paymentState,
    String? reasonError,
    String? errorMessage,
    String? paymentErrorTitle,
    String? paymentErrorMessage,
  }) => DeleteAccountState(
    finalAmount: finalAmount ?? this.finalAmount,
    dataState: dataState ?? this.dataState,
    paymentState: paymentState ?? this.paymentState,
    reasonError: reasonError ?? this.reasonError,
    errorMessage: errorMessage ?? this.errorMessage,
    paymentErrorTitle: paymentErrorTitle ?? this.paymentErrorTitle,
    paymentErrorMessage: paymentErrorMessage ?? this.paymentErrorMessage,
  );
}
