import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Model/user_details_model.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/order_response.dart';
import 'package:rusticgram/Response/user_response.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final UserResponse _userResponse = UserResponse();
  final OrderResponse _orderResponse = OrderResponse();

  AccountCubit() : super(AccountState.initial()) {
    _initializingLocalDB();
    if (phoneNumber.isNotEmpty) {
      fetchingUserDetails();
    }
  }

  Future<void> _initializingLocalDB() async {
    await appDatabase.openingImageDB();
    appDatabase.fetchingDB();
  }

  Future<bool> fetchingUserDetails() async {
    try {
      Response response = await _userResponse.userDetailsResponse();
      if (response.data["code"] == "success") {
        Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
        userDetailsModel = UserDetailsModel.fromJson(result);
        Uint8List profileImage = Uint8List.fromList([]);
        if (userDetailsModel.userDetails.profileImage.isNotEmpty) {
          profileImage = base64.decode(userDetailsModel.userDetails.profileImage);
        }
        if (userDetailsModel.status) {
          UserDetails userDetails = userDetailsModel.userDetails;
          emit(
            state.copyWith(
              name: userDetails.name,
              email: userDetails.email,
              mobile: userDetails.phone,
              address: userDetails.address,
              profilePic: profileImage,
              dataState: DataState.loaded,
              errorMessage: "",
            ),
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
      await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "fetchingUserDetails()", error: error, input: phoneNumber);
      emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
      _resettingStatus();
    } catch (exception, stack) {
      await CommonFunction.recordingError(
        exception: Exception(exception),
        stack: stack,
        functionName: "fetchingUserDetails()",
        error: "Something Went Wrong. Please Try Again",
        input: phoneNumber,
      );
      emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", dataState: DataState.failure));
      _resettingStatus();
    }
    return false;
  }

  Future<String> _generateImageDownloadLink(XFile image) async {
    try {
      final storageRef = firebaseStorage.ref("/user/profile_images/");
      final profileRef = storageRef.child("${userDetailsModel.userDetails.id}.png");
      final profileImageRef = storageRef.child("/user/profile_images/${userDetailsModel.userDetails.id}.png");
      assert(profileRef.name == profileImageRef.name);
      assert(profileRef.fullPath != profileImageRef.fullPath);
      await profileRef.putFile(File(image.path));
      String profileImage = await profileRef.getDownloadURL();
      await firebaseAuth.currentUser!.updatePhotoURL(profileImage);
      emit(state.copyWith(dataState: DataState.success));
      return profileImage;
    } on FirebaseException catch (exception) {
      emit(state.copyWith(errorMessage: exception.message ?? "Something went wrong. Please try again.", dataState: DataState.failure));
    }
    return "";
  }

  Future<void> selectingProfilePic() async {
    await Permission.photos.request();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      emit(state.copyWith(dataState: DataState.loading));
      String downloadLink = await _generateImageDownloadLink(image);
      if (downloadLink.isNotEmpty) {
        Map<String, dynamic> picDetails = {"userID": userDetailsModel.userDetails.id, "imageURL": downloadLink};
        try {
          Response response = await _userResponse.updateProfilePicResponse(jsonEncode(picDetails));
          if (response.data["code"] == "success") {
            Map<String, dynamic> output = jsonDecode(response.data["details"]["output"]);
            if (output["status"]) {
              await fetchingUserDetails();
            } else {
              emit(state.copyWith(errorMessage: output["message"] ?? "Something Went Wrong. Please Try Again", dataState: DataState.failure));
              _resettingStatus();
            }
          } else {
            emit(state.copyWith(errorMessage: response.data["message"], dataState: DataState.failure));
            _resettingStatus();
          }
        } on DioException catch (exception, stack) {
          String error = "Something went wrong. Please try again.";
          if (exception.response != null) {
            error = exception.response!.data["message"] ?? error;
          }
          await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "selectingProfilePic()", error: error, input: phoneNumber);
          emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
          _resettingStatus();
        } catch (exception, stack) {
          await CommonFunction.recordingError(
            exception: Exception(exception),
            stack: stack,
            functionName: "selectingProfilePic()",
            error: "Something Went Wrong. Please Try Again",
            input: phoneNumber,
          );
          emit(state.copyWith(errorMessage: "Something went wrong. Please try again", dataState: DataState.failure));
          _resettingStatus();
        }
      } else {
        emit(state.copyWith(errorMessage: "Something went wrong while uploading the image. Please try again shortly or report bug if the issue persists.", dataState: DataState.failure));
        _resettingStatus();
      }
    }
  }

  Future<bool> cancellingSubscription(String subscriptionID) async {
    emit(state.copyWith(orderState: OrderState.loading));
    try {
      Response response = await _orderResponse.cancelSubscriptionResponse(subscriptionID);
      if (response.data["status"]) {
        emit(state.copyWith(orderState: OrderState.loaded));
        await firebaseAnalytics.logEvent(name: "cancel_subscription", parameters: {"subscriptionID": subscriptionID, "mobile": phoneNumber});
        return true;
      }
    } on DioException catch (exception, stack) {
      String error = "Something went wrong. Please try again.";
      if (exception.response != null) {
        error = exception.response!.data["message"] ?? error;
      }
      await CommonFunction.recordingError(
        exception: exception,
        stack: stack,
        functionName: "cancellingSubscription()",
        error: error,
        input: {"mobile": phoneNumber, "subscriptionID": subscriptionID},
      );
      emit(state.copyWith(errorMessage: error, orderState: OrderState.failure));
      _resettingStatus();
    } catch (exception, stack) {
      await CommonFunction.recordingError(
        exception: Exception(exception),
        stack: stack,
        functionName: "cancellingSubscription()",
        error: "Something Went Wrong. Please Try Again",
        input: {"mobile": phoneNumber, "subscriptionID": subscriptionID},
      );
      emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", orderState: OrderState.failure));
      _resettingStatus();
    }
    return false;
  }

  void _resettingStatus() => Future.delayed(const Duration(seconds: 2), () => emit(state.copyWith(errorMessage: "", dataState: DataState.loaded, orderState: OrderState.loaded)));

  void resettingUserData() => emit(state.copyWith(errorMessage: "", dataState: DataState.initial, name: "", email: "", mobile: "", address: UserAddress.fromJson({})));
}
