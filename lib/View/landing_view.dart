import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/Landing/landing_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Response/api.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';
import 'package:rusticgram/Utility/custom_upgrader.dart';
import 'package:upgrader/upgrader.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return BlocConsumer<LandingCubit, LandingState>(
      listener: (context, state) {
        if (state.dataState == DataState.loaded && !state.isVideoCompleted) {
          RouteManager(context).dynamicLinkNavigation(orderDetailsCubit: context.read<OrderDetailsCubit>(), accountCubit: context.read<AccountCubit>());
        }
        if (!state.profileStatus) {
          CommonFunction.logout(accountCubit: context.read<AccountCubit>(), orderDetailsCubit: context.read<OrderDetailsCubit>());
          showDialog(context: context, builder: (ctx) => AccountStatusDialog());
        }
      },
      builder: (context, state) {
        return CustomUpgradeAlert(
          upgrader: Upgrader(durationUntilAlertAgain: const Duration(hours: 1)),
          child: Scaffold(
            body: Stack(
              children: [
                _buildVideoSection(),
                _buildSlidingSignInOptions(context, width: width, height: height, state: state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoSection() => Center(child: Lottie.asset(AppAssets.splashLottie, repeat: false, backgroundLoading: true));

  Widget _buildSlidingSignInOptions(BuildContext context, {required double height, required double width, required LandingState state}) {
    return AnimatedAlign(
      alignment: state.isVideoCompleted ? Alignment.bottomCenter : Alignment(0, 1.5),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: state.isVideoCompleted ? 1.0 : 0.0,
        duration: const Duration(seconds: 1),
        child: _checkingNetworkStatus(context, width: width, height: height, state: state),
      ),
    );
  }

  Widget _checkingNetworkStatus(BuildContext context, {required double height, required double width, required LandingState state}) => AnimatedCrossFade(
    firstChild: _buildNetworkErrorUI(context, width: width, height: height),
    secondChild: _buildLoginAndLegalUI(context, width: width, height: height),
    crossFadeState: state.connectionStatus ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    duration: const Duration(seconds: 1),
  );

  Widget _buildNetworkErrorUI(BuildContext context, {required double height, required double width}) => Container(
    width: width,
    height: height * 0.17,
    padding: const EdgeInsets.all(20.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Sorry! Connection Failed", style: Theme.of(context).textTheme.titleSmall),
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Text("Please make sure you have network coverage and try again", textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium),
        ),
      ],
    ),
  );

  Widget _buildLoginAndLegalUI(BuildContext context, {required double height, required double width}) => Container(
    width: width,
    height: height * 0.2,
    margin: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        ElevatedButton(onPressed: () => RouteManager(context).loginPage(), child: Text("Let’s Go Down Memory Lane")),
        Padding(padding: const EdgeInsets.only(top: 20.0, bottom: 25.0), child: _buildTermsAndConditions(context)),
        Text.rich(
          TextSpan(
            children: [
              _powerText(context, title: "Powered By", fontWeight: FontWeight.w500),
              _powerText(context, title: " DataDrone", fontWeight: FontWeight.bold),
            ],
          ),
        ),
      ],
    ),
  );

  TextSpan _powerText(BuildContext context, {required String title, required FontWeight fontWeight}) => TextSpan(
    text: title,
    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: fontWeight),
  );

  Widget _buildTermsAndConditions(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Text.rich(
      TextSpan(
        children: [
          _policyText(context, title: "By continuing, you agree to our "),
          _policyLinkText(context, title: "Terms of Service", onTap: () => CommonFunction.openingExternalWebPage(API.termsOfServiceURL)),
          _policyText(context, title: " & "),
          _policyLinkText(context, title: "Privacy Policy.", onTap: () => CommonFunction.openingExternalWebPage(API.privacyPolicyURL)),
        ],
      ),
      textAlign: TextAlign.center,
    ),
  );

  TextSpan _policyText(BuildContext context, {required String title}) => TextSpan(text: title, style: Theme.of(context).textTheme.bodySmall);

  TextSpan _policyLinkText(BuildContext context, {required String title, required void Function()? onTap}) => TextSpan(
    recognizer: TapGestureRecognizer()..onTap = onTap,
    text: title,
    style: Theme.of(context).textTheme.bodyMedium!.copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.body7Color),
  );
}
