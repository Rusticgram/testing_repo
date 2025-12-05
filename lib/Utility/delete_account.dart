import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/DeleteAccount/delete_account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';
import 'package:rusticgram/Utility/custom_text_field.dart';

class DeleteAccount extends StatelessWidget {
  const DeleteAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeleteAccountCubit(context.read<AccountCubit>()),
      child: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
        listener: (context, state) async {
          if (state.dataState == DataState.success) {
            if (state.paymentState == PaymentState.success) {
              _paymentSuccessAlert(context, state: state);
              await Future.delayed(const Duration(seconds: 2));
            }
            if (context.mounted) {
              CommonFunction.logout(accountCubit: context.read<AccountCubit>(), orderDetailsCubit: context.read<OrderDetailsCubit>());
              RouteManager(context).loginPage();
            }
          } else if (state.paymentState == PaymentState.failure) {
            _paymentFailureAlert(context, state: state);
          } else if (state.dataState == DataState.failure) {
            showDialog(
              context: context,
              builder: (ctx) => CommonErrorDialog(content: state.errorMessage),
            );
          }
        },
        builder: (context, state) {
          return OutlinedButton(
            onPressed: () {
              OrderDetailsCubit orderDetailsCubit = BlocProvider.of<OrderDetailsCubit>(context);
              if (orderDetailsCubit.state.orderDetails.orderStatusCode == 0) {
                _directDelete(context, state: state);
              } else if (orderDetailsCubit.state.orderDetails.orderStatusCode >= 1 && orderDetailsCubit.state.orderDetails.orderStatusCode <= 4) {
                _deleteRequest(context, state: state);
              } else {
                _deletePayment(context, state: state);
              }
            },
            child: const Text("DELETE ACCOUNT"),
          );
        },
      ),
    );
  }

  void _directDelete(BuildContext context, {required DeleteAccountState state}) => _commonAlertDialog(
    context,
    state: state,
    buttonTitle: "DELETE",
    content: Text("Are you sure you want to delete your account?", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
    onPressed: () async {
      return await BlocProvider.of<DeleteAccountCubit>(context).deletingAccount("delete");
    },
  );

  void _deleteRequest(BuildContext context, {required DeleteAccountState state}) => _commonAlertDialog(
    context,
    state: state,
    buttonTitle: "REQUEST",
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Need to delete your account? Our support team will help you. Please get in touch.", textAlign: TextAlign.justify, style: Theme.of(context).textTheme.bodyLarge),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
          child: Text("Reason for deletion:", textAlign: TextAlign.justify, style: Theme.of(context).textTheme.bodyLarge),
        ),
        CustomTextField(
          controller: BlocProvider.of<DeleteAccountCubit>(context).deleteReason,
          focusNode: BlocProvider.of<DeleteAccountCubit>(context).deleteNode,
          textInputType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          errorText: state.reasonError,
          maxLines: 5,
        ),
      ],
    ),
    onPressed: () async => await BlocProvider.of<DeleteAccountCubit>(context).requestDeletion(),
  );

  void _deletePayment(BuildContext context, {required DeleteAccountState state}) => _commonAlertDialog(
    context,
    state: state,
    buttonTitle: "DELETE",
    content: Text.rich(
      TextSpan(
        children: [
          TextSpan(text: "As per our policy, a one time fee of ${_deleteAmount(context)} is required to permanently delete your account."),
          // TextSpan(
          //   text:
          //       "If you do not wish to proceed with permanent deletion, you can choose to deactivate your account instead. Deactivation is free, and you may reactivate your account anytime in the future without any charges.",
          // ),
        ],
      ),
      textAlign: TextAlign.justify,
      style: Theme.of(context).textTheme.bodyLarge,
    ),
    onPressed: () async => _onPressedAction(context, type: "delete"),
  );

  String _deleteAmount(BuildContext context) {
    String customerEmail = BlocProvider.of<AccountCubit>(context).state.email;
    if (customerEmail.contains("@datadrone.biz") && CommonFunction.deletePaymentTestingEnabled) {
      return "₹1";
    }
    return "₹1999";
  }

  Future<bool> _onPressedAction(BuildContext context, {required String type}) async {
    if (type == "delete") {
      BlocProvider.of<DeleteAccountCubit>(context).initiateRazorPay();
      return false;
    } else {
      return await BlocProvider.of<DeleteAccountCubit>(context).deletingAccount("deactivate");
    }
  }

  void _commonAlertDialog(BuildContext context, {required String buttonTitle, required Widget content, required Future<bool> Function() onPressed, required DeleteAccountState state}) {
    double width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          scrollable: true,
          insetPadding: EdgeInsets.all(15.0),
          backgroundColor: AppColors.fillColor,
          actionsAlignment: MainAxisAlignment.center,
          title: Text("DELETE ACCOUNT", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
          content: content,
          actions: [
            BlocProvider.value(
              value: BlocProvider.of<DeleteAccountCubit>(context),
              child: BlocBuilder<DeleteAccountCubit, DeleteAccountState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () async {
                      if (state.dataState != DataState.loading) {
                        bool isDeleted = await onPressed();
                        if (isDeleted) {
                          if (buttonTitle == "REQUEST" && context.mounted) {
                            _requestedSuccessfully(context);
                            await Future.delayed(const Duration(seconds: 2));
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } else {
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          }
                        }
                      }
                    },
                    style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.35, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.redColor)),
                    child: state.dataState == DataState.loading ? Center(child: CircularProgressIndicator()) : Text(buttonTitle),
                  );
                },
              ),
            ),
            const SizedBox(width: 20.0),
            ElevatedButton(
              onPressed: () => RouteManager(ctx).popBack(),
              style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.32, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.grey)),
              child: Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }

  void _requestedSuccessfully(BuildContext context) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      insetPadding: EdgeInsets.all(15.0),
      backgroundColor: AppColors.fillColor,
      content: SizedBox(
        width: 350.0,
        height: 350.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppAssets.verifiedIcon, width: 120.0, height: 120.0),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
              child: Text("Delete Request Submitted", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
            ),
          ],
        ),
      ),
    ),
  );

  void _paymentSuccessAlert(BuildContext context, {required DeleteAccountState state}) => showDialog(
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

  void _paymentFailureAlert(BuildContext context, {required DeleteAccountState state}) {
    double width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fillColor,
        insetPadding: const EdgeInsets.all(10.0),
        actionsAlignment: MainAxisAlignment.center,
        content: _paymentContentAnimation(
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
        ),
        actions: [
          ElevatedButton(
            onPressed: () => RouteManager(ctx).popBack(),
            style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.3, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.grey)),
            child: const Text("LATER"),
          ),
          const SizedBox(width: 20.0),
          ElevatedButton(
            onPressed: () {
              RouteManager(ctx).popBack();
              BlocProvider.of<DeleteAccountCubit>(context).initiateRazorPay();
            },
            style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.38, 50.0))),
            child: Text("TRY AGAIN"),
          ),
        ],
      ),
    );
  }

  Widget _paymentContentAnimation(BuildContext context, {required Widget secondChild, required DeleteAccountState state}) => BlocProvider.value(
    value: BlocProvider.of<DeleteAccountCubit>(context),
    child: BlocBuilder<DeleteAccountCubit, DeleteAccountState>(
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
          crossFadeState: state.dataState == DataState.loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          alignment: AlignmentDirectional.center,
          duration: const Duration(milliseconds: 500),
        );
      },
    ),
  );
}
