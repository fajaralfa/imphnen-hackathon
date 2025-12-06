/// Response model for caption generation API.
class GenerateCaptionResponseModel {
  const GenerateCaptionResponseModel({required this.caption});

  factory GenerateCaptionResponseModel.fromJson(Map<String, dynamic> json) {
    return GenerateCaptionResponseModel(
      caption: json['caption'] as String,
    );
  }

  final String caption;

  Map<String, dynamic> toJson() {
    return {'caption': caption};
  }
}
