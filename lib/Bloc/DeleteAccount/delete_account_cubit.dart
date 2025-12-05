import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/api.dart';
import 'package:rusticgram/Response/order_response.dart';
import 'package:rusticgram/Response/user_response.dart';

part 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final Razorpay _razorpay = Razorpay();
  final String _razorKeyID = API.isStaging ? "rzp_test_t3KVt3skc8SfJj" : "rzp_live_yAKIy2k75TbG3N";
  final String _receiptId = "RG${DateTime.now().millisecondsSinceEpoch.toString()}";
  String _orderId = "";
  TextEditingController deleteReason = TextEditingController();
  FocusNode deleteNode = FocusNode();
  final OrderResponse _orderResponse = OrderResponse();
  final UserResponse _userResponse = UserResponse();

  final AccountCubit accountCubit;
  DeleteAccountCubit(this.accountCubit) : super(DeleteAccountState.initial());

  void initiateRazorPay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _creatingOrderID();
  }

  Future<void> _creatingOrderID() async {
    emit(state.copyWith(dataState: DataState.loading));
    String amount = "199900";
    if (accountCubit.state.email.contains("@datadrone.biz") && CommonFunction.deletePaymentTestingEnabled) {
      amount = "100";
    }
    Map<String, dynamic> orderDetails = {"amount": amount, "receiptID": _receiptId};
    try {
      Response response = await _orderResponse.orderIDResponse(orderDetails);
      if (response.statusCode == 200) {
        _orderId = response.data["data"]["id"];
        emit(state.copyWith(finalAmount: double.parse(amount)));
        _triggeringPayment();
      } else {
        emit(state.copyWith(errorMessage: "Initiating Payment Failed. Please Try Again", dataState: DataState.failure));
      }
    } on DioException catch (exception, stack) {
      String errorMessage = "Something Went Wrong. Please Try Again";
      if (exception.response != null) {
        errorMessage = exception.response!.data["message"] ?? "Something Went Wrong. Please Try Again";
      }
      emit(state.copyWith(errorMessage: errorMessage, dataState: DataState.failure));
      CommonFunction.recordingError(exception: exception, stack: stack, functionName: "_creatingOrderID()", error: errorMessage, input: orderDetails);
    }
  }

  Future<void> _triggeringPayment() async {
    Map<String, dynamic> paymentOption = {
      "key": _razorKeyID,
      "name": "Rusticgram",
      "order_id": _orderId,
      "description": "Permanent Account Deletion",
      "retry": {"enabled": true, "max_count": 1},
      "prefill": {"contact": phoneNumber, "email": accountCubit.state.email},
    };
    emit(state.copyWith(dataState: DataState.loaded));
    await firebaseAnalytics.logBeginCheckout(currency: "INR", value: state.finalAmount / 100, parameters: {"mobileNumber": phoneNumber});
    _razorpay.open(paymentOption);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _razorpay.clear();
    emit(state.copyWith(paymentState: PaymentState.success, paymentErrorMessage: "", paymentErrorTitle: ""));
    await firebaseAnalytics.logPurchase(
      currency: "INR",
      value: state.finalAmount / 100,
      transactionId: response.paymentId,
      parameters: {"mobileNumber": phoneNumber, "description": "Permanent Account Deletion"},
    );
    deletingAccount("delete");
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    _razorpay.clear();
    String errorTitle = "Payment Failed";
    String errorMessage = "Please check your security code, card details and connection and try again.";
    if (response.error != null) {
      if (response.error!["reason"].toString().contains("cancelled")) {
        errorTitle = "Payment Cancelled";
        errorMessage = "";
      }
    }
    emit(state.copyWith(paymentErrorTitle: errorTitle, paymentErrorMessage: errorMessage, paymentState: PaymentState.failure));
    await firebaseAnalytics.logEvent(name: "payment_failure", parameters: {"mobileNumber": phoneNumber, "description": "Payment failed/cancelled for account deletion"});
    _resettingStatus();
  }

  Future<void> validatingExpliantion() async {
    String explinationError = "";
    if (deleteReason.text.isNotEmpty) {
      explinationError = "";
    } else {
      explinationError = "Please tell us the reason for deletion";
    }
    emit(state.copyWith(reasonError: explinationError));
  }

  Future<bool> requestDeletion() async {
    validatingExpliantion();
    if (state.reasonError.isEmpty) {
      try {
        emit(state.copyWith(dataState: DataState.loading));
        Map<String, String> requestDetails = {"userID": userDetailsModel.userDetails.id, "deleteReason": deleteReason.text.trim()};
        Response response = await _userResponse.deleteRequest(jsonEncode(requestDetails));
        Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
        if (result["status"]) {
          await firebaseAnalytics.logEvent(name: "delete_account_request", parameters: {"mobileNumber": phoneNumber, "deleteReason": deleteReason.text.trim()});
          emit(state.copyWith(dataState: DataState.loaded));
          return true;
        } else {
          emit(state.copyWith(errorMessage: "Something went wrong. Please try again.", dataState: DataState.failure));
          _resettingStatus();
        }
      } on DioException catch (exception, stack) {
        String error = "Something went wrong. Please try again.";
        if (exception.response != null) {
          error = exception.response!.data["message"] ?? error;
        }
        await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "requestDeletion()", error: error, input: phoneNumber);
        emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
        _resettingStatus();
      }
    }
    return false;
  }

  Future<bool> deletingAccount(String type) async {
    emit(state.copyWith(dataState: DataState.loading));
    try {
      Map<String, String> deleteData = {"userID": userDetailsModel.userDetails.id, "type": type};
      Response response = await _userResponse.deleteProfileResponse(jsonEncode(deleteData));
      if (response.data["code"] == "success") {
        Map<String, dynamic> output = jsonDecode(response.data["details"]["output"]);
        if (output["status"]) {
          emit(state.copyWith(errorMessage: "", dataState: DataState.success));
          return true;
        }
        emit(state.copyWith(errorMessage: "", dataState: DataState.success));
      }
    } on DioException catch (exception, stack) {
      String error = "Something went wrong. Please try again.";
      if (exception.response != null) {
        error = exception.response!.data["message"] ?? error;
      }
      await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "deletingAccount()", error: error, input: phoneNumber);
      emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
      _resettingStatus();
    } catch (exception, stack) {
      await CommonFunction.recordingError(
        exception: Exception(exception),
        stack: stack,
        functionName: "deletingAccount()",
        error: "Something Went Wrong. Please Try Again",
        input: phoneNumber,
      );
      emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", dataState: DataState.failure));
      _resettingStatus();
    }
    return false;
  }

  void _resettingStatus() => Future.delayed(const Duration(seconds: 2), () => emit(state.copyWith(errorMessage: "", dataState: DataState.loaded, paymentState: PaymentState.loaded)));
}
