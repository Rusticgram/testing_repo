import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/address_field.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state.dataState == DataState.failure) {
          showDialog(
            context: context,
            builder: (ctx) => CommonErrorDialog(content: state.errorMessage),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                if (state.dataState != DataState.loading) {
                  RouteManager(context).popBack();
                }
              },
              icon: const Icon(Icons.arrow_back, color: AppColors.body3Color),
            ),
            title: Text("My Account", style: Theme.of(context).textTheme.titleSmall),
          ),
          body: ListView(
            padding: const EdgeInsets.all(10.0),
            children: [
              Card(
                color: AppColors.fillColor,
                margin: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        child: InkWell(
                          onTap: state.dataState == DataState.loading ? null : BlocProvider.of<AccountCubit>(context).selectingProfilePic,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryColor, width: 2.0),
                            ),
                            child: Container(
                              width: 120.0,
                              height: 120.0,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              margin: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(color: Color(0xFFFC6600), shape: BoxShape.circle),
                              child: _profileImage(state),
                            ),
                          ),
                        ),
                      ),
                      _detailCard(context, title: state.name),
                      _detailCard(context, title: state.email),
                      _detailCard(context, title: state.mobile),
                      Container(
                        width: width,
                        margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: AppColors.primaryColor, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: state.address.formattedAddress.isNotEmpty ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: _addressText(context, title: state.address.formattedAddress),
                              ),
                            ),
                            InkWell(
                              onTap: () => _editAddress(context),
                              child: Padding(padding: const EdgeInsets.all(10.0), child: SvgPicture.asset(AppAssets.addressEditIcon)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (context.watch<OrderDetailsCubit>().state.orderDetails.paymentDetails.subscriptionID.isNotEmpty &&
                  context.watch<OrderDetailsCubit>().state.orderDetails.paymentDetails.subscriptionStatus == "active")
                TextButton(
                  onPressed: () => _cancelSubscriptionStatusMessage(
                    context,
                    title: "Cancel Subscription",
                    message: "Are you sure you want to cancel your subscription? You’ll lose access to all your photos immediately after cancellation.",
                    actions: [
                      BlocBuilder<AccountCubit, AccountState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: () => _cancellingSubscription(context),
                            style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.38, 50.0))),
                            child: state.orderState == OrderState.loading ? Center(child: CircularProgressIndicator()) : const Text("CONTINUE"),
                          );
                        },
                      ),
                      const SizedBox(width: 20.0),
                      ElevatedButton(
                        onPressed: () => RouteManager(context).popBack(),
                        style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.32, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.grey)),
                        child: Text(
                          "CANCEL",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  child: Text("Cancel Subscription"),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _addressText(BuildContext context, {required String title}) {
    if (title.isNotEmpty) {
      return _cardText(context, title: title);
    }
    return Text("Address", style: Theme.of(context).textTheme.labelLarge);
  }

  Widget _detailCard(BuildContext context, {required String title}) {
    return Card(
      color: AppColors.fillColor,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        height: 60.0,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: AppColors.primaryColor, width: 1.5),
        ),
        child: _cardText(context, title: title),
      ),
    );
  }

  Widget _cardText(BuildContext context, {required String title}) => Text(title, style: Theme.of(context).textTheme.displayMedium);

  Widget _profileImage(AccountState state) {
    return ExtendedImage.memory(
      state.profilePic,
      loadStateChanged: (progressState) {
        if (progressState.extendedImageLoadState == LoadState.loading || state.dataState == DataState.loading) {
          return const Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(child: CircularProgressIndicator(strokeWidth: 5)),
          );
        } else if (progressState.extendedImageLoadState == LoadState.failed) {
          return _defaultProfileIcon();
        }
        return null;
      },
      fit: BoxFit.fill,
    );
  }

  Widget _defaultProfileIcon() => Image.asset(AppAssets.defaultProfileIcon, fit: BoxFit.fill);

  void _editAddress(BuildContext context) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: AppColors.fillColor,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AddressField(showButton: true),
    ),
  );

  Future<void> _cancellingSubscription(BuildContext context) async {
    bool isCancelled = await BlocProvider.of<AccountCubit>(context).cancellingSubscription(context.read<OrderDetailsCubit>().state.orderDetails.paymentDetails.subscriptionID);
    if (isCancelled && context.mounted) {
      _cancelSubscriptionStatusMessage(
        context,
        title: "Subscription Cancelled Successfully",
        message: "Your subscription has been successfully canceled. You will no longer be billed. Thanks for being with us — we hope to see you again soon.",
        actions: [],
      );
      await BlocProvider.of<OrderDetailsCubit>(context).fetchingOrderDetails();
      if (context.mounted) {
        RouteManager(context).popBack();
        RouteManager(context).popBack();
      }
    } else if (context.mounted) {
      _cancelSubscriptionStatusMessage(
        context,
        title: "Subscription Cancellation Failed",
        message: "We encountered an error while canceling your subscription. Please check your internet connection or try again later.",
        actions: [],
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          RouteManager(context).popBack();
          RouteManager(context).popBack();
        }
      });
    }
  }

  void _cancelSubscriptionStatusMessage(BuildContext context, {required String title, required String message, required List<Widget> actions}) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.fillColor,
      title: Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
      content: Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
      actionsAlignment: MainAxisAlignment.center,
      actions: actions,
    ),
  );
}
