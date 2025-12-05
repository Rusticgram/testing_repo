import 'package:dio/dio.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/api.dart';

class UserResponse {
  Future<Response> newUserResponse(String data) async => await API.clientService.get(API.newUserAPI, queryParameters: {"data": data});

  Future<Response> userDetailsResponse() async => await API.clientService.get(API.userDetailsAPI, queryParameters: {"mobile": phoneNumber});

  Future<Response> updatingAddressResponse(String data) async => await API.clientService.get(API.updateAddressAPI, queryParameters: {"data": data});

  Future<Response> updateProfilePicResponse(String data) async => API.clientService.get(API.updateProfilePicAPI, queryParameters: {"data": data});

  Future<Response> deleteRequest(String requestDetails) async => API.clientService.get(API.requestDeleteAPI, queryParameters: {"data": requestDetails});

  Future<Response> deleteProfileResponse(String deleteData) async => API.clientService.get(API.deleteAccountAPI, queryParameters: {"data": deleteData});

  Future<Response> bugReportResponse(String data) async => await API.clientService.get(API.bugReportAPI, queryParameters: {"data": data});
}
