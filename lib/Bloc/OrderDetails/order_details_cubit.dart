import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Model/order_details_model.dart';
import 'package:rusticgram/Model/plan_list_model.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/order_response.dart';

part 'order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController cancelReasonController = TextEditingController();
  final FocusNode cancelFocusNode = FocusNode();
  final TextEditingController feedbackController = TextEditingController();
  final FocusNode feedbackFocusNode = FocusNode();
  final OrderResponse _orderResponse = OrderResponse();
  OrderDetailsCubit() : super(OrderDetailsState.initial()) {
    if (userDetailsModel.userDetails.id.isNotEmpty) {
      fetchingOrderDetails();
    }
  }

  void resettingCancelReason() {
    cancelReasonController.clear();
    emit(state.copyWith(cancelError: "", selectedReason: -1));
  }

  void validatingCancelError() {
    String cancelError = "";
    if (cancelReasonController.text.isNotEmpty) {
      cancelError = "";
    } else {
      cancelError = "Please enter your cancel reason";
    }
    emit(state.copyWith(cancelError: cancelError));
  }

  Future<void> validatingFeedbackError() async {
    String feedbackError = "";
    if (feedbackController.text.isNotEmpty) {
      feedbackError = "";
    } else {
      feedbackError = "Please enter your feedback";
    }
    emit(state.copyWith(feedbackError: feedbackError));
  }

  Future<bool> updatingFeedback() async {
    if (feedbackFocusNode.hasFocus) {
      feedbackFocusNode.unfocus();
    }
    await validatingFeedbackError();
    if (state.feedbackError.isEmpty) {
      emit(state.copyWith(dataState: DataState.loading));
      Map<String, dynamic> feedbackDetails = {"dealID": state.orderDetails.id, "feedback": feedbackController.text.trim()};
      try {
        Response response = await _orderResponse.feedbackResponse(jsonEncode(feedbackDetails));
        if (response.data["code"] == "success") {
          Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
          if (result["status"]) {
            await fetchingOrderDetails();
            emit(state.copyWith(dataState: DataState.loaded, errorMessage: ""));
            return true;
          }
        }
        emit(state.copyWith(errorMessage: response.data["message"] ?? "Something Went Wrong. Please Try Again", dataState: DataState.failure));
        _resettingStatus();
      } on DioException catch (exception, stack) {
        String error = "Something went wrong. Please try again.";
        if (exception.response != null) {
          error = exception.response!.data["message"] ?? error;
        }
        await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "updatingFeedback()", error: error, input: feedbackDetails);
        emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
        _resettingStatus();
      } catch (exception, stack) {
        await CommonFunction.recordingError(
          exception: Exception(exception),
          stack: stack,
          functionName: "updatingFeedback()",
          error: "Something Went Wrong. Please Try Again",
          input: feedbackDetails,
        );
        emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", dataState: DataState.failure));
        _resettingStatus();
      }
    }
    return false;
  }

  Future<bool> fetchingOrderDetails({bool orderState = false}) async {
    if (orderState) {
      emit(state.copyWith(orderState: OrderState.loading));
    }
    try {
      Response response = await _orderResponse.orderDetailsResponse();
      if (response.data["code"] == "success") {
        Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
        OrderDetailsModel orderDetailsModel = OrderDetailsModel.fromJson(result);
        if (orderDetailsModel.status && orderDetailsModel.orderDetails.id.isNotEmpty) {
          if (orderDetailsModel.orderDetails.orderStatusCode >= 3 && orderDetailsModel.orderDetails.orderStatusCode != 6) {
            fetchingPlanList();
          }
          List<bool> activeSteps = List<bool>.generate(6, (index) => index == 0);
          if (orderDetailsModel.orderDetails.orderStatusCode == 1) {
            activeSteps = List<bool>.generate(6, (index) => index <= 1);
          } else if (orderDetailsModel.orderDetails.orderStatusCode == 2) {
            activeSteps = List<bool>.generate(6, (index) => index <= 2);
          } else if (orderDetailsModel.orderDetails.orderStatusCode == 3) {
            await firebaseAnalytics.logEvent(
              name: "scanning_completed",
              parameters: {
                "mobileNumber": phoneNumber,
                "orderID": orderDetailsModel.orderDetails.id,
                "orderName": orderDetailsModel.orderDetails.dealName,
                "orderCreated": orderDetailsModel.orderDetails.createdDate,
              },
            );
            activeSteps = List<bool>.generate(6, (index) => index <= 3);
          } else if (orderDetailsModel.orderDetails.orderStatusCode == 4) {
            activeSteps = List<bool>.generate(6, (index) => index <= 4);
          } else if (orderDetailsModel.orderDetails.orderStatusCode == 5) {
            activeSteps = List<bool>.generate(6, (index) => index <= 5);
          }
          emit(state.copyWith(orderDetails: orderDetailsModel.orderDetails, activeSteps: activeSteps, errorMessage: "", orderState: OrderState.loaded, dataState: DataState.loaded));
          return true;
        }
      }
      emit(state.copyWith(errorMessage: response.data["message"] ?? "Something Went Wrong. Please Try Again", orderState: OrderState.loaded, dataState: DataState.failure));
      _resettingStatus();
    } on DioException catch (exception, stack) {
      String error = "Something went wrong. Please try again.";
      await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "fetchingOrderDetails()", error: error, input: phoneNumber);
      emit(state.copyWith(errorMessage: error, orderState: OrderState.loaded, dataState: DataState.failure));
      _resettingStatus();
    } catch (exception, stack) {
      await CommonFunction.recordingError(
        exception: Exception(exception),
        stack: stack,
        functionName: "fetchingOrderDetails()",
        error: "Something Went Wrong. Please Try Again",
        input: phoneNumber,
      );
      emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", orderState: OrderState.loaded, dataState: DataState.failure));
      _resettingStatus();
    }
    return false;
  }

  Future<void> fetchingPlanList() async {
    Response response = await _orderResponse.planListResponse();
    if (response.data["code"] == "success") {
      Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
      PlanListModel planListModel = PlanListModel.fromJson(result);
      if (planListModel.status) {
        List<PlanDetails> planList = planListModel.data;
        if (planList.isNotEmpty) {
          planList.removeWhere((plan) => plan.name == "Account Delete");
          planList.removeWhere((plan) => (!userDetailsModel.userDetails.email.contains("@datadrone.biz") || !CommonFunction.orderPaymentTestingEnabled) && plan.name == "Weekly");
          planList.sort((a, b) => a.actualAmount.compareTo(b.actualAmount));
          emit(state.copyWith(planList: planList));
        }
      }
    }
  }

  void selectingCancelReason(int? value) => emit(state.copyWith(selectedReason: value, cancelError: ""));

  Future<bool> cancellingOrder() async {
    if (state.cancelError.isEmpty) {
      try {
        String cancelReason;
        if (state.selectedReason == (state.cancelReasons.length - 1)) {
          cancelReason = cancelReasonController.text.trim();
        } else {
          cancelReason = state.cancelReasons[state.selectedReason];
        }
        emit(state.copyWith(dataState: DataState.loading));
        Map<String, dynamic> cancelOrderDetails = {"dealID": state.orderDetails.id, "cancelReason": cancelReason};
        Response response = await _orderResponse.orderCancelResponse(jsonEncode(cancelOrderDetails));
        if (response.data["code"] == "success") {
          Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
          if (result["status"]) {
            await firebaseAnalytics.logEvent(name: "order_cancelled", parameters: {"mobileNumber": phoneNumber, "cancelReason": cancelReason});
            emit(state.copyWith(orderDetails: OrderDetails.fromJson({}), dataState: DataState.loaded));
            return true;
          }
        }
        emit(state.copyWith(dataState: DataState.loaded));
      } on DioException catch (exception, stack) {
        await fetchingOrderDetails();
        String error = "Something went wrong. Please try again.";
        if (exception.response != null) {
          error = exception.response!.data["message"] ?? error;
        }
        await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "cancellingOrder()", error: error, input: phoneNumber);
        emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
        _resettingStatus();
      } catch (exception, stack) {
        await fetchingOrderDetails();
        await CommonFunction.recordingError(
          exception: Exception(exception),
          stack: stack,
          functionName: "cancellingOrder()",
          error: "Something Went Wrong. Please Try Again",
          input: phoneNumber,
        );
        emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", dataState: DataState.failure));
        _resettingStatus();
      }
    }
    return false;
  }

  String invoiceName(String name, String mobile) {
    String invoiceName;
    mobile = mobile.substring(9, 13);
    invoiceName = "Invoice #${name[0]}${name[1]}-${mobile[0]}${mobile[1]}-${mobile[2]}${mobile[3]}";
    return invoiceName;
  }

  void _resettingStatus() => Future.delayed(const Duration(seconds: 2), () => emit(state.copyWith(errorMessage: "", dataState: DataState.loaded)));

  void resettingOrderData() => emit(state.copyWith(errorMessage: "", dataState: DataState.initial, orderDetails: OrderDetails.fromJson({})));
}
