class PlanListModel {
  final bool status;
  final String message;
  final List<PlanDetails> data;

  PlanListModel({required this.status, required this.message, required this.data});

  factory PlanListModel.fromJson(Map<String, dynamic> json) => PlanListModel(
    status: json["status"] ?? false,
    message: json["message"] ?? "Something went wrong. Please try again.",
    data: List<PlanDetails>.from((json["data"] ?? []).map((x) => PlanDetails.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {"status": status, "message": message, "data": List<dynamic>.from(data.map((x) => x.toJson()))};
}

class PlanDetails {
  final String name;
  final String planId;
  final int actualAmount;
  final int finalAmount;
  final int offerPercentage;
  final String currencyType;
  final String period;
  final String unit;
  final String interval;

  PlanDetails({
    required this.name,
    required this.planId,
    required this.actualAmount,
    required this.finalAmount,
    required this.offerPercentage,
    required this.currencyType,
    required this.period,
    required this.unit,
    required this.interval,
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) => PlanDetails(
    name: json["name"] ?? "",
    planId: json["planID"] ?? "",
    actualAmount: json["actualAmount"] ?? 0,
    finalAmount: json["finalAmount"] ?? 0,
    offerPercentage: json["offerPercentage"] ?? 0,
    currencyType: json["currencyType"] ?? "",
    period: json["period"] ?? "",
    unit: json["unit"] ?? "",
    interval: json["interval"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "planID": planId,
    "actualAmount": actualAmount,
    "finalAmount": finalAmount,
    "offerPercentage": offerPercentage,
    "currencyType": currencyType,
    "period": period,
    "unit": unit,
    "interval": interval,
  };
}
