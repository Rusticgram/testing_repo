import 'package:bloc/bloc.dart';
import 'package:rusticgram/Config/content_state.dart';

part 'maintain_state.dart';

class MaintainCubit extends Cubit<MaintainState> {
  MaintainCubit() : super(MaintainState.initial());
}
