import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/AddressField/address_field_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Bloc/ScheduleDate/schedule_date_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/order_response.dart';

part 'confirm_order_state.dart';

class ConfirmOrderCubit extends Cubit<ConfirmOrderState> {
  final List<String> photoCount = ["100 - 200", "200 - 500", "500 - 1000", "More than 1000"];
  final TextEditingController totalPhotoCountController = TextEditingController();
  final FocusNode totalPhotoCountNode = FocusNode();
  final OrderResponse _orderResponse = OrderResponse();
  ConfirmOrderCubit() : super(ConfirmOrderState.initial());

  void selectingOption(int? value) => emit(state.copyWith(selectedOption: value));

  void selectingCount(String? option) => emit(state.copyWith(selectedCount: option));

  void validatingPhotoCount() {
    String photoCount = totalPhotoCountController.text.trim();
    String error = "";

    if (photoCount.isNotEmpty) {
      if (int.parse(photoCount) < 100) {
        error = "Minimum photo count is 100";
      } else {
        error = "";
      }
    } else {
      error = "Please enter your total photo count.";
    }
    emit(state.copyWith(photoCountError: error));
  }

  Future<bool> validating({
    required AccountCubit accountCubit,
    required AddressFieldCubit addressFieldCubit,
    required OrderDetailsCubit orderDetailsCubit,
    required ScheduleDateCubit scheduleCubit,
  }) async {
    if (state.selectedOption == 0) {
      validatingPhotoCount();
      if (state.photoCountError.isEmpty) {
        return await newOrder(
          accountCubit: accountCubit,
          addressFieldCubit: addressFieldCubit,
          orderDetailsCubit: orderDetailsCubit,
          scheduleCubit: scheduleCubit,
          photoCount: totalPhotoCountController.text.trim(),
        );
      }
    } else {
      return await newOrder(
        accountCubit: accountCubit,
        addressFieldCubit: addressFieldCubit,
        orderDetailsCubit: orderDetailsCubit,
        scheduleCubit: scheduleCubit,
        photoCount: state.selectedCount,
      );
    }
    return false;
  }

  Future<bool> newOrder({
    required AccountCubit accountCubit,
    required AddressFieldCubit addressFieldCubit,
    required OrderDetailsCubit orderDetailsCubit,
    required ScheduleDateCubit scheduleCubit,
    required String photoCount,
  }) async {
    emit(state.copyWith(dataState: DataState.loading));
    bool isUpdated = await addressFieldCubit.updatingAddress();
    if (isUpdated) {
      Map<String, dynamic> address = accountCubit.state.address.toJson();
      address.removeWhere((key, value) => key == "formattedAddress");
      String source = "Android";
      if (Platform.isIOS) {
        source = "IOS";
      }
      Map<String, dynamic> orderDetails = {
        "userID": userDetailsModel.userDetails.id,
        "address": address,
        "fromDate": scheduleCubit.state.scheduleDate.start.toIso8601String(),
        "toDate": scheduleCubit.state.scheduleDate.end.toIso8601String(),
        "source": source,
        "photoCount": photoCount,
      };
      try {
        Response response = await _orderResponse.newOrderResponse(jsonEncode(orderDetails));
        if (response.data["code"] == "success") {
          Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
          if (result["status"]) {
            await orderDetailsCubit.fetchingOrderDetails();
            emit(state.copyWith(dataState: DataState.success, errorMessage: ""));
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
        await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "newOrder()", error: error, input: orderDetails);
        emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
        _resettingStatus();
      } catch (exception, stack) {
        await CommonFunction.recordingError(exception: Exception(exception), stack: stack, functionName: "newOrder()", error: "Something Went Wrong. Please Try Again", input: orderDetails);
        emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", dataState: DataState.failure));
        _resettingStatus();
      }
    } else {
      emit(state.copyWith(dataState: DataState.loaded));
    }
    return false;
  }

  void _resettingStatus() => Future.delayed(const Duration(seconds: 2), () => emit(state.copyWith(errorMessage: "", dataState: DataState.loaded)));
}
