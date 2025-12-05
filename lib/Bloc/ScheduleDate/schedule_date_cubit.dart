import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Model/order_details_model.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/order_response.dart';

part 'schedule_date_state.dart';

class ScheduleDateCubit extends Cubit<ScheduleDateState> {
  List scheduleTimeList = ["09:00 - 13:00", "13:00 - 17:00", "17:00 - 21:00"];
  final OrderResponse _orderResponse = OrderResponse();

  final OrderDetailsCubit orderDetailsCubit;
  late final StreamSubscription<OrderDetailsState> orderSubscription;

  ScheduleDateCubit(this.orderDetailsCubit) : super(ScheduleDateState.initial()) {
    initializingDateAndTime(orderDetailsCubit.state);
    assigningListiner();
  }

  void assigningListiner() {
    orderSubscription = orderDetailsCubit.stream.listen(initializingDateAndTime);
  }

  void initializingDateAndTime(OrderDetailsState state) {
    if (state.orderDetails.orderStatusCode == 0) {
      if (state.orderDetails.pickupDateTime.isNotEmpty && state.orderDetails.pickupEndTime.isNotEmpty) {
        selectingTime(
          time: state.orderDetails.pickupDateTime,
          date: DateTimeRange(start: DateTime.parse(state.orderDetails.pickupDateTime), end: DateTime.parse(state.orderDetails.pickupEndTime)),
        );
      }
    } else if (state.orderDetails.orderStatusCode == 4) {
      selectingTime(
        time: state.orderDetails.deliveryDateTime,
        date: DateTimeRange(start: DateTime.parse(state.orderDetails.deliveryDateTime), end: DateTime.parse(state.orderDetails.deliveryEndTime)),
      );
    } else {
      DateTime currentDate = DateTime.now().add(const Duration(days: 1));
      selectingTime(
        time: "${DateTime(currentDate.year, currentDate.month, currentDate.day, 09)}",
        date: DateTimeRange(start: DateTime(currentDate.year, currentDate.month, currentDate.day, 09), end: DateTime.utc(currentDate.year, currentDate.month, currentDate.day, 13)),
      );
    }
  }

  void selectingDate({required DateTime date, required bool isDateFormated}) {
    date = DateTime(date.year, date.month, date.day, DateTime.now().hour, DateTime.now().minute);
    DateTimeRange selectedDateRange = DateTimeRange(start: DateTime(date.year, date.month, date.day), end: DateTime(date.year, date.month, date.day));
    String time = "";
    if (isDateFormated) {
      String tempTime = state.selectedTime.split("-").first.split(":").first.trim();
      DateTime tempDate = DateTime(date.year, date.month, date.day, int.parse(tempTime));
      time = "$tempDate";
    }
    selectingTime(time: time, date: selectedDateRange);
  }

  void selectingTime({required String time, required DateTimeRange date}) {
    DateTimeRange timeRange;
    DateTime dateTime = DateTime.parse(time);
    if (dateTime.hour == 09) {
      timeRange = DateTimeRange(start: DateTime.utc(date.start.year, date.start.month, date.start.day, 09), end: DateTime.utc(date.end.year, date.end.month, date.end.day, 13));
    } else if (dateTime.hour == 13) {
      timeRange = DateTimeRange(start: DateTime.utc(date.start.year, date.start.month, date.start.day, 13), end: DateTime.utc(date.end.year, date.end.month, date.end.day, 17));
    } else {
      timeRange = DateTimeRange(start: DateTime.utc(date.start.year, date.start.month, date.start.day, 17), end: DateTime.utc(date.end.year, date.end.month, date.end.day, 21));
    }
    String selectedTime = "${DateFormat("HH:mm").format(timeRange.start)} - ${DateFormat("HH:mm").format(timeRange.end)}";
    emit(state.copyWith(scheduleDate: timeRange, selectedTime: selectedTime));
  }

  Future<bool> schedulingOrder({required String scheduleType, required OrderDetails orderDetails, required AccountCubit accountCubit}) async {
    emit(state.copyWith(dataState: DataState.loading));
    Map<String, dynamic> scheduleDetails = {
      "fromDate": state.scheduleDate.start.toIso8601String(),
      "toDate": state.scheduleDate.end.toIso8601String(),
      "type": scheduleType,
      "dealID": orderDetails.id,
    };
    try {
      Response response = await _orderResponse.scheduleOrderResponse(jsonEncode(scheduleDetails));
      if (response.data["code"] == "success") {
        Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
        if (result["status"]) {
          await orderDetailsCubit.fetchingOrderDetails();
          emit(state.copyWith(dataState: DataState.loaded, errorMessage: ""));
          await firebaseAnalytics.logEvent(
            name: scheduleType == "new"
                ? "pickup_reschedule"
                : scheduleType == "delivery"
                ? "delivery"
                : "delivery_reschedule",
            parameters: {
              "fromDate": state.scheduleDate.start.toIso8601String(),
              "toDate": state.scheduleDate.end.toIso8601String(),
              "type": scheduleType,
              "orderID": orderDetails.id,
              "address": accountCubit.state.address.formattedAddress,
              "mobileNumber": phoneNumber,
            },
          );
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
      await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "schedulingOrder()", error: error, input: scheduleDetails);
      emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
      _resettingStatus();
    } catch (exception, stack) {
      await CommonFunction.recordingError(
        exception: Exception(exception),
        stack: stack,
        functionName: "schedulingOrder()",
        error: "Something Went Wrong. Please Try Again",
        input: scheduleDetails,
      );
      emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", dataState: DataState.failure));
      _resettingStatus();
    }
    return false;
  }

  void _resettingStatus() => Future.delayed(const Duration(seconds: 2), () => emit(state.copyWith(errorMessage: "", dataState: DataState.loaded)));
}
