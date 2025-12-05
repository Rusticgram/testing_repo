part of 'landing_cubit.dart';

class LandingState {
  final DataState dataState;
  final bool isVideoCompleted;
  final bool connectionStatus;
  final bool profileStatus;

  const LandingState({required this.dataState, required this.isVideoCompleted, required this.connectionStatus, required this.profileStatus});

  factory LandingState.initial() => const LandingState(dataState: DataState.initial, isVideoCompleted: false, connectionStatus: true, profileStatus: true);

  LandingState copyWith({DataState? dataState, bool? isVideoCompleted, bool? connectionStatus, bool? profileStatus}) => LandingState(
    dataState: dataState ?? this.dataState,
    isVideoCompleted: isVideoCompleted ?? this.isVideoCompleted,
    connectionStatus: connectionStatus ?? this.connectionStatus,
    profileStatus: profileStatus ?? this.profileStatus,
  );
}
