import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';
import 'package:rusticgram/Utility/common_drawer.dart';
import 'package:rusticgram/Utility/custom_upgrader.dart';
import 'package:rusticgram/Utility/grid_image_item.dart';
import 'package:rusticgram/Utility/subscription_plan.dart';
import 'package:rusticgram/Utility/schedule_date.dart';
import 'package:upgrader/upgrader.dart';

class GalleryView extends StatelessWidget {
  const GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomUpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(hours: 1)),
      child: BlocConsumer<OrderDetailsCubit, OrderDetailsState>(
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
            drawer: const CommonDrawer(),
            appBar: AppBar(
              leadingWidth: 65.0,
              leading: Builder(
                builder: (subContext) => Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: IconButton(
                      onPressed: Scaffold.of(subContext).openDrawer,
                      style: const ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(50.0, 50.0))),
                      icon: SvgPicture.asset(AppAssets.menuIcon),
                    ),
                  ),
                ),
              ),
              title: Text("Gallery", style: Theme.of(context).textTheme.titleSmall),
              actions: [
                if (state.orderDetails.imageLinks.totalCount != 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Total Images: ",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.primaryColor),
                          ),
                          TextSpan(
                            text: "${state.orderDetails.imageLinks.downloadLinks.length}",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            body: _mainBody(context, state: state),
          );
        },
      ),
    );
  }

  Widget _mainBody(BuildContext context, {required OrderDetailsState state}) {
    if (state.dataState == DataState.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.orderDetails.imageLinks.downloadLinks.isNotEmpty) {
      return Column(
        children: [
          Expanded(child: _buildImageGrid(context, state: state)),
          _enableSchedulingOption(context, state: state),
        ],
      );
    }
    return Center(child: Text("Scanning on Progress...", style: Theme.of(context).textTheme.titleSmall));
  }

  Widget _enableSchedulingOption(BuildContext context, {required OrderDetailsState state}) {
    if (state.orderDetails.orderStatusCode <= 3) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
        child: ElevatedButton(
          onPressed: () => _schedulingDelivery(context, state: state, scheduleType: "delivery"),
          child: const Text("SCHEDULE RETURN"),
        ),
      );
    } else if (state.orderDetails.orderStatusCode == 4) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
        child: ElevatedButton(
          onPressed: () => _schedulingDelivery(context, state: state, scheduleType: "deliverRe"),
          child: const Text("RESCHEDULE RETURN"),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildImageGrid(BuildContext context, {required OrderDetailsState state}) {
    return Scrollbar(
      thickness: 10.0,
      interactive: true,
      radius: Radius.circular(10.0),
      controller: BlocProvider.of<OrderDetailsCubit>(context).scrollController,
      child: GridView.builder(
        shrinkWrap: true,
        controller: BlocProvider.of<OrderDetailsCubit>(context).scrollController,
        itemCount: state.orderDetails.imageLinks.downloadLinks.length,
        padding: const EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _crossAxisCount(context), mainAxisSpacing: 10.0, crossAxisSpacing: 10.0),
        itemBuilder: (BuildContext context, int index) => _imageContainer(context, index: index, state: state),
      ),
    );
  }

  int _crossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 800) {
      return 4;
    }
    return 3;
  }

  Widget _imageContainer(BuildContext context, {required int index, required OrderDetailsState state}) {
    bool blurStatus = state.orderDetails.paymentDetails.paymentStatus
        ? false
        : index > 4
        ? true
        : false;
    return InkWell(
      onTap: () {
        if (blurStatus) {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            backgroundColor: AppColors.fillColor,
            builder: (ctx) => SubscriptionPlans(planList: state.planList),
          );
        } else {
          RouteManager(context).imageViewerPage(index);
        }
      },
      child: GridImageItem(imageUrl: state.orderDetails.imageLinks.downloadLinks[index].downloadLink, blurStatus: blurStatus),
    );
  }

  void _schedulingDelivery(BuildContext context, {required OrderDetailsState state, required String scheduleType}) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.fillColor,
    builder: (ctx) => ScheduleDate(scheduleType: scheduleType, orderDetails: state.orderDetails),
  );
}
