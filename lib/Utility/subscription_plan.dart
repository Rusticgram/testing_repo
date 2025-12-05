import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Bloc/Payment/payment_cubit.dart';
import 'package:rusticgram/Model/plan_list_model.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Config/content_state.dart' as content_state;
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';

class SubscriptionPlans extends StatelessWidget {
  const SubscriptionPlans({super.key, required this.planList});

  final List<PlanDetails> planList;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentCubit(orderDetailsCubit: context.read<OrderDetailsCubit>(), accountCubit: context.read<AccountCubit>()),
      child: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state.paymentState == content_state.PaymentState.success && state.dataState == content_state.DataState.loading) {
            _paymentSuccessAlert(context, state: state);
          } else if (state.paymentState == content_state.PaymentState.success && state.dataState == content_state.DataState.success) {
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) {
                RouteManager(context).popBack();
                RouteManager(context).popBack();
              }
            });
          } else if (state.paymentState == content_state.PaymentState.failure) {
            _paymentFailureAlert(context, state: state);
          } else if (state.dataState == content_state.DataState.failure) {
            showDialog(
              context: context,
              builder: (ctx) => CommonErrorDialog(content: state.errorMessage),
            );
          }
        },
        builder: (context, state) => SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text("Choose Your Plan", style: Theme.of(context).textTheme.titleMedium),
              ),
              _planTile(context, state: state),
              Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  children: [
                    _privilegeText(context, title: "Unlimited Access To Photos"),
                    _privilegeText(context, title: "In-App Download Enabled"),
                    _privilegeText(context, title: "Social Media Sharing"),
                    _privilegeText(context, title: "Immediate Access To New Features"),
                  ],
                ),
              ),
              _paymentButton(context, state: state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planTile(BuildContext context, {required PaymentState state}) => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: planList.length,
    padding: EdgeInsets.zero,
    itemBuilder: (BuildContext context, int index) => InkWell(
      hoverColor: Colors.transparent,
      onTap: () {
        if (state.dataState != content_state.DataState.loading && state.currentPlan != index) {
          BlocProvider.of<PaymentCubit>(context).selectingPlan(currentPlan: index, amount: planList[index].finalAmount, planID: planList[index].planId);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(right: 5.0),
        margin: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: RadioGroup(
                    onChanged: (value) {},
                    groupValue: state.currentPlan,
                    child: Radio(value: index),
                  ),
                ),
                _titleText(context, index: index, state: state),
              ],
            ),
            _amountText(context, index: index, state: state),
          ],
        ),
      ),
    ),
  );

  Widget _titleText(BuildContext context, {required int index, required PaymentState state}) => Row(
    children: [
      Text(planList[index].name, style: Theme.of(context).textTheme.bodyLarge),
      if (planList[index].offerPercentage != 0)
        Container(
          margin: const EdgeInsets.only(left: 10.0),
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
          decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(5.0)),
          child: Text(
            "${planList[index].offerPercentage}% OFF",
            style: Theme.of(context).textTheme.displayMedium!.copyWith(color: AppColors.secondaryColor, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
          ),
        ),
    ],
  );

  Widget _amountText(BuildContext context, {required int index, required PaymentState state}) => Text.rich(
    TextSpan(
      children: [
        if (planList[index].actualAmount != 0)
          TextSpan(
            text: _calculatingAmount(context, amount: planList[index].actualAmount, index: index, actualAmount: false),
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppColors.dividerColor, decoration: TextDecoration.lineThrough, decorationColor: AppColors.dividerColor),
          ),
        TextSpan(
          text: "  ${_calculatingAmount(context, amount: planList[index].finalAmount, index: index, actualAmount: true)}  ",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    ),
    textAlign: TextAlign.end,
  );

  String _calculatingAmount(BuildContext context, {required int amount, required int index, required bool actualAmount}) {
    String finalAmount = "₹ 0";
    if (amount != 0) {
      finalAmount = "₹ $amount";
    }
    if (context.read<AccountCubit>().state.email.contains("@datadrone.biz") && CommonFunction.orderPaymentTestingEnabled && index == planList.length - 1 && actualAmount) {
      finalAmount = "₹ 1";
    }
    return finalAmount;
  }

  Widget _privilegeText(BuildContext context, {required String title}) => ListTile(
    leading: Icon(Icons.verified, color: AppColors.primaryColor, size: 25.0),
    title: Text(title, style: Theme.of(context).textTheme.displayLarge),
  );

  Widget _paymentButton(BuildContext context, {required PaymentState state}) => Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: ElevatedButton(
      onPressed: BlocProvider.of<PaymentCubit>(context).initiateRazorPay,
      child: state.dataState == content_state.DataState.loading ? const Center(child: CircularProgressIndicator()) : const Text("PAY NOW"),
    ),
  );

  void _paymentSuccessAlert(BuildContext context, {required PaymentState state}) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.fillColor,
      insetPadding: const EdgeInsets.all(10.0),
      content: _paymentContentAnimation(
        context,
        secondChild: SizedBox(
          width: 400.0,
          height: 400.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(AppAssets.verifiedIcon, width: 120.0, height: 120.0),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
                child: Text("Payment Completed", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
              ),
            ],
          ),
        ),
        state: state,
      ),
    ),
  );

  void _paymentFailureAlert(BuildContext context, {required PaymentState state}) {
    double width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fillColor,
        insetPadding: const EdgeInsets.all(10.0),
        actionsAlignment: MainAxisAlignment.center,
        content: BlocProvider.value(
          value: context.read<PaymentCubit>(),
          child: BlocBuilder<PaymentCubit, PaymentState>(
            builder: (context, state) {
              return _paymentContentAnimation(
                context,
                state: state,
                secondChild: SizedBox(
                  width: 400.0,
                  height: 400.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(AppAssets.paymentFailureIcon, width: 120.0, height: 120.0),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(state.paymentErrorTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
                      ),
                      if (state.paymentErrorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
                          child: Text(state.paymentErrorMessage, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              RouteManager(ctx).popBack();
              RouteManager(ctx).popBack();
            },
            style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.3, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.grey)),
            child: const Text("LATER"),
          ),
          const SizedBox(width: 20.0),
          ElevatedButton(
            onPressed: () => RouteManager(ctx).popBack(),
            style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.38, 50.0))),
            child: Text("TRY AGAIN"),
          ),
        ],
      ),
    );
  }

  Widget _paymentContentAnimation(BuildContext context, {required Widget secondChild, required PaymentState state}) => BlocProvider.value(
    value: context.read<PaymentCubit>(),
    child: BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        return AnimatedCrossFade(
          firstChild: SizedBox(
            width: 400.0,
            height: 400.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
                  child: Text("Checking Payment", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
                ),
              ],
            ),
          ),
          secondChild: secondChild,
          crossFadeState: state.dataState == content_state.DataState.loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          alignment: AlignmentDirectional.center,
          duration: const Duration(milliseconds: 500),
        );
      },
    ),
  );
}
