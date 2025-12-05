import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart' as content_state;
import 'package:rusticgram/Model/plan_list_model.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/api.dart';
import 'package:rusticgram/Response/order_response.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final Razorpay _razorpay = Razorpay();
  final String _razorKeyID = API.isStaging ? "rzp_test_t3KVt3skc8SfJj" : "rzp_live_yAKIy2k75TbG3N";
  final String _receiptId = "RG${DateTime.now().millisecondsSinceEpoch.toString()}";
  String _orderId = "";
  String _subscriptionId = "";

  final OrderResponse _orderResponse = OrderResponse();

  final OrderDetailsCubit orderDetailsCubit;
  final AccountCubit accountCubit;
  PaymentCubit({required this.orderDetailsCubit, required this.accountCubit}) : super(PaymentState.initial()) {
    Iterable<PlanDetails> defaultPlan = orderDetailsCubit.state.planList.where((plan) => plan.name == "Life Time");
    if (defaultPlan.isNotEmpty) {
      int defaultIndex = orderDetailsCubit.state.planList.indexOf(defaultPlan.first);
      selectingPlan(currentPlan: defaultIndex, amount: defaultPlan.first.finalAmount, planID: defaultPlan.first.planId);
    } else {
      selectingPlan(currentPlan: 0, amount: orderDetailsCubit.state.planList.first.finalAmount, planID: orderDetailsCubit.state.planList.first.planId);
    }
  }

  void initiateRazorPay() {
    if (state.currentPlan != 100) {
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _creatingOrderID();
    } else {
      emit(state.copyWith(errorMessage: "Choose a plan to make a payment", dataState: content_state.DataState.failure));
      _resettingStatus();
    }
  }

  void selectingPlan({required int currentPlan, required int amount, required String planID}) {
    int finalAmount = amount * 100;
    if (userDetailsModel.userDetails.email.contains("@datadrone.biz") && CommonFunction.orderPaymentTestingEnabled && currentPlan == orderDetailsCubit.state.planList.length - 1) {
      finalAmount = 100;
    }
    emit(state.copyWith(currentPlan: currentPlan, finalAmount: finalAmount, planID: planID));
  }

  Future<void> _creatingOrderID() async {
    emit(state.copyWith(dataState: content_state.DataState.loading));
    Map<String, dynamic> orderDetails = {"amount": "${state.finalAmount}", "receiptID": _receiptId};
    try {
      if (state.currentPlan == (orderDetailsCubit.state.planList.length - 1)) {
        Response response = await _orderResponse.orderIDResponse(orderDetails);
        if (response.statusCode == 200) {
          _orderId = response.data["data"]["id"];
        } else {
          emit(state.copyWith(errorMessage: "Initiating Payment Failed. Please Try Again", dataState: content_state.DataState.failure));
        }
      }
      _triggeringPayment();
    } on DioException catch (exception, stack) {
      String errorMessage = "Something Went Wrong. Please Try Again";
      if (exception.response != null) {
        errorMessage = exception.response!.data["message"] ?? "Something Went Wrong. Please Try Again";
      }
      emit(state.copyWith(errorMessage: errorMessage, dataState: content_state.DataState.failure));
      CommonFunction.recordingError(exception: exception, stack: stack, functionName: "_creatingOrderID()", error: errorMessage, input: orderDetails);
    }
  }

  Future<void> _triggeringPayment() async {
    Map<String, dynamic> paymentOption = {
      "key": _razorKeyID,
      "name": "Rusticgram",
      "description": "Photo digitalize qty: ${orderDetailsCubit.state.orderDetails.noOfPhotos}",
      "retry": {"enabled": true, "max_count": 1},
      "prefill": {"contact": phoneNumber, "email": accountCubit.state.email},
    };
    // If part is for Lifetime payment and the else part is when customer selects recurring payments.
    if (state.currentPlan == (orderDetailsCubit.state.planList.length - 1)) {
      await firebaseAnalytics.logBeginCheckout(currency: "INR", value: (state.finalAmount.toDouble()) / 100, parameters: {"mobileNumber": phoneNumber, "planID": state.planID});
      paymentOption.addAll({"order_id": _orderId});
      emit(state.copyWith(dataState: content_state.DataState.loaded));
      _razorpay.open(paymentOption);
    } else {
      Map<String, dynamic> subscriptionDetails = {"name": accountCubit.state.name, "contact": phoneNumber, "email": accountCubit.state.email, "failExisting": "0", "planID": state.planID};
      try {
        Response response = await _orderResponse.subscriptionResponse(subscriptionDetails);
        if (response.data["status"]) {
          _subscriptionId = response.data["data"]["id"];
          paymentOption.addAll({"subscription_id": _subscriptionId});
          await firebaseAnalytics.logBeginCheckout(
            currency: "INR",
            value: (state.finalAmount.toDouble()) / 100,
            parameters: {"mobileNumber": phoneNumber, "planID": state.planID, "subscriptionID": _subscriptionId},
          );
          emit(state.copyWith(dataState: content_state.DataState.loaded));
          _razorpay.open(paymentOption);
        } else {
          emit(state.copyWith(dataState: content_state.DataState.failure));
          _resettingStatus();
        }
      } on DioException catch (exception, stack) {
        String error = "Something went wrong. Please try again.";
        if (exception.response != null) {
          error = exception.response!.data["message"] ?? error;
        }
        emit(state.copyWith(dataState: content_state.DataState.failure, errorMessage: error));
        CommonFunction.recordingError(exception: exception, stack: stack, functionName: "_triggeringPayment()", error: error, input: subscriptionDetails);
        _resettingStatus();
      }
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _razorpay.clear();
    await firebaseAnalytics.logPurchase(
      currency: "INR",
      value: (state.finalAmount.toDouble()) / 100,
      transactionId: response.paymentId,
      parameters: {"mobileNumber": phoneNumber, "description": "Order payment"},
    );
    emit(state.copyWith(paymentState: content_state.PaymentState.success, paymentErrorMessage: "", paymentErrorTitle: "", dataState: content_state.DataState.loading));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(paymentState: content_state.PaymentState.success, dataState: content_state.DataState.loaded));
    String paymentID = "";
    if (response.paymentId != null) {
      paymentID = response.paymentId!;
    }
    await _updatingPaymentMethod(paymentID);
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    _razorpay.clear();
    String errorTitle = "Payment Failed";
    String errorMessage = "Please check your security code, card details and connection and try again.";
    await firebaseAnalytics.logEvent(name: "payment_failure", parameters: {"mobileNumber": phoneNumber, "description": "Payment failed/cancelled for order"});
    if (response.error != null) {
      if (response.error!["reason"].toString().contains("cancelled")) {
        errorTitle = "Payment Cancelled";
        errorMessage = "";
      }
    }
    emit(state.copyWith(paymentErrorTitle: errorTitle, paymentErrorMessage: errorMessage, paymentState: content_state.PaymentState.failure));
    _resettingStatus();
  }

  Future<void> _updatingPaymentMethod(String paymentID) async {
    String subscriptionType = orderDetailsCubit.state.planList[state.currentPlan].name.replaceAll(" ", "");
    Map<String, dynamic> paymentDetails = {
      "subscriptionType": subscriptionType,
      "amount": "${state.finalAmount / 100}",
      "paymentID": paymentID,
      "orderID": orderDetailsCubit.state.orderDetails.id,
    };
    if (_subscriptionId.isNotEmpty) {
      paymentDetails.addAll({"subscriptionID": _subscriptionId});
    }
    try {
      Response response = await _orderResponse.updatePaymentDetailsResponse(jsonEncode(paymentDetails));
      if (response.data["code"] == "success") {
        Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
        if (result["status"]) {
          await orderDetailsCubit.fetchingOrderDetails();
          emit(state.copyWith(paymentState: content_state.PaymentState.success, dataState: content_state.DataState.success));
        } else {
          emit(state.copyWith(errorMessage: result["message"], dataState: content_state.DataState.failure));
          CommonFunction.recordingError(exception: Exception(), stack: StackTrace.empty, functionName: "_updatingPaymentMethod()", error: result["message"], input: paymentDetails);
          _resettingStatus();
        }
      } else {
        emit(state.copyWith(errorMessage: response.data["message"], dataState: content_state.DataState.failure));
        CommonFunction.recordingError(exception: Exception(), stack: StackTrace.empty, functionName: "_updatingPaymentMethod()", error: response.data["message"], input: paymentDetails);
        _resettingStatus();
      }
    } on DioException catch (exception, stack) {
      String error = "Something went wrong. Please try again.";
      if (exception.response != null) {
        error = exception.response!.data["message"] ?? error;
      }
      emit(state.copyWith(dataState: content_state.DataState.failure, errorMessage: error));
      CommonFunction.recordingError(exception: exception, stack: stack, functionName: "_updatingPaymentMethod()", error: error, input: paymentDetails);
      _resettingStatus();
    }
  }

  void _resettingStatus() =>
      Future.delayed(const Duration(seconds: 1), () => emit(state.copyWith(errorMessage: "", paymentState: content_state.PaymentState.loaded, dataState: content_state.DataState.loaded)));
}
