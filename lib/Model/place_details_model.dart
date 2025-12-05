class PlaceDetailsModel {
  final String formattedAddress;
  final List<AddressComponent> addressComponents;
  final Location location;
  final String googleMapsUri;
  final AddressDescriptor addressDescriptor;
  final GoogleMapsLinks googleMapsLinks;

  PlaceDetailsModel({
    required this.formattedAddress,
    required this.addressComponents,
    required this.location,
    required this.googleMapsUri,
    required this.addressDescriptor,
    required this.googleMapsLinks,
  });

  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) => PlaceDetailsModel(
    formattedAddress: json["formattedAddress"] ?? "",
    addressComponents: List<AddressComponent>.from((json["addressComponents"] ?? []).map((x) => AddressComponent.fromJson(x))),
    location: Location.fromJson(json["location"] ?? {}),
    googleMapsUri: json["googleMapsUri"] ?? "",
    addressDescriptor: AddressDescriptor.fromJson(json["addressDescriptor"] ?? {}),
    googleMapsLinks: GoogleMapsLinks.fromJson(json["googleMapsLinks"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "formattedAddress": formattedAddress,
    "addressComponents": List<dynamic>.from(addressComponents.map((x) => x.toJson())),
    "location": location.toJson(),
    "googleMapsUri": googleMapsUri,
    "addressDescriptor": addressDescriptor.toJson(),
    "googleMapsLinks": googleMapsLinks.toJson(),
  };
}

class AddressComponent {
  final String longText;
  final String shortText;
  final List<String> types;
  final String languageCode;

  AddressComponent({required this.longText, required this.shortText, required this.types, required this.languageCode});

  factory AddressComponent.fromJson(Map<String, dynamic> json) => AddressComponent(
    longText: json["longText"] ?? "",
    shortText: json["shortText"] ?? "",
    types: List<String>.from((json["types"] ?? []).map((x) => x)),
    languageCode: json["languageCode"] ?? "",
  );

  Map<String, dynamic> toJson() => {"longText": longText, "shortText": shortText, "types": List<dynamic>.from(types.map((x) => x)), "languageCode": languageCode};
}

class AddressDescriptor {
  final List<Landmark> landmarks;
  final List<Area> areas;

  AddressDescriptor({required this.landmarks, required this.areas});

  factory AddressDescriptor.fromJson(Map<String, dynamic> json) => AddressDescriptor(
    landmarks: List<Landmark>.from((json["landmarks"] ?? []).map((x) => Landmark.fromJson(x))),
    areas: List<Area>.from((json["areas"] ?? []).map((x) => Area.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {"landmarks": List<dynamic>.from(landmarks.map((x) => x.toJson())), "areas": List<dynamic>.from(areas.map((x) => x.toJson()))};
}

class Area {
  final String name;
  final String placeId;
  final DisplayName displayName;
  final String containment;

  Area({required this.name, required this.placeId, required this.displayName, required this.containment});

  factory Area.fromJson(Map<String, dynamic> json) =>
      Area(name: json["name"] ?? "", placeId: json["placeId"] ?? "", displayName: DisplayName.fromJson(json["displayName"] ?? {}), containment: json["containment"] ?? "");

  Map<String, dynamic> toJson() => {"name": name, "placeId": placeId, "displayName": displayName.toJson(), "containment": containment};
}

class DisplayName {
  final String text;
  final String languageCode;

  DisplayName({required this.text, required this.languageCode});

  factory DisplayName.fromJson(Map<String, dynamic> json) => DisplayName(text: json["text"] ?? "", languageCode: json["languageCode"] ?? "");

  Map<String, dynamic> toJson() => {"text": text, "languageCode": languageCode};
}

class Landmark {
  final String name;
  final String placeId;
  final DisplayName displayName;
  final List<String> types;
  final double straightLineDistanceMeters;
  final double travelDistanceMeters;
  final String spatialRelationship;

  Landmark({
    required this.name,
    required this.placeId,
    required this.displayName,
    required this.types,
    required this.straightLineDistanceMeters,
    required this.travelDistanceMeters,
    required this.spatialRelationship,
  });

  factory Landmark.fromJson(Map<String, dynamic> json) => Landmark(
    name: json["name"] ?? "",
    placeId: json["placeId"] ?? "",
    displayName: DisplayName.fromJson(json["displayName"] ?? {}),
    types: List<String>.from((json["types"] ?? []).map((x) => x)),
    straightLineDistanceMeters: json["straightLineDistanceMeters"] ?? 0.0,
    travelDistanceMeters: json["travelDistanceMeters"] ?? 0.0,
    spatialRelationship: json["spatialRelationship"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "placeId": placeId,
    "displayName": displayName.toJson(),
    "types": List<dynamic>.from(types.map((x) => x)),
    "straightLineDistanceMeters": straightLineDistanceMeters,
    "travelDistanceMeters": travelDistanceMeters,
    "spatialRelationship": spatialRelationship,
  };
}

class GoogleMapsLinks {
  final String directionsUri;
  final String placeUri;

  GoogleMapsLinks({required this.directionsUri, required this.placeUri});

  factory GoogleMapsLinks.fromJson(Map<String, dynamic> json) => GoogleMapsLinks(directionsUri: json["directionsUri"] ?? "", placeUri: json["placeUri"] ?? "");

  Map<String, dynamic> toJson() => {"directionsUri": directionsUri, "placeUri": placeUri};
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) => Location(latitude: json["latitude"] ?? 0.0, longitude: json["longitude"] ?? 0.0);

  Map<String, dynamic> toJson() => {"latitude": latitude, "longitude": longitude};
}
