part of 'order_details_cubit.dart';

class OrderDetailsState {
  final DataState dataState;
  final OrderState orderState;
  final OrderDetails orderDetails;
  final List<bool> activeSteps;
  final List<PlanDetails> planList;
  final List<String> cancelReasons;
  final int selectedReason;
  final String cancelError;
  final String feedbackError;
  final String errorMessage;

  const OrderDetailsState({
    required this.dataState,
    required this.orderState,
    required this.orderDetails,
    required this.activeSteps,
    required this.planList,
    required this.cancelReasons,
    required this.selectedReason,
    required this.cancelError,
    required this.feedbackError,
    required this.errorMessage,
  });

  factory OrderDetailsState.initial() => OrderDetailsState(
    dataState: DataState.loading,
    orderState: OrderState.initial,
    orderDetails: OrderDetails.fromJson({}),
    activeSteps: [],
    planList: [],
    cancelReasons: ["Found a better alternative", "Delay in pickup", "Change of mind", "Ordered by mistake", "Other"],
    selectedReason: -1,
    cancelError: "",
    feedbackError: "",
    errorMessage: "",
  );

  OrderDetailsState copyWith({
    DataState? dataState,
    OrderState? orderState,
    OrderDetails? orderDetails,
    List<bool>? activeSteps,
    List<PlanDetails>? planList,
    List<String>? cancelReasons,
    int? selectedReason,
    String? cancelError,
    String? feedbackError,
    String? errorMessage,
  }) {
    return OrderDetailsState(
      dataState: dataState ?? this.dataState,
      orderState: orderState ?? this.orderState,
      orderDetails: orderDetails ?? this.orderDetails,
      activeSteps: activeSteps ?? this.activeSteps,
      planList: planList ?? this.planList,
      cancelReasons: cancelReasons ?? this.cancelReasons,
      selectedReason: selectedReason ?? this.selectedReason,
      cancelError: cancelError ?? this.cancelError,
      feedbackError: feedbackError ?? this.feedbackError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
