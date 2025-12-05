import 'package:dio/dio.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/api.dart';

class OrderResponse {
  Future<Response> newOrderResponse(String data) async => await API.clientService.get(API.newOrderAPI, queryParameters: {"data": data});

  Future<Response> orderDetailsResponse() async => await API.clientService.get(API.orderDetailsAPI, queryParameters: {"userID": userDetailsModel.userDetails.id});

  Future<Response> scheduleOrderResponse(String data) async => await API.clientService.get(API.scheduleOrderAPI, queryParameters: {"data": data});

  Future<Response> orderCancelResponse(String data) async => API.clientService.get(API.orderCancelAPI, queryParameters: {"data": data});

  Future<Response> planListResponse() async => await API.clientService.get(API.planListAPI);

  Future<Response> orderIDResponse(Map<String, dynamic> orderDetails) async => await API.clientService.post(API.paymentOrderIdAPI, data: orderDetails);

  Future<Response> subscriptionResponse(Map<String, dynamic> subscriptionDetails) async => await API.clientService.post(API.createSubscriptionAPI, data: subscriptionDetails);

  Future<Response> updatePaymentDetailsResponse(String data) async => await API.clientService.get(API.updatePaymentDetailsAPI, queryParameters: {"data": data});

  Future<Response> cancelSubscriptionResponse(String subscriptionID) async => await API.clientService.get(API.cancelSubscriptionAPI, queryParameters: {"subscriptionID": subscriptionID});

  Future<Response> feedbackResponse(String data) async => await API.clientService.get(API.feedbackAPI, queryParameters: {"data": data});
}
