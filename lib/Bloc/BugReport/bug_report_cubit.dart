import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/user_response.dart';

part 'bug_report_state.dart';

class BugReportCubit extends Cubit<BugReportState> {
  final TextEditingController bugExplinationController = TextEditingController();
  final FocusNode bugExplinationNode = FocusNode();

  final UserResponse _userResponse = UserResponse();

  final OrderDetailsCubit orderDetailsCubit;

  BugReportCubit(this.orderDetailsCubit) : super(BugReportState.initial()) {
    fetchingDeviceDetails();
  }

  Future<void> validatingExpliantion() async {
    String explinationError = "";
    if (bugExplinationController.text.isNotEmpty) {
      explinationError = "";
    } else {
      explinationError = "Please explaing the bug you encountered";
    }
    emit(state.copyWith(commentError: explinationError));
  }

  Future<void> fetchingDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String brand = "";
    String model = "";
    String platformVersion = "";
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      brand = androidInfo.brand.replaceFirst(androidInfo.brand[0], androidInfo.brand[0].toUpperCase());
      model = androidInfo.model;
      platformVersion = "Android ${androidInfo.version.release}";
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      brand = iosInfo.model;
      model = iosInfo.modelName;
      platformVersion = "IOS ${iosInfo.systemVersion}";
    }
    emit(state.copyWith(brand: brand, model: model, version: platformVersion));
  }

  Future<void> uploadingScreenshots() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      emit(state.copyWith(screenshots: images));
    }
  }

  void removeScreenshot(int index) {
    List<XFile> images = state.screenshots;
    images.removeAt(index);
    emit(state.copyWith(screenshots: images));
  }

  Future<bool> submittingBug() async {
    await validatingExpliantion();
    if (state.commentError.isEmpty) {
      if (bugExplinationNode.hasFocus) {
        bugExplinationNode.unfocus();
      }
      emit(state.copyWith(dataState: DataState.loading));

      Map<String, dynamic> bugDetails = {
        "userID": userDetailsModel.userDetails.id,
        "brand": state.brand,
        "model": state.model,
        "osVersion": state.version,
        "appVersion": "6.0.1",
        "description": bugExplinationController.text.trim(),
        "mobile": phoneNumber,
        "type": "mobile",
      };
      try {
        Response response = await _userResponse.bugReportResponse(jsonEncode(bugDetails));
        if (response.data["code"] == "success") {
          Map<String, dynamic> output = jsonDecode(response.data["details"]["output"]);
          if (output["status"]) {
            await orderDetailsCubit.fetchingOrderDetails();
            bugExplinationController.clear();
            emit(state.copyWith(dataState: DataState.loaded, errorMessage: ""));
            return true;
          }
          emit(state.copyWith(errorMessage: output["message"] ?? "Something Went Wrong. Please Try Again", dataState: DataState.failure));
          _resettingStatus();
        } else {
          emit(state.copyWith(errorMessage: response.data["message"] ?? "Something Went Wrong. Please Try Again", dataState: DataState.failure));
          _resettingStatus();
        }
      } on DioException catch (exception, stack) {
        String error = "Something went wrong. Please try again.";
        if (exception.response != null) {
          error = exception.response!.data["message"] ?? error;
        }
        await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "submittingBug()", error: error, input: bugDetails);
        emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
        _resettingStatus();
      } catch (exception, stack) {
        await CommonFunction.recordingError(
          exception: Exception(exception),
          stack: stack,
          functionName: "submittingBug()",
          error: "Something Went Wrong. Please Try Again",
          input: bugDetails,
        );
        emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", dataState: DataState.failure));
        _resettingStatus();
      }
    }
    return false;
  }

  void _resettingStatus() => Future.delayed(const Duration(seconds: 2), () => emit(state.copyWith(errorMessage: "", dataState: DataState.loaded)));
}
