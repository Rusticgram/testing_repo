import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';

part 'landing_state.dart';

class LandingCubit extends Cubit<LandingState> {
  final AccountCubit accountCubit;
  final OrderDetailsCubit orderDetailsCubit;
  final Connectivity _connectivity = Connectivity();

  LandingCubit({required this.accountCubit, required this.orderDetailsCubit}) : super(LandingState.initial()) {
    _connectivity.onConnectivityChanged.listen((connectionStatus) => emit(state.copyWith(connectionStatus: !connectionStatus.contains(ConnectivityResult.none))));
    if (state.connectionStatus) {
      initializing();
    }
  }

  Future<void> initializing() async {
    _requestingPermission();
    await firebaseAnalytics.logAppOpen();
    Future.delayed(const Duration(seconds: 4), () async {
      if (firebaseAuth.currentUser != null && phoneNumber.isNotEmpty && state.connectionStatus) {
        await CommonFunction.fetchingRemoteConfig();
        bool userExist = await accountCubit.fetchingUserDetails();
        final bool profileStatus = userDetailsModel.userDetails.profileStatus;
        if (profileStatus && userExist) {
          await orderDetailsCubit.fetchingOrderDetails();
          await firebaseCrashlytics.setUserIdentifier(phoneNumber);
          await firebaseAnalytics.setUserId(id: phoneNumber);
          emit(state.copyWith(dataState: DataState.loaded));
        } else {
          emit(state.copyWith(dataState: DataState.loaded, isVideoCompleted: true, profileStatus: profileStatus));
        }
      } else {
        emit(state.copyWith(dataState: DataState.loaded, isVideoCompleted: true));
      }
    });
  }

  Future<void> _requestingPermission() async => await Permission.notification.request();
}
