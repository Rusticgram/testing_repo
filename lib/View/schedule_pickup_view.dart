import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/AddressField/address_field_cubit.dart';
import 'package:rusticgram/Bloc/ConfirmOrder/confirm_order_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Bloc/ScheduleDate/schedule_date_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/address_field.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';
import 'package:rusticgram/Utility/custom_text_field.dart';
import 'package:rusticgram/Utility/schedule_date.dart';

class ConfirmOrderView extends StatelessWidget {
  const ConfirmOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    AddressFieldCubit addressFieldCubit = BlocProvider.of<AddressFieldCubit>(context, listen: true);
    return BlocConsumer<ConfirmOrderCubit, ConfirmOrderState>(
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
            title: Text("Schedule PickUp", style: Theme.of(context).textTheme.titleSmall),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(context, title: "Your Address"),
                Card(color: AppColors.fillColor, margin: const EdgeInsets.symmetric(vertical: 10.0), child: AddressField()),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _title(context, title: "Your Availability"),
                ),
                Card(
                  color: AppColors.fillColor,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ScheduleDate(scheduleType: "new"),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _title(context, title: "Total Number of Photos"),
                ),
                Column(
                  children: [
                    Card(
                      color: AppColors.fillColor,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                        child: Column(
                          children: [
                            _customerPhotoCount(context, value: 0, groupValue: state.selectedOption, title: "I know"),
                            _customerPhotoCount(context, value: 1, groupValue: state.selectedOption, title: "I don't know"),
                            _photoCount(context),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                      child: ElevatedButton(
                        onPressed: () => _checkingAddress(context, state: state, addressFieldCubit: addressFieldCubit),
                        child: state.dataState == DataState.loading ? const Center(child: CircularProgressIndicator()) : const Text("CONFIRM PICKUP"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _title(BuildContext context, {required String title}) => Text(title, style: Theme.of(context).textTheme.titleSmall);

  Future<void> _checkingAddress(BuildContext context, {required ConfirmOrderState state, required AddressFieldCubit addressFieldCubit}) async {
    if (state.dataState != DataState.loading && state.dataState != DataState.success) {
      if (context.mounted) {
        bool isCreated = await BlocProvider.of<ConfirmOrderCubit>(context).validating(
          accountCubit: context.read<AccountCubit>(),
          addressFieldCubit: addressFieldCubit,
          orderDetailsCubit: context.read<OrderDetailsCubit>(),
          scheduleCubit: context.read<ScheduleDateCubit>(),
        );
        if (context.mounted && isCreated) {
          _createdSuccessful(context);
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) RouteManager(context).orderDetailsPage(false);
          });
        }
      }
    }
  }

  Widget _customerPhotoCount(BuildContext context, {required int value, required int groupValue, required String title}) => Padding(
    padding: EdgeInsets.symmetric(vertical: value == 1 ? 20.0 : 0.0),
    child: RadioListTile(
      value: value,
      groupValue: groupValue,
      onChanged: BlocProvider.of<ConfirmOrderCubit>(context).selectingOption,
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(15.0),
      ),
    ),
  );

  Widget _photoCount(BuildContext context) {
    ConfirmOrderState state = context.watch<ConfirmOrderCubit>().state;
    if (context.watch<ConfirmOrderCubit>().state.selectedOption == 1) {
      return ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonFormField<String>(
          initialValue: state.selectedCount,
          items: BlocProvider.of<ConfirmOrderCubit>(context).photoCount
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option, style: Theme.of(context).textTheme.bodyLarge),
                ),
              )
              .toList(),
          onChanged: BlocProvider.of<ConfirmOrderCubit>(context).selectingCount,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          dropdownColor: AppColors.fillColor,
        ),
      );
    }

    return CustomTextField(
      controller: BlocProvider.of<ConfirmOrderCubit>(context).totalPhotoCountController,
      focusNode: BlocProvider.of<ConfirmOrderCubit>(context).totalPhotoCountNode,
      textInputType: TextInputType.number,
      errorText: state.photoCountError,
      labelText: "Total No. of Photos",
    );
  }

  void _createdSuccessful(BuildContext context) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (cont) => AlertDialog(
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
              child: Text("Pickup Scheduled", style: Theme.of(context).textTheme.titleSmall),
            ),
            Text("Our team will be in touch", style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ),
  );
}
