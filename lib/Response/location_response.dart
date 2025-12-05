import 'package:dio/dio.dart';
import 'package:rusticgram/Response/api.dart';

class LocationResponse {
  Future<Response> autoCompleteResponse(String searchText) async => await API.clientService.post(
    API.autoCompleteAPI,
    data: {
      "input": searchText,
      "languageCode": "en",
      "includedRegionCodes": ["in"],
      "locationRestriction": {
        "rectangle": {
          "low": {"latitude": 6.5546079, "longitude": 68.1113787},
          "high": {"latitude": 35.6745457, "longitude": 97.395561},
        },
      },
    },
    options: Options(headers: {"X-Goog-Api-Key": API.googleAPIKey, "Content-Type": "application/json"}),
  );

  Future<Response> placeDetailResponse(String placeID) async => await API.clientService.get(
    API.placeDetailsAPI + placeID,
    options: Options(headers: {"X-Goog-Api-Key": API.googleAPIKey, "X-Goog-FieldMask": "formattedAddress,addressComponents,location,googleMapsLinks,addressDescriptor,googleMapsUri"}),
  );
}
