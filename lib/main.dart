import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/AddressField/address_field_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Bloc/ScheduleDate/schedule_date_cubit.dart';
import 'package:rusticgram/Config/app_theme.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/api.dart';
import 'package:rusticgram/Route/route_service.dart';
import 'package:rusticgram/firebase_initialization.dart';
import 'package:rusticgram/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(const AppInitialization());
}

Future<void> _initializeApp() async {
  prefs = await SharedPreferences.getInstance();
  phoneNumber = prefs.getString("rustic_phone") ?? "";
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FlutterBranchSdk.init(enableLogging: true, branchAttributionLevel: BranchAttributionLevel.FULL);

  if (kDebugMode || API.isStaging) {
    firebaseAuth.setSettings(appVerificationDisabledForTesting: false);
    firebaseAnalytics.setAnalyticsCollectionEnabled(false);
  }
  FlutterError.onError = (errorDetails) => firebaseCrashlytics.recordFlutterFatalError(errorDetails);
  PlatformDispatcher.instance.onError = (error, stack) {
    firebaseCrashlytics.recordError(error, stack, fatal: false);
    return true;
  };
  FirebaseMessaging.onBackgroundMessage(foregroundNotification);
  FirebaseMessaging.onMessage.listen(foregroundNotification);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class AppInitialization extends StatelessWidget {
  const AppInitialization({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AccountCubit()),
        BlocProvider(create: (context) => OrderDetailsCubit()),
        BlocProvider(lazy: false, create: (context) => AddressFieldCubit(BlocProvider.of<AccountCubit>(context))),
        BlocProvider(create: (context) => ScheduleDateCubit(context.read<OrderDetailsCubit>())),
      ],
      child: MaterialApp.router(
        title: "Rusticgram",
        theme: AppTheme.lightTheme(context),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        routerConfig: RouteService.routerConfig,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(boldText: false, textScaler: TextScaler.noScaling),
          child: child!,
        ),
      ),
    );
  }
}
