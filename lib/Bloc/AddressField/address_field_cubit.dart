import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Model/autocomplete_model.dart';
import 'package:rusticgram/Model/place_details_model.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/location_response.dart';
import 'package:rusticgram/Response/user_response.dart';
import 'package:rusticgram/Utility/debouncer.dart';

part 'address_field_state.dart';

class AddressFieldCubit extends Cubit<AddressFieldState> {
  TextEditingController flatController = TextEditingController();
  FocusNode flatFocus = FocusNode();
  TextEditingController areaController = TextEditingController();
  FocusNode areaFocus = FocusNode();
  TextEditingController pincodeController = TextEditingController();
  FocusNode pincodeFocus = FocusNode();
  TextEditingController townController = TextEditingController();
  FocusNode townFocus = FocusNode();
  TextEditingController stateController = TextEditingController();
  FocusNode stateFocus = FocusNode();
  TextEditingController countryController = TextEditingController();
  FocusNode countryFocus = FocusNode();
  TextEditingController landmarkController = TextEditingController();
  FocusNode landmarkFocus = FocusNode();
  static AutocompleteModel autocomplete = AutocompleteModel.fromJson({});
  static List<String> addressList = [];
  String formattedAddress = "";
  final Debounceable<Iterable<String>, TextEditingValue> autocompleteDebounceable = debounce(
    function: (searchText) => autocompleteOptions(searchText),
    fallbackOnCancel: List<String>.empty(),
  );
  final UserResponse _userResponse = UserResponse();
  static final LocationResponse _locationResponse = LocationResponse();

  final AccountCubit accountCubit;
  late final StreamSubscription<AccountState> accountSubscription;

  AddressFieldCubit(this.accountCubit) : super(AddressFieldState.initial()) {
    accountSubscription = accountCubit.stream.listen((AccountState accountState) {
      flatController.text = accountState.address.flat;
      areaController.text = accountState.address.area;
      townController.text = accountState.address.town;
      pincodeController.text = accountState.address.pincode;
      stateController.text = accountState.address.state;
      countryController.text = accountState.address.country;
      landmarkController.text = accountState.address.landmark;
      formattedAddress = accountState.address.formattedAddress;
    });
  }

  static Future<Iterable<String>> autocompleteOptions(TextEditingValue textEditingValue) async {
    String searchText = textEditingValue.text;
    addressList.clear();
    if (searchText.isNotEmpty) {
      Response response = await _locationResponse.autoCompleteResponse(searchText);
      autocomplete = AutocompleteModel.fromJson(response.data);
      for (Suggestion address in autocomplete.suggestions) {
        addressList.add(address.placePrediction.formattedAddress.text);
      }
      return addressList;
    }
    return addressList;
  }

  Future<void> fetchingPlaceDetails(String address) async {
    String placeID = autocomplete.suggestions.where((add) => add.placePrediction.formattedAddress.text == address).first.placePrediction.placeId;
    emit(state.copyWith(addressState: AddressState.loading));
    Response response = await _locationResponse.placeDetailResponse(placeID);
    PlaceDetailsModel locationModel = PlaceDetailsModel.fromJson(response.data);
    List<AddressComponent> addressComponents = locationModel.addressComponents;
    List<String> flatList = [];
    List<String> areaList = [];
    List<String> townList = [];
    for (AddressComponent location in addressComponents) {
      final List<String> types = location.types;
      if (types.contains("subpremise") ||
          types.contains("street_number") ||
          (types.contains("premise") && types.length == 1) ||
          types.contains("establishment") ||
          types.contains("floor") ||
          types.contains("point_of_interest")) {
        flatList.add(location.longText);
      } else if (types.contains("route") ||
          types.contains("sublocality") ||
          types.contains("sublocality_level_1") ||
          types.contains("sublocality_level_2") ||
          types.contains("neighborhood") ||
          types.contains("colloquial_area") ||
          types.contains("postal_town")) {
        areaList.add(location.longText);
      } else if (types.contains("locality") || types.contains("postal_town") || types.contains("administrative_area_level_2") || types.contains("administrative_area_level_3")) {
        townList.add(location.longText);
      } else if (types.contains("administrative_area_level_1")) {
        stateController.text = location.longText;
      } else if (types.contains("country")) {
        countryController.text = location.longText;
      } else if (types.contains("postal_code")) {
        pincodeController.text = location.longText;
      } else if (types.contains("landmark")) {
        landmarkController.text = location.longText;
      }
    }
    flatController.text = flatList.join(", ");
    if (flatController.text.isEmpty) {
      flatController.text = address.split(", ").first;
    }
    areaController.text = areaList.join(", ");
    townController.text = townList.toSet().join(", ");
    emit(state.copyWith(flatMessage: "", areaMessage: "", landmarkMessage: "", townMessage: "", stateMessage: "", countryMessage: "", pincodeMessage: "", addressState: AddressState.loaded));
  }

  Future<bool> updatingAddress() async {
    String flat = flatController.text.trim();
    String area = areaController.text.trim();
    String town = townController.text.trim();
    String pincode = pincodeController.text.trim();
    String addressState = stateController.text.trim();
    String country = countryController.text.trim();
    String landmark = landmarkController.text.trim();
    String flatError = "";
    String areaError = "";
    String townError = "";
    String pincodeError = "";
    String stateError = "";
    String countryError = "";
    String landmarkError = "";

    if (flat.isNotEmpty && area.isNotEmpty && town.isNotEmpty && pincode.isNotEmpty && addressState.isNotEmpty && country.isNotEmpty && landmark.isNotEmpty) {
      String newFormattedAddress = "$flat, $area, $town, $pincode, $addressState, $country, $landmark";
      if (formattedAddress != newFormattedAddress) {
        Map<String, dynamic> newAddress = {
          "address": {"flatNo": flat, "area": area, "town": town, "pincode": pincode, "state": addressState, "country": country, "landmark": landmark},
          "userID": userDetailsModel.userDetails.id,
        };

        emit(
          state.copyWith(
            flatMessage: flatError,
            areaMessage: areaError,
            townMessage: townError,
            pincodeMessage: pincodeError,
            stateMessage: stateError,
            countryMessage: countryError,
            landmarkMessage: landmarkError,
            dataState: DataState.loading,
          ),
        );
        try {
          Response response = await _userResponse.updatingAddressResponse(jsonEncode(newAddress));
          if (response.data["code"] == "success") {
            Map<String, dynamic> result = jsonDecode(response.data["details"]["output"]);
            if (result["status"]) {
              await accountCubit.fetchingUserDetails();
              emit(state.copyWith(dataState: DataState.loaded, errorMessage: ""));
              return true;
            }
          }
          await CommonFunction.recordingError(exception: Exception(""), functionName: "updatingAddress()", error: response.data["message"], input: newAddress);
          emit(state.copyWith(errorMessage: "Updating address failed. Please try again.", dataState: DataState.failure));
          _resettingStatus();
        } on DioException catch (exception, stack) {
          String error = "Something went wrong. Please try again.";
          if (exception.response != null) {
            error = exception.response!.data["message"] ?? error;
          }
          await CommonFunction.recordingError(exception: exception, stack: stack, functionName: "updatingAddress()", error: error, input: newAddress);
          emit(state.copyWith(errorMessage: error, dataState: DataState.failure));
          _resettingStatus();
        } catch (exception, stack) {
          await CommonFunction.recordingError(
            exception: Exception(exception),
            stack: stack,
            functionName: "updatingAddress()",
            error: "Something Went Wrong. Please Try Again",
            input: newAddress,
          );
          emit(state.copyWith(errorMessage: "Something Went Wrong. Please Try Again", dataState: DataState.failure));
          _resettingStatus();
        }
      } else {
        return true;
      }
    } else {
      if (flat.isEmpty) {
        flatError = "Please enter your flat/building no.";
      }
      if (area.isEmpty) {
        areaError = "Please enter your area/street name";
      }
      if (town.isEmpty) {
        townError = "Please enter your town/city";
      }
      if (pincode.isEmpty) {
        pincodeError = "Please enter your area pincode";
      }
      if (addressState.isEmpty) {
        stateError = "Please enter your state";
      }
      if (country.isEmpty) {
        countryError = "Please enter your country";
      }
      if (landmark.isEmpty) {
        landmarkError = "Please enter landmark near you";
      }
      emit(
        state.copyWith(
          flatMessage: flatError,
          areaMessage: areaError,
          townMessage: townError,
          pincodeMessage: pincodeError,
          stateMessage: stateError,
          countryMessage: countryError,
          landmarkMessage: landmarkError,
          dataState: DataState.loaded,
        ),
      );
    }
    return false;
  }

  void _resettingStatus() => Future.delayed(const Duration(seconds: 2), () => emit(state.copyWith(errorMessage: "", dataState: DataState.loaded)));
}
