import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';

class ServiceSummaryView extends StatelessWidget {
  const ServiceSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderDetailsCubit, OrderDetailsState>(
      listener: (context, state) => _downloadStatusAlert(context, state: state),
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text("Service Summary", style: Theme.of(context).textTheme.titleSmall),
          leading: IconButton(
            onPressed: () {
              if (state.dataState != DataState.loading) {
                RouteManager(context).popBack();
              }
            },
            icon: const Icon(Icons.arrow_back, color: AppColors.body3Color),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              _descriptionCard(context, state: state),
              _addressCard(context, state: state),
              _paymentDetailsCard(context, state: state),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadStatusAlert(BuildContext context, {required OrderDetailsState state}) {
    if (state.dataState == DataState.success || state.dataState == DataState.failure) {
      String title = "Download Successful";
      String content = "Downloading Image Successful";
      if (state.dataState == DataState.failure) {
        title = "Download Failed";
        content = "Downloading Image Failed. Please Try Again.";
      }
      showDialog(
        context: context,
        builder: (_) => DownloadStatus(title: title, content: content),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) RouteManager(context).popBack();
      });
    }
  }

  Widget _descriptionCard(BuildContext context, {required OrderDetailsState state}) {
    return Card(
      color: AppColors.fillColor,
      margin: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.0,
                  height: 120.0,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    boxShadow: const [BoxShadow(offset: Offset(0, 2), blurRadius: 10.0, color: Color.fromARGB(255, 102, 102, 102))],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Image.asset(AppAssets.serviceSummaryIcon, fit: BoxFit.cover),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      BlocProvider.of<OrderDetailsCubit>(context).invoiceName(state.orderDetails.dealName, phoneNumber),
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text("Photo Scanned : ${state.orderDetails.noOfPhotos}", style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Text("Description", style: Theme.of(context).textTheme.displayLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
            child: Text("Photo Digitization Service: ", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.primaryColor)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
            child: Text("Secure pickup, scan, digitize, and deliver photo prints with lifetime access on your Rusticgram application.", style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(BuildContext context, {required OrderDetailsState state}) {
    return Card(
      color: AppColors.fillColor,
      margin: const EdgeInsets.all(10.0),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Address", style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w600)),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
              child: Text(context.watch<AccountCubit>().state.address.formattedAddress, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Picked-Up Date ", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.primaryColor)),
                Text(_dateFormatting(state.orderDetails.pickupDateTime), style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    state.orderDetails.orderStatusCode != 5 ? "Delivering Date " : "Delivered Date ",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.primaryColor),
                  ),
                  Text(_dateFormatting(state.orderDetails.deliveryDateTime), style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentDetailsCard(BuildContext context, {required OrderDetailsState state}) => SizedBox(
    width: double.maxFinite,
    child: Card(
      color: AppColors.fillColor,
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Price Details", style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w600)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Total Count of Photos", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.primaryColor)),
                  Text(state.orderDetails.noOfPhotos, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Digitizing Service", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.primaryColor)),
                Text("₹ ${state.orderDetails.paymentDetails.amountPaid}", style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
            if (state.orderDetails.paymentDetails.discountAmount != 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Coupon Discount", style: Theme.of(context).textTheme.bodyLarge),
                    Text("- ₹ ${state.orderDetails.paymentDetails.discountAmount}", style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total", style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w600)),
                  Text("₹ ${state.orderDetails.paymentDetails.amountPaid}", style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    ),
  );

  String _dateFormatting(String date) {
    if (date.isNotEmpty) {
      return DateFormat("dd/MM/yyyy").format(DateTime.parse(date));
    } else {
      return "";
    }
  }
}
