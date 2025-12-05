class AutocompleteModel {
  final List<Suggestion> suggestions;

  AutocompleteModel({required this.suggestions});

  factory AutocompleteModel.fromJson(Map<String, dynamic> json) => AutocompleteModel(suggestions: List<Suggestion>.from((json["suggestions"] ?? []).map((x) => Suggestion.fromJson(x))));

  Map<String, dynamic> toJson() => {"suggestions": List<dynamic>.from(suggestions.map((x) => x.toJson()))};
}

class Suggestion {
  final PlacePrediction placePrediction;

  Suggestion({required this.placePrediction});

  factory Suggestion.fromJson(Map<String, dynamic> json) => Suggestion(placePrediction: PlacePrediction.fromJson(json["placePrediction"]));

  Map<String, dynamic> toJson() => {"placePrediction": placePrediction.toJson()};
}

class PlacePrediction {
  final String placeId;
  final FormattedAddress formattedAddress;

  PlacePrediction({required this.placeId, required this.formattedAddress});

  factory PlacePrediction.fromJson(Map<String, dynamic> json) => PlacePrediction(placeId: json["placeId"], formattedAddress: FormattedAddress.fromJson(json["text"]));

  Map<String, dynamic> toJson() => {"placeId": placeId, "text": formattedAddress.toJson()};
}

class FormattedAddress {
  final String text;

  FormattedAddress({required this.text});

  factory FormattedAddress.fromJson(Map<String, dynamic> json) => FormattedAddress(text: json["text"]);

  Map<String, dynamic> toJson() => {"text": text};
}
