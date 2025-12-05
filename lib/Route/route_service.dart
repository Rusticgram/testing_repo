import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/Authentication/authentication_cubit.dart';
import 'package:rusticgram/Bloc/BugReport/bug_report_cubit.dart';
import 'package:rusticgram/Bloc/ConfirmOrder/confirm_order_cubit.dart';
import 'package:rusticgram/Bloc/ImageViewer/image_viewer_cubit.dart';
import 'package:rusticgram/Bloc/Landing/landing_cubit.dart';
import 'package:rusticgram/Bloc/Maintain/maintain_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Bloc/SignUp/signup_cubit.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Route/page_name.dart';
import 'package:rusticgram/Utility/how_we_work.dart';
import 'package:rusticgram/View/account_view.dart';
import 'package:rusticgram/View/bug_report_view.dart';
import 'package:rusticgram/View/image_viewer_view.dart';
import 'package:rusticgram/View/service_summary_view.dart';
import 'package:rusticgram/View/signup_view.dart';
import 'package:rusticgram/View/gallery_view.dart';
import 'package:rusticgram/View/home_view.dart';
import 'package:rusticgram/View/landing_view.dart';
import 'package:rusticgram/View/schedule_pickup_view.dart';
import 'package:rusticgram/View/login_view.dart';
import 'package:rusticgram/View/maintaince_view.dart';
import 'package:rusticgram/View/order_details_view.dart';

class RouteService {
  static GoRouter routerConfig = GoRouter(
    navigatorKey: navKey,
    initialLocation: PageName.landingScreen,
    routes: [
      GoRoute(
        path: PageName.landingScreen,
        name: PageName.landingScreen,
        builder: (context, state) {
          final AccountCubit accountCubit = context.read<AccountCubit>();
          final OrderDetailsCubit orderDetailsCubit = context.read<OrderDetailsCubit>();
          return BlocProvider(
            create: (context) => LandingCubit(accountCubit: accountCubit, orderDetailsCubit: orderDetailsCubit),
            child: const LandingView(),
          );
        },
      ),
      GoRoute(
        path: PageName.loginScreen,
        name: PageName.loginScreen,
        builder: (context, state) => BlocProvider(create: (context) => AuthenticationCubit(), child: const LoginView()),
      ),
      GoRoute(
        path: PageName.signUpScreen,
        name: PageName.signUpScreen,
        builder: (context, state) => BlocProvider(create: (context) => SignupCubit(BlocProvider.of<AccountCubit>(context)), child: const SignUpView()),
      ),
      GoRoute(path: PageName.homeScreen, name: PageName.homeScreen, builder: (context, state) => const HomeView()),
      GoRoute(path: PageName.howWeWorkScreen, name: PageName.howWeWorkScreen, builder: (context, state) => const HowWeWorkView()),
      GoRoute(path: PageName.accountScreen, name: PageName.accountScreen, builder: (context, state) => const AccountView()),
      GoRoute(
        path: PageName.scheduleOrderScreen,
        name: PageName.scheduleOrderScreen,
        builder: (context, state) => BlocProvider(create: (context) => ConfirmOrderCubit(), child: const ConfirmOrderView()),
      ),
      GoRoute(path: PageName.orderDetailScreen, name: PageName.orderDetailScreen, builder: (context, state) => const OrderDetailsView()),
      GoRoute(path: PageName.gallaryScreen, name: PageName.gallaryScreen, builder: (context, state) => const GalleryView()),
      GoRoute(
        path: PageName.imageViewerScreen,
        name: PageName.imageViewerScreen,
        builder: (context, state) => BlocProvider(create: (context) => ImageViewerCubit(context.read<OrderDetailsCubit>()), child: const ImageViewerView()),
      ),
      GoRoute(path: PageName.serviceSummaryScreen, name: PageName.serviceSummaryScreen, builder: (context, state) => const ServiceSummaryView()),
      GoRoute(
        path: PageName.bugReportScreen,
        name: PageName.bugReportScreen,
        builder: (context, state) => BlocProvider(create: (context) => BugReportCubit(context.read<OrderDetailsCubit>()), child: const BugReportView()),
      ),
      GoRoute(
        path: PageName.maintainceScreen,
        name: PageName.maintainceScreen,
        builder: (context, state) => BlocProvider(create: (context) => MaintainCubit(), child: const MaintainceView()),
      ),
    ],
  );
}
