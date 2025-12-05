import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/fcm_response.dart';
import 'package:rusticgram/Route/page_name.dart';
import 'package:rusticgram/Route/route_service.dart';

@pragma('vm:entry-point')
Future<void> foregroundNotification(RemoteMessage message) async {
  String? title = message.notification!.title ?? "";
  String? body = message.notification!.body ?? "";
  String userID = message.data["userID"];
  int notificationId = int.parse(message.data["notification_id"] ?? 0);
  String pageName = message.data["pageName"];

  if (firebaseAuth.currentUser != null && userDetailsModel.userDetails.id == userID) {
    OrderDetailsCubit().fetchingOrderDetails();
    await firebaseMessaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    AndroidNotificationChannel channel = AndroidNotificationChannel("high_importance_channel", userID, importance: Importance.max, playSound: true);

    await localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("@mipmap/notification");

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

    localNotification.initialize(initializationSettings, onDidReceiveBackgroundNotificationResponse: notificationAction, onDidReceiveNotificationResponse: notificationAction);

    localNotification.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.max,
          playSound: channel.playSound,
          color: AppColors.secondaryColor,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: false, presentSound: true, presentBadge: true),
      ),
      payload: pageName,
    );
  }
}

@pragma('vm:entry-point')
void notificationAction(NotificationResponse notificationResponse) {
  String routeName = notificationResponse.payload ?? "";
  switch (routeName) {
    case "gallery":
      RouteService.routerConfig.goNamed(PageName.gallaryScreen);
      break;
    case "order":
      RouteService.routerConfig.goNamed(PageName.orderDetailScreen);
      break;
    default:
      RouteService.routerConfig.goNamed(PageName.homeScreen);
  }
}

Future<void> sendingFcmToken() async {
  String? fcmToken = await firebaseMessaging.getToken();
  if (fcmToken != null) {
    if (userDetailsModel.userDetails.id.isNotEmpty) {
      Map<String, dynamic> fcmDetails = {"userID": userDetailsModel.userDetails.id, "fcm": fcmToken};
      try {
        await FcmResponse().fcmResponse(jsonEncode(fcmDetails));
      } on DioException catch (exception, stack) {
        CommonFunction.recordingError(exception: exception, stack: stack, functionName: "sendingFcmToken()", error: "Sending FCM Notification to CRM failed", input: phoneNumber);
      }
    }
  }
}
