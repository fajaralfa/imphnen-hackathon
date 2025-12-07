part of 'generate_caption_bloc.dart';

enum GenerateCaptionStatus {
  initial,
  pickingImages,
  imagesSelected,
  generating,
  success,
  failure,
  authFailure, // Triggers auto-logout when token is invalid/expired
}

class GenerateCaptionState extends Equatable {
  const GenerateCaptionState({
    this.status = GenerateCaptionStatus.initial,
    this.images = const [],
    this.description = '',
    this.caption,
    this.errorMessage,
  });

  final GenerateCaptionStatus status;
  final List<File> images;
  final String description;
  final String? caption;
  final String? errorMessage;

  /// Maximum number of images allowed
  static const int maxImages = 5;

  /// Check if more images can be added
  bool get canAddMoreImages => images.length < maxImages;

  /// Check if ready to generate (at least 1 image)
  bool get canGenerate => images.isNotEmpty;

  /// Remaining slots for images
  int get remainingSlots => maxImages - images.length;

  GenerateCaptionState copyWith({
    GenerateCaptionStatus? status,
    List<File>? images,
    String? description,
    String? caption,
    String? errorMessage,
  }) {
    return GenerateCaptionState(
      status: status ?? this.status,
      images: images ?? this.images,
      description: description ?? this.description,
      caption: caption ?? this.caption,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, images, description, caption, errorMessage];
}
