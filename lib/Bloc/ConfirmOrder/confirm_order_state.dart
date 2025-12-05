part of 'confirm_order_cubit.dart';

class ConfirmOrderState {
  final int selectedOption;
  final String selectedCount;
  final String photoCountError;
  final DataState dataState;
  final String errorMessage;

  const ConfirmOrderState({required this.selectedOption, required this.selectedCount, required this.photoCountError, required this.dataState, required this.errorMessage});

  factory ConfirmOrderState.initial() => const ConfirmOrderState(selectedOption: 0, selectedCount: "100 - 200", photoCountError: "", dataState: DataState.initial, errorMessage: "");

  ConfirmOrderState copyWith({int? selectedOption, String? selectedCount, String? photoCountError, DataState? dataState, String? errorMessage}) => ConfirmOrderState(
    selectedOption: selectedOption ?? this.selectedOption,
    selectedCount: selectedCount ?? this.selectedCount,
    photoCountError: photoCountError ?? this.photoCountError,
    dataState: dataState ?? this.dataState,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
