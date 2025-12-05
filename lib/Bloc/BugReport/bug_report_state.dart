part of 'bug_report_cubit.dart';

class BugReportState {
  final DataState dataState;
  final String brand;
  final String model;
  final String version;
  final List<XFile> screenshots;
  final String commentError;
  final String errorMessage;

  const BugReportState({
    required this.dataState,
    required this.brand,
    required this.model,
    required this.version,
    required this.screenshots,
    required this.commentError,
    required this.errorMessage,
  });

  factory BugReportState.initial() => BugReportState(dataState: DataState.initial, brand: "", model: "", version: "", screenshots: [], commentError: "", errorMessage: "");

  BugReportState copyWith({DataState? dataState, String? brand, String? model, String? version, List<XFile>? screenshots, String? commentError, String? errorMessage}) => BugReportState(
    dataState: dataState ?? this.dataState,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    version: version ?? this.version,
    screenshots: screenshots ?? this.screenshots,
    commentError: commentError ?? this.commentError,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
