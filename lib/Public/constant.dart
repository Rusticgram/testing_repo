import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rusticgram/LocalDB/app_database.dart';
import 'package:rusticgram/Model/user_details_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Local Storage

late SharedPreferences prefs;
final AppDatabase appDatabase = AppDatabase();

// Global Navigation Key
GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

// Firebase Instance

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FirebaseCrashlytics firebaseCrashlytics = FirebaseCrashlytics.instance;
FlutterLocalNotificationsPlugin localNotification = FlutterLocalNotificationsPlugin();

UserDetailsModel userDetailsModel = UserDetailsModel.fromJson({});

String phoneNumber = "";
int initialImageIndex = 0;
