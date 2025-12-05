part of 'payment_cubit.dart';

class PaymentState {
  final content_state.DataState dataState;
  final content_state.PaymentState paymentState;
  final String planID;
  final int currentPlan;
  final int finalAmount;
  final String errorMessage;
  final String paymentErrorTitle;
  final String paymentErrorMessage;

  const PaymentState({
    required this.dataState,
    required this.paymentState,
    required this.planID,
    required this.currentPlan,
    required this.finalAmount,
    required this.errorMessage,
    required this.paymentErrorTitle,
    required this.paymentErrorMessage,
  });

  factory PaymentState.initial() => const PaymentState(
    dataState: content_state.DataState.initial,
    paymentState: content_state.PaymentState.initial,
    planID: "",
    currentPlan: 0,
    finalAmount: 149900,
    errorMessage: "",
    paymentErrorTitle: "",
    paymentErrorMessage: "",
  );

  PaymentState copyWith({
    content_state.DataState? dataState,
    content_state.PaymentState? paymentState,
    String? planID,
    int? currentPlan,
    int? finalAmount,
    String? errorMessage,
    String? paymentErrorTitle,
    String? paymentErrorMessage,
  }) {
    return PaymentState(
      dataState: dataState ?? this.dataState,
      paymentState: paymentState ?? this.paymentState,
      planID: planID ?? this.planID,
      currentPlan: currentPlan ?? this.currentPlan,
      finalAmount: finalAmount ?? this.finalAmount,
      errorMessage: errorMessage ?? this.errorMessage,
      paymentErrorTitle: paymentErrorTitle ?? this.paymentErrorTitle,
      paymentErrorMessage: paymentErrorMessage ?? this.paymentErrorMessage,
    );
  }
}
