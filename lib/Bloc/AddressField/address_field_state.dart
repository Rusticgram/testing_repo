part of 'address_field_cubit.dart';

class AddressFieldState {
  final DataState dataState;
  final AddressState addressState;
  final String flatMessage;
  final String areaMessage;
  final String pincodeMessage;
  final String townMessage;
  final String stateMessage;
  final String countryMessage;
  final String landmarkMessage;
  final String errorMessage;

  const AddressFieldState({
    required this.dataState,
    required this.addressState,
    required this.flatMessage,
    required this.areaMessage,
    required this.pincodeMessage,
    required this.townMessage,
    required this.stateMessage,
    required this.countryMessage,
    required this.landmarkMessage,
    required this.errorMessage,
  });

  factory AddressFieldState.initial() => const AddressFieldState(
    dataState: DataState.initial,
    addressState: AddressState.loaded,
    flatMessage: "",
    areaMessage: "",
    pincodeMessage: "",
    townMessage: "",
    stateMessage: "",
    countryMessage: "",
    landmarkMessage: "",
    errorMessage: "",
  );

  AddressFieldState copyWith({
    DataState? dataState,
    AddressState? addressState,
    String? flatMessage,
    String? areaMessage,
    String? pincodeMessage,
    String? townMessage,
    String? stateMessage,
    String? countryMessage,
    String? landmarkMessage,
    String? errorMessage,
  }) {
    return AddressFieldState(
      dataState: dataState ?? this.dataState,
      addressState: addressState ?? this.addressState,
      flatMessage: flatMessage ?? this.flatMessage,
      areaMessage: areaMessage ?? this.areaMessage,
      pincodeMessage: pincodeMessage ?? this.pincodeMessage,
      townMessage: townMessage ?? this.townMessage,
      stateMessage: stateMessage ?? this.stateMessage,
      countryMessage: countryMessage ?? this.countryMessage,
      landmarkMessage: landmarkMessage ?? this.landmarkMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
