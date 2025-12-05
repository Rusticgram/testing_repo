import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/ScheduleDate/schedule_date_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Model/order_details_model.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/custom_text_field.dart';

class ScheduleDate extends StatelessWidget {
  const ScheduleDate({super.key, required this.scheduleType, this.orderDetails});

  final String scheduleType;
  final OrderDetails? orderDetails;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleDateCubit, ScheduleDateState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: TextEditingController(text: DateFormat("dd/MM/yyyy").format(state.scheduleDate.start)),
                    focusNode: FocusNode(),
                    textInputType: TextInputType.none,
                    labelText: "Date",
                    isRequired: false,
                    errorText: "",
                    readOnly: true,
                    onTap: () => _datePicker(context, state: state),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: state.selectedTime,
                        alignment: Alignment.center,
                        dropdownColor: AppColors.fillColor,
                        borderRadius: BorderRadius.circular(10.0),
                        items: BlocProvider.of<ScheduleDateCubit>(context).scheduleTimeList
                            .map(
                              (time) => DropdownMenuItem<String>(
                                value: time,
                                alignment: Alignment.center,
                                child: Text(time, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500)),
                              ),
                            )
                            .toList(),
                        onChanged: (time) {
                          String tempTime = time!.split("-").first.split(":").first.trim();
                          DateTime date = state.scheduleDate.start;
                          DateTime tempDate = DateTime(date.year, date.month, date.day, int.parse(tempTime));
                          BlocProvider.of<ScheduleDateCubit>(context).selectingTime(time: "$tempDate", date: state.scheduleDate);
                        },
                        iconSize: 0.0,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fillColor,
                          label: Text("Time", style: Theme.of(context).textTheme.displayMedium),
                        ),
                      ),
                    ),
                  ),
                  if (scheduleType != "new" && orderDetails != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: ElevatedButton(
                        onPressed: () => _schedulingOrder(context, scheduleType: scheduleType, orderDetails: orderDetails!),
                        child: state.dataState == DataState.loading ? const Center(child: CircularProgressIndicator()) : const Text("SCHEDULE"),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _datePicker(BuildContext context, {required ScheduleDateState state}) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: state.scheduleDate.start,
      currentDate: state.scheduleDate.start,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryColor),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.secondaryColor,
            todayBackgroundColor: const WidgetStatePropertyAll(AppColors.secondaryColor),
            todayForegroundColor: const WidgetStatePropertyAll(AppColors.primaryColor),
            headerHeadlineStyle: Theme.of(context).textTheme.titleLarge,
            confirmButtonStyle: ButtonStyle(foregroundColor: const WidgetStatePropertyAll(AppColors.primaryColor), textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.bodyLarge)),
            cancelButtonStyle: ButtonStyle(foregroundColor: const WidgetStatePropertyAll(AppColors.primaryColor), textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.bodyLarge)),
          ),
        ),
        child: child!,
      ),
    );
    if (selectedDate != null && context.mounted) {
      BlocProvider.of<ScheduleDateCubit>(context).selectingDate(date: selectedDate, isDateFormated: true);
    }
  }

  Future<void> _schedulingOrder(BuildContext context, {required String scheduleType, required OrderDetails orderDetails}) async {
    bool scheduled = await BlocProvider.of<ScheduleDateCubit>(context).schedulingOrder(scheduleType: scheduleType, orderDetails: orderDetails, accountCubit: context.read<AccountCubit>());
    if (scheduled && context.mounted) {
      RouteManager(context).popBack();
    }
  }
}
