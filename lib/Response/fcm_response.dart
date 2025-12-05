import 'package:dio/dio.dart';
import 'package:rusticgram/Response/api.dart';

class FcmResponse {
  Future<Response> fcmResponse(String data) async => API.clientService.get(API.updateFCMAPI, queryParameters: {"data": data});
}
