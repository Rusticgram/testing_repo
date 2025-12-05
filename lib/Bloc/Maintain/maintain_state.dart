// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'maintain_cubit.dart';

class MaintainState {
  final DataState dataState;

  const MaintainState({required this.dataState});

  factory MaintainState.initial() => const MaintainState(dataState: DataState.initial);

  MaintainState copyWith({DataState? dataState}) {
    return MaintainState(dataState: dataState ?? this.dataState);
  }
}
