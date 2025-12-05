class ImageDBModel {
  final String imageName;
  final String imagePath;

  ImageDBModel({required this.imageName, required this.imagePath});

  factory ImageDBModel.fromJson(Map<String, dynamic> json) => ImageDBModel(imageName: json["imageName"] ?? "", imagePath: json["imagePath"] ?? "");

  Map<String, dynamic> toJson() => {"imageName": imageName, "imagePath": imagePath};
}
