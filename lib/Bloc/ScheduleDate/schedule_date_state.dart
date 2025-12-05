part of 'schedule_date_cubit.dart';

class ScheduleDateState {
  final DataState dataState;
  final DateTimeRange scheduleDate;
  final String selectedTime;
  final String errorMessage;

  const ScheduleDateState({required this.dataState, required this.scheduleDate, required this.selectedTime, required this.errorMessage});

  factory ScheduleDateState.initial() => ScheduleDateState(
    dataState: DataState.initial,
    scheduleDate: DateTimeRange(
      start: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day, 09).add(const Duration(days: 1)),
      end: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13).add(const Duration(days: 1)),
    ),
    selectedTime: "09:00 - 13:00",
    errorMessage: "",
  );

  ScheduleDateState copyWith({DataState? dataState, DateTimeRange? scheduleDate, String? selectedTime, String? errorMessage}) => ScheduleDateState(
    dataState: dataState ?? this.dataState,
    scheduleDate: scheduleDate ?? this.scheduleDate,
    selectedTime: selectedTime ?? this.selectedTime,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
