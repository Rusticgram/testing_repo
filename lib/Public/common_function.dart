import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class CommonFunction {
  static bool maintainceEnabled = false;
  static bool deletePaymentTestingEnabled = false;
  static bool orderPaymentTestingEnabled = false;
  static bool fromGalleryPage = false;
  static bool forceUpdateEnabled = false;
  static Future<void> logout({required AccountCubit accountCubit, required OrderDetailsCubit orderDetailsCubit}) async {
    phoneNumber = "";
    accountCubit.resettingUserData();
    orderDetailsCubit.resettingOrderData();
    fromGalleryPage = false;
    prefs.clear();
    firebaseAuth.signOut();
  }

  static void openingExternalWebPage(Uri url) => launchUrl(url);

  static Future<void> recordingError({required Exception exception, StackTrace stack = StackTrace.empty, required String functionName, required String error, dynamic input}) async {
    if (!kDebugMode) {
      await firebaseCrashlytics.recordError(
        exception,
        stack,
        reason: error,
        information: [
          {"function": functionName, "input": input},
        ],
      );
    }
  }

  static Future<void> fetchingRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: const Duration(minutes: 1), minimumFetchInterval: const Duration(seconds: 1)));
    await remoteConfig.fetchAndActivate();
    if (Platform.isAndroid) {
      maintainceEnabled = remoteConfig.getBool("android_activate_maintenance");
    } else {
      maintainceEnabled = remoteConfig.getBool("ios_activate_maintenance");
    }
    deletePaymentTestingEnabled = remoteConfig.getBool("enable_delete_payment_testing");
    orderPaymentTestingEnabled = remoteConfig.getBool("enable_order_payment_testing");
    forceUpdateEnabled = remoteConfig.getBool("enable_force_update");
  }
}
