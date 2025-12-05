class UserDetailsModel {
  final bool status;
  final String message;
  final UserDetails userDetails;

  UserDetailsModel({required this.status, required this.message, required this.userDetails});

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) =>
      UserDetailsModel(status: json["status"] ?? false, message: json["message"] ?? "Something went wrong", userDetails: UserDetails.fromJson(json["data"] ?? {}));

  Map<String, dynamic> toJson() => {"status": status, "message": message, "data": userDetails.toJson()};
}

class UserDetails {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserAddress address;
  final bool profileStatus;
  final String fcmKey;
  final String profileImage;

  UserDetails({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.profileStatus,
    required this.fcmKey,
    required this.profileImage,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    phone: json["phone"] ?? "",
    email: json["email"] ?? "",
    address: UserAddress.fromJson(json["address"] ?? {}),
    profileStatus: json["profileStatus"] ?? true,
    fcmKey: json["fcmKey"] ?? "",
    profileImage: json["profileImage"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "fullName": name,
    "phone": phone,
    "email": email,
    "address": address.toJson(),
    "profileStatus": profileStatus,
    "fcmKey": fcmKey,
    "profileImage": profileImage,
  };
}

class UserAddress {
  final String flat;
  final String area;
  final String town;
  final String pincode;
  final String state;
  final String country;
  final String landmark;
  final String formattedAddress;

  UserAddress({
    required this.flat,
    required this.area,
    required this.town,
    required this.pincode,
    required this.state,
    required this.country,
    required this.landmark,
    required this.formattedAddress,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
    flat: json["flatNo"] ?? "",
    area: json["area"] ?? "",
    town: json["town"] ?? "",
    pincode: json["pincode"] ?? "",
    state: json["state"] ?? "",
    country: json["country"] ?? "",
    landmark: json["landmark"] ?? "",
    formattedAddress: json["formattedAddress"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "flatNo": flat,
    "area": area,
    "town": town,
    "pincode": pincode,
    "state": state,
    "country": country,
    "landmark": landmark,
    "formattedAddress": formattedAddress,
  };
}
