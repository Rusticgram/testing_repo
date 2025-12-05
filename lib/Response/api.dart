import 'package:dio/dio.dart';

abstract class API {
  static bool isStaging = false;

  static const String _sandboxAPIKey = "1003.7eaf45d065ea6717442b455e55be7381.e17b18bfbd6ed90839eb2486fe5dba26";

  static const String _productionAPIKey = "1003.323b58df22f0de1063f4e3929a9e7d8d.40e1f8232db971b9ba2587648655a378";

  static const String googleAPIKey = "AIzaSyDOqYdOPTf21jrgyKCmjFEBuV8jTZZ_UoM";

  static String get _baseURL => isStaging ? "https://sandbox.zohoapis.in/crm/v7/functions" : "https://www.zohoapis.in/crm/v7/functions";

  static const String firebaseBaseURL = "-cujbbt4h2a-uc.a.run.app";

  static String get _auth => isStaging ? "/actions/execute?auth_type=apikey&zapikey=$_sandboxAPIKey" : "/actions/execute?auth_type=apikey&zapikey=$_productionAPIKey";

  static Uri privacyPolicyURL = Uri.parse("https://rusticgram.com/privacy-policy/");

  static Uri termsOfServiceURL = Uri.parse("https://rusticgram.com/terms-of-service/");

  static String get _whatsAppURL => "https://wa.me/919500382009?text=";

  static Uri customerSupport = Uri.parse(_whatsAppURL);

  static Uri cancelOrderURL = Uri.parse("${_whatsAppURL}Hello!%20I%20would%20like%20to%20cancel%20my%20order.");

  static Uri reactivateURL = Uri.parse("${_whatsAppURL}Hello!%20I%20need%20to%20reactivate%20my%20account.");

  static Uri maintainceOrderURL = Uri.parse("${_whatsAppURL}Hello!%20I%20noticed%20that%20the%20app%20is%20under%20maintenance.%20I%20need%20assistance.");

  static Uri deleteAccountURL = Uri.parse("${_whatsAppURL}Hello!%20I%20Want%20to%20delete%20my%20account.");

  static Dio get clientService => Dio(BaseOptions(baseUrl: _baseURL, sendTimeout: const Duration(minutes: 2)));

  static String newUserAPI = "/createprofile$_auth";

  static String userDetailsAPI = "/profiledetails$_auth";

  static String updateAddressAPI = "/updateaddress$_auth";

  static String updateProfilePicAPI = "/updateprofileimage$_auth";

  static String requestDeleteAPI = "/deleterequest$_auth";

  static String deleteAccountAPI = "/deleteaccount$_auth";

  static String updateFCMAPI = "/updatefcm$_auth";

  static String newOrderAPI = "/createorder$_auth";

  static String orderDetailsAPI = "/orderdetails$_auth";

  static String scheduleOrderAPI = "/scheduleupdate$_auth";

  static String orderCancelAPI = "/cancelorder$_auth";

  static String get paymentOrderIdAPI => isStaging ? "https://stagingCreatePaymentOrderID$firebaseBaseURL" : "https://createPaymentOrderID$firebaseBaseURL";

  static String planListAPI = "/paymentplanlist$_auth";

  static String get createSubscriptionAPI => isStaging ? "https://stagingCreateSubscription$firebaseBaseURL" : "https://createSubscription$firebaseBaseURL";

  static String updatePaymentDetailsAPI = "/updatepaymentdetails$_auth";

  static String get cancelSubscriptionAPI => isStaging ? "https://stagingCancelSubscription$firebaseBaseURL" : "https://cancelSubscription$firebaseBaseURL";

  static String bugReportAPI = "/bugreport$_auth";

  static String feedbackAPI = "/updatefeedback$_auth";

  static String autoCompleteAPI = "https://places.googleapis.com/v1/places:autocomplete";

  static String placeDetailsAPI = "https://places.googleapis.com/v1/places/";
}
