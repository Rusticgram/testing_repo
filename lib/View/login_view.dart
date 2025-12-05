import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/Authentication/authentication_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';
import 'package:rusticgram/Utility/phone_and_otp.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state.dataState == DataState.failure) showDialog(context: context, builder: (ctx) => CommonErrorDialog(content: state.errorMessage));
      },
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 60.0),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Text("Enter your mobile number to access your albums or to set up a new account.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
                ),
                PhoneAndOtp(),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(onPressed: () => _mainButtonFunction(context, state: state), child: _mainButton(context, state: state)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mainButton(BuildContext context, {required AuthenticationState state}) {
    if (state.showOTP) {
      return _fadeAnimation(firstChild: const Text("VERIFY"), secondChild: const Center(child: CircularProgressIndicator()), fadeStatus: state.dataState != DataState.loading);
    }
    return _fadeAnimation(firstChild: const Text("SEND CODE"), secondChild: const Center(child: CircularProgressIndicator()), fadeStatus: state.dataState != DataState.loading);
  }

  Widget _fadeAnimation({required Widget firstChild, required Widget secondChild, required bool fadeStatus}) =>
      AnimatedSwitcher(duration: const Duration(milliseconds: 500), child: fadeStatus ? firstChild : secondChild);

  Future<void> _mainButtonFunction(BuildContext context, {required AuthenticationState state}) async {
    if (state.dataState != DataState.loading) {
      if (state.showOTP) {
        bool otpVerified = await BlocProvider.of<AuthenticationCubit>(context).verifyOTP(accountCubit: context.read<AccountCubit>(), orderDetailsCubit: context.read<OrderDetailsCubit>());
        if (otpVerified && context.mounted) {
          state = context.read<AuthenticationCubit>().state;
          if (state.isNewUser) {
            RouteManager(context).signInPage();
          } else if (state.profileStatus) {
            RouteManager(context).checkingExistingOrder(orderDetailsCubit: context.read<OrderDetailsCubit>(), accountCubit: context.read<AccountCubit>());
          } else {
            showDialog(context: context, builder: (ctx) => AccountStatusDialog());
          }
        }
      } else {
        BlocProvider.of<AuthenticationCubit>(context).validatingPhoneNumber();
      }
    }
  }
}
