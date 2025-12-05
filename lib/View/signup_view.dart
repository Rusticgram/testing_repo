import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rusticgram/Bloc/SignUp/signup_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';
import 'package:rusticgram/Utility/custom_text_field.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state.dataState == DataState.failure) {
          showDialog(context: context, builder: (ctx) => CommonErrorDialog(content: state.errorMessage));
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Tell Us About Yourself", style: Theme.of(context).textTheme.titleSmall),
            leading: IconButton(
              onPressed: () {
                if (state.dataState != DataState.loading) {
                  RouteManager(context).popBack();
                }
              },
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColors.lightBrown)),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text("We’d love to know who’s behind the memories. Just your name and email!", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
                ),
                Padding(padding: const EdgeInsets.only(top: 20.0, bottom: 10.0), child: _titleText(context, title: "Your Name")),
                CustomTextField(
                  controller: BlocProvider.of<SignupCubit>(context).nameController,
                  focusNode: BlocProvider.of<SignupCubit>(context).nameFocus,
                  textInputType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  hintText: "Name",
                  isFilled: false,
                  errorText: state.nameError,
                  textInputAction: TextInputAction.next,
                ),
                Padding(padding: const EdgeInsets.only(top: 20.0, bottom: 10.0), child: _titleText(context, title: "Your E-mail")),
                CustomTextField(
                  controller: BlocProvider.of<SignupCubit>(context).emailController,
                  focusNode: BlocProvider.of<SignupCubit>(context).emailFocus,
                  textInputType: TextInputType.emailAddress,
                  hintText: "Email",
                  isFilled: false,
                  errorText: state.emailError,
                  textInputAction: TextInputAction.done,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: () => _mainButtonFunction(context, state: state),
                    child: _fadeAnimation(
                      firstChild: const Text("CONTINUE"),
                      secondChild: const Center(child: CircularProgressIndicator()),
                      fadeStatus: state.dataState != DataState.loading,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _titleText(BuildContext context, {required String title}) => Text.rich(
    TextSpan(
      children: [
        TextSpan(text: title, style: Theme.of(context).textTheme.titleSmall),
        TextSpan(text: " *", style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColors.redColor)),
      ],
    ),
  );

  Widget _fadeAnimation({required Widget firstChild, required Widget secondChild, required bool fadeStatus}) =>
      AnimatedSwitcher(duration: const Duration(milliseconds: 500), child: fadeStatus ? firstChild : secondChild);

  Future<void> _mainButtonFunction(BuildContext context, {required SignupState state}) async {
    if (state.dataState != DataState.loading) {
      bool isCreated = await BlocProvider.of<SignupCubit>(context).creatingProfile();
      if (isCreated && context.mounted) {
        _completedAlertDialog(context);
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) RouteManager(context).homePage();
        });
      }
    }
  }

  void _completedAlertDialog(BuildContext context) => showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          backgroundColor: AppColors.fillColor,
          insetPadding: const EdgeInsets.all(10.0),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(AppAssets.verifiedIcon, width: 120.0, height: 120.0),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
                  child: Text("Welcome to Rusticgram", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
                ),
              ],
            ),
          ),
        ),
  );
}
