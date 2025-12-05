import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Model/order_details_model.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Response/api.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';
import 'package:rusticgram/Utility/common_drawer.dart';
import 'package:rusticgram/Utility/custom_text_field.dart';
import 'package:rusticgram/Utility/custom_upgrader.dart';
import 'package:rusticgram/Utility/schedule_date.dart';
import 'package:upgrader/upgrader.dart';

class OrderDetailsView extends StatefulWidget {
  const OrderDetailsView({super.key});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderDetailsCubit, OrderDetailsState>(
      listener: (context, state) {
        if (state.orderState == OrderState.loading) {
          _controller.repeat();
        } else if (state.orderState == OrderState.loaded) {
          _controller.stop();
        }
        if (state.dataState == DataState.failure) {
          showDialog(
            context: context,
            builder: (context) => CommonErrorDialog(content: state.errorMessage),
          );
        }
      },
      builder: (context, state) {
        return CustomUpgradeAlert(
          upgrader: Upgrader(durationUntilAlertAgain: const Duration(hours: 1)),
          child: Scaffold(
            drawer: const CommonDrawer(),
            appBar: AppBar(
              title: Text("Track Progress", style: Theme.of(context).textTheme.titleSmall),
              leadingWidth: 65.0,
              leading: _leadingIcon(context, state: state),
              actions: [
                if (state.orderDetails.orderStatusCode != 5)
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: IconButton(
                      onPressed: () => _checkingOrderStatus(context, state: state, orderState: true),
                      icon: AnimatedBuilder(
                        animation: _controller,
                        child: const Icon(Icons.refresh, size: 24.0),
                        builder: (context, child) => Transform.rotate(angle: state.orderState == OrderState.loading ? _controller.value * 2 * 3.1416 : 0, child: child),
                      ),
                    ),
                  ),
              ],
            ),
            body: _buildOrderTracking(context, state: state),
          ),
        );
      },
    );
  }

  Widget _leadingIcon(BuildContext context, {required OrderDetailsState state}) {
    if (state.orderDetails.orderStatusCode >= 3) {
      return IconButton(
        onPressed: () {
          if (state.dataState != DataState.loading) {
            RouteManager(context).galleryPage();
          }
        },
        icon: const Icon(Icons.arrow_back, color: AppColors.body3Color),
      );
    } else {
      return Builder(
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
      );
    }
  }

  Widget _buildOrderTracking(BuildContext context, {required OrderDetailsState state}) {
    if (state.dataState != DataState.loading) {
      return ListView(
        padding: const EdgeInsets.all(10.0),
        physics: state.orderDetails.orderStatus == "Scanning On Hold" ? const NeverScrollableScrollPhysics() : null,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              alignment: Alignment.centerRight,
              child: SelectableText("Service ID: ${state.orderDetails.id}", style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: AppColors.body7Color)),
            ),
          ),
          _buildStepper(context, state),
          const SizedBox(height: 15.0),
          _buildConditionalButtons(context, orderDetails: state.orderDetails, state: state),
          const SizedBox(height: 10.0),
        ],
      );
    }
    return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
  }

  Widget _buildStepper(BuildContext context, OrderDetailsState state) => Card(
    color: AppColors.fillColor,
    child: Theme(
      data: ThemeData(
        colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primaryColor, secondary: AppColors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Stepper(
          currentStep: state.orderDetails.orderStatusCode,
          physics: const NeverScrollableScrollPhysics(),
          steps: [
            _buildStep(context, "Pickup Scheduled", "Your pickup is scheduled on ${_formatDate(state.orderDetails.pickupDateTime)}", state.activeSteps[0]),
            _buildStep(context, "Picked Up Originals", "We have received your Album", state.activeSteps[1]), // on ${_formatDate(state.orderDetails.pickupDateTime)}
            _buildStep(
              context,
              "Scanning In Progress",
              state.activeSteps[3] ? "Our team has completed the scanning" : "Our team has started scanning your ${state.orderDetails.noOfPhotos} photos",
              state.activeSteps[2],
            ),
            _buildStep(context, "Digitalization Complete", "We have scanned ${state.orderDetails.noOfPhotos} photos", state.activeSteps[3]),
            _buildStep(context, "Return Scheduled", "Your return is scheduled for ${_formatDate(state.orderDetails.deliveryDateTime)}", state.activeSteps[4]),
            _buildStep(context, "Originals Returned", "Returned your originals on ${_formatDate(state.orderDetails.deliveryEndTime)}", state.activeSteps[5]),
          ],
          controlsBuilder: (context, details) => const Row(),
          stepIconBuilder: (stepIndex, stepState) => _buildStepIcon(stepIndex, state.activeSteps[stepIndex]),
          stepIconHeight: 60.0,
          stepIconWidth: 60.0,
          stepIconMargin: EdgeInsets.zero,
        ),
      ),
    ),
  );

  Step _buildStep(BuildContext context, String title, String subtitle, bool isActive) {
    return Step(
      isActive: isActive,
      title: Text(title, style: Theme.of(context).textTheme.displayLarge),
      subtitle: isActive ? Text(subtitle, style: Theme.of(context).textTheme.labelMedium) : const Row(),
      content: const Row(),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isNotEmpty) {
      return DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.parse(dateString));
    } else {
      return "(Date)";
    }
  }

  Widget _buildStepIcon(int stepIndex, bool stepState) {
    switch (stepIndex) {
      case 1:
        return SvgPicture.asset(AppAssets.stepperIcon, colorFilter: _stepIconColor(stepState));
      case 2:
        return SvgPicture.asset(AppAssets.stepper1Icon, colorFilter: _stepIconColor(stepState));
      case 3:
        return SvgPicture.asset(AppAssets.stepper2Icon, colorFilter: _stepIconColor(stepState));
      case 4:
        return SvgPicture.asset(AppAssets.stepper3Icon, colorFilter: _stepIconColor(stepState));
      case 5:
        return SvgPicture.asset(AppAssets.stepper4Icon, colorFilter: _stepIconColor(stepState));
      default:
        return SvgPicture.asset(AppAssets.stepper5Icon, colorFilter: _stepIconColor(stepState));
    }
  }

  ColorFilter _stepIconColor(bool currentStep) {
    Color stepColor;
    if (currentStep) {
      stepColor = AppColors.fillColor;
    } else {
      stepColor = AppColors.primaryColor;
    }
    return ColorFilter.mode(stepColor, BlendMode.srcIn);
  }

  Widget _buildConditionalButtons(BuildContext context, {required OrderDetails orderDetails, required OrderDetailsState state}) {
    switch (orderDetails.orderStatusCode) {
      case 0:
        return Column(
          children: [
            ElevatedButton(
              onPressed: () => _scheduleOrder(context, scheduleType: "pickup", orderDetails: orderDetails),
              child: const Text("RESCHEDULE PICKUP"),
            ),
            _cancelButton(context, orderStatusCode: orderDetails.orderStatusCode),
          ],
        );
      case 1:
        return _cancelButton(context, orderStatusCode: orderDetails.orderStatusCode);
      case 2:
        return _cancelButton(context, orderStatusCode: orderDetails.orderStatusCode);
      case 3:
        return ElevatedButton(
          onPressed: () => _scheduleOrder(context, scheduleType: "delivery", orderDetails: orderDetails),
          child: const Text("SCHEDULE RETURN"),
        );
      case 4:
        if (orderDetails.deliveryDateTime.isNotEmpty && orderDetails.deliveryEndTime.isNotEmpty && orderDetails.orderStatus != "Album Dispatched") {
          return ElevatedButton(
            onPressed: () => _scheduleOrder(context, scheduleType: "deliverRe", orderDetails: orderDetails),
            child: const Text("RESCHEDULE DELIVERY"),
          );
        }
        return const SizedBox.shrink();
      case 5:
        if (orderDetails.orderStatus == "Album Delivered") {
          return ElevatedButton(
            onPressed: () => _provideFeedback(context, state: state),
            child: const Text("GIVE FEEDBACK"),
          );
        }
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  void _provideFeedback(BuildContext context, {required OrderDetailsState state}) {
    final cubit = BlocProvider.of<OrderDetailsCubit>(context);
    cubit.feedbackController.clear();
    double width = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("We Value Your Feedback", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: CustomTextField(
                      controller: BlocProvider.of<OrderDetailsCubit>(context).feedbackController,
                      focusNode: BlocProvider.of<OrderDetailsCubit>(context).feedbackFocusNode,
                      textInputType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      errorText: state.feedbackError,
                      maxLines: 5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            bool feedbackUpdated = await BlocProvider.of<OrderDetailsCubit>(context).updatingFeedback();
                            if (feedbackUpdated && ctx.mounted) {
                              RouteManager(ctx).popBack();
                            }
                          },
                          style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.38, 50.0))),
                          child: state.dataState == DataState.loading ? CircularProgressIndicator(color: AppColors.white) : Text("CONTINUE"),
                        ),
                        ElevatedButton(
                          onPressed: () => RouteManager(ctx).popBack(),
                          style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.32, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.grey)),
                          child: Text(
                            "CANCEL",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _scheduleOrder(BuildContext context, {required String scheduleType, required OrderDetails orderDetails}) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.fillColor,
    builder: (_) => ScheduleDate(scheduleType: scheduleType, orderDetails: orderDetails),
  );

  Widget _cancelButton(BuildContext context, {required int orderStatusCode}) => Padding(
    padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
    child: ElevatedButton(
      onPressed: () {
        if (orderStatusCode == 0) {
          BlocProvider.of<OrderDetailsCubit>(context).resettingCancelReason();
          _cancelReason(context);
        } else {
          _reachSupportForCancel(context);
        }
      },
      style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColors.fill1Color)),
      child: Text("CANCEL SERVICE", style: Theme.of(context).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.w500)),
    ),
  );

  void _cancelReason(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fillColor,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
            builder: (subctx, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Reason for Cancelling your Order", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.cancelReasons.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index) => RadioListTile(
                      value: index,
                      groupValue: state.selectedReason,
                      contentPadding: EdgeInsets.zero,
                      onChanged: BlocProvider.of<OrderDetailsCubit>(context).selectingCancelReason,
                      title: Text(state.cancelReasons[index], style: Theme.of(context).textTheme.bodyLarge),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: CustomTextField(
                        controller: BlocProvider.of<OrderDetailsCubit>(context).cancelReasonController,
                        focusNode: BlocProvider.of<OrderDetailsCubit>(context).cancelFocusNode,
                        hintText: "Reason for cancelling",
                        maxLines: 5,
                        textInputType: TextInputType.text,
                        errorText: state.cancelError,
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: state.selectedReason == (state.cancelReasons.length - 1) ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 500),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (state.selectedReason == (state.cancelReasons.length - 1)) {
                              BlocProvider.of<OrderDetailsCubit>(context).validatingCancelError();
                              state = BlocProvider.of<OrderDetailsCubit>(context).state;
                              if (state.cancelError.isEmpty) {
                                RouteManager(ctx).popBack();
                                _cancelConfirmatiion(context, orderStatusCode: state.orderDetails.orderStatusCode, state: state);
                              }
                            } else {
                              RouteManager(ctx).popBack();
                              _cancelConfirmatiion(context, orderStatusCode: state.orderDetails.orderStatusCode, state: state);
                            }
                          },
                          style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.38, 50.0))),
                          child: const Text("CONTINUE"),
                        ),
                        ElevatedButton(
                          onPressed: () => RouteManager(ctx).popBack(),
                          style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.32, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.grey)),
                          child: Text(
                            "CANCEL",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _cancelConfirmatiion(BuildContext context, {required int orderStatusCode, required OrderDetailsState state}) {
    double width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fillColor,
        insetPadding: const EdgeInsets.all(15.0),
        title: SvgPicture.asset(AppAssets.errorIcon),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text("Are you sure you want to cancel your service?", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      RouteManager(ctx).popBack();
                      _cancelOrder(context, state: state);
                    },
                    style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.3, 50.0))),
                    child: const Text("YES"),
                  ),
                  const SizedBox(width: 20.0),
                  ElevatedButton(
                    onPressed: () => RouteManager(ctx).popBack(),
                    style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.32, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.grey)),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelOrder(BuildContext context, {required OrderDetailsState state}) async {
    if (state.dataState != DataState.loading) {
      bool cancelStatus = await BlocProvider.of<OrderDetailsCubit>(context).cancellingOrder();
      if (cancelStatus && context.mounted) {
        RouteManager(context).homePage();
      }
    }
  }

  Future<void> _checkingOrderStatus(BuildContext context, {required OrderDetailsState state, bool orderState = false}) async {
    if (state.dataState != DataState.loading && state.orderState != OrderState.loading) {
      bool orderStatus = await BlocProvider.of<OrderDetailsCubit>(context).fetchingOrderDetails(orderState: orderState);
      if (orderStatus && context.mounted) {
        OrderDetailsState state = context.read<OrderDetailsCubit>().state;
        if (state.orderDetails.orderStatusCode == 3 && !CommonFunction.fromGalleryPage) {
          RouteManager(context).galleryPage();
        } else if (state.orderDetails.orderStatusCode == 6) {
          RouteManager(context).homePage();
        }
      }
    }
  }

  void _reachSupportForCancel(BuildContext context) => showDialog(
    context: context,
    builder: (con) => AlertDialog(
      backgroundColor: AppColors.fillColor,
      title: SvgPicture.asset(AppAssets.errorIcon),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              "Since your order was already picked up for scanning, please reach out to us for further assistance.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => CommonFunction.openingExternalWebPage(API.cancelOrderURL),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Contact Us",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium!.copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.body7Color, color: AppColors.body7Color),
                    ),
                    Padding(padding: const EdgeInsets.only(left: 10.0), child: SvgPicture.asset(AppAssets.whatsappIcon)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
