class OrderDetailsModel {
  final bool status;
  final String message;
  final OrderDetails orderDetails;

  OrderDetailsModel({required this.status, required this.message, required this.orderDetails});

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailsModel(status: json["status"] ?? false, message: json["message"] ?? "Something went wrong. Please try again.", orderDetails: OrderDetails.fromJson(json["data"] ?? {}));

  Map<String, dynamic> toJson() => {"status": status, "message": message, "data": orderDetails.toJson()};
}

class OrderDetails {
  final String id;
  final String createdDate;
  final String folderId;
  final String dealName;
  final String orderStatus;
  final int orderStatusCode;
  final String noOfPhotos;
  final ImageLinks imageLinks;
  final String pickupDateTime;
  final String pickupEndTime;
  final String deliveryDateTime;
  final String deliveryEndTime;
  final PaymentDetails paymentDetails;
  final String invoiceLink;
  final String feedbackLink;

  OrderDetails({
    required this.id,
    required this.createdDate,
    required this.folderId,
    required this.dealName,
    required this.orderStatus,
    required this.orderStatusCode,
    required this.noOfPhotos,
    required this.imageLinks,
    required this.pickupDateTime,
    required this.pickupEndTime,
    required this.deliveryDateTime,
    required this.deliveryEndTime,
    required this.paymentDetails,
    required this.invoiceLink,
    required this.feedbackLink,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) => OrderDetails(
    id: json["id"] ?? "",
    createdDate: json["createdDate"] ?? "",
    folderId: json["folderId"] ?? "",
    dealName: json["dealName"] ?? "",
    orderStatus: json["orderStatus"] ?? "",
    orderStatusCode: json["orderStatusCode"] ?? 0,
    noOfPhotos: json["noOfPhotos"]?.toString() ?? "x",
    imageLinks: ImageLinks.fromJson(json["imageLinks"] ?? {}),
    pickupDateTime: json["pickupStart"] ?? "",
    pickupEndTime: json["pickupEnd"] ?? "",
    deliveryDateTime: json["deliveryStart"] ?? "",
    deliveryEndTime: json["deliveryEnd"] ?? "",
    paymentDetails: PaymentDetails.fromJson(json["paymentDetails"] ?? {}),
    invoiceLink: json["invoiceLink"] ?? "",
    feedbackLink: json["feedbackLink"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "createdDate": createdDate,
    "folderId": folderId,
    "dealName": dealName,
    "stage": orderStatus,
    "orderStatusCode": orderStatusCode,
    "noOfPhotos": noOfPhotos,
    "imageLinks": imageLinks.toJson(),
    "pickupDateTime": pickupDateTime,
    "pickupEndTime": pickupEndTime,
    "deliveryDateTime": deliveryDateTime,
    "deliveryEndTime": deliveryEndTime,
    "paymentDetails": paymentDetails.toJson(),
    "invoiceLink": invoiceLink,
    "feedbackLink": feedbackLink,
  };
}

class PaymentDetails {
  final int base;
  final int total;
  final int amountPaid;
  final int discountAmount;
  final String subscriptionID;
  final String subscriptionStatus;
  final bool paymentStatus;

  PaymentDetails({
    required this.base,
    required this.total,
    required this.amountPaid,
    required this.discountAmount,
    required this.subscriptionID,
    required this.subscriptionStatus,
    required this.paymentStatus,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(
    base: json["base"] ?? 0,
    total: json["total"] ?? 0,
    amountPaid: json["amountPaid"] ?? 0,
    discountAmount: json["discountAmount"] ?? 0,
    subscriptionID: json["subscriptionID"] ?? "",
    subscriptionStatus: json["subscriptionStatus"] ?? "",
    paymentStatus: json["paymentStatus"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "base": base,
    "total": total,
    "amountPaid": amountPaid,
    "discountAmount": discountAmount,
    "subscriptionID": subscriptionID,
    "subscriptionStatus": subscriptionStatus,
    "paymentStatus": paymentStatus,
  };
}

class ImageLinks {
  final String createdAt;
  final int totalCount;
  final List<DownloadLinks> downloadLinks;

  ImageLinks({required this.createdAt, required this.totalCount, required this.downloadLinks});

  factory ImageLinks.fromJson(Map<String, dynamic> json) => ImageLinks(
    createdAt: json["createdAt"] ?? "",
    totalCount: json["totalCount"] ?? 0,
    downloadLinks: List<DownloadLinks>.from((json["links"] ?? []).map((x) => DownloadLinks.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {"createdAt": createdAt, "totalCount": totalCount, "downloadLinks": List<dynamic>.from(downloadLinks.map((x) => x))};
}

class DownloadLinks {
  final String fileName;
  final String downloadLink;

  DownloadLinks({required this.fileName, required this.downloadLink});

  factory DownloadLinks.fromJson(Map<String, dynamic> json) => DownloadLinks(fileName: json["fileName"] ?? "", downloadLink: json["downloadLink"] ?? "");

  Map<String, dynamic> toJson() => {"fileName": fileName, "downloadLink": downloadLink};
}
