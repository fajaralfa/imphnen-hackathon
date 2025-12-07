import 'dart:io';

import 'package:equatable/equatable.dart';

/// Entity representing the state of caption generation.
class GenerateCaptionEntity extends Equatable {
  const GenerateCaptionEntity({
    this.images = const [],
    this.description = '',
    this.caption,
  });

  /// Selected images (max 5)
  final List<File> images;

  /// User's product description
  final String description;

  /// Generated caption (null until API returns result)
  final String? caption;

  /// Maximum number of images allowed
  static const int maxImages = 5;

  /// Check if more images can be added
  bool get canAddMoreImages => images.length < maxImages;

  /// Check if ready to generate (at least 1 image)
  bool get canGenerate => images.isNotEmpty;

  /// Remaining slots for images
  int get remainingSlots => maxImages - images.length;

  GenerateCaptionEntity copyWith({
    List<File>? images,
    String? description,
    String? caption,
  }) {
    return GenerateCaptionEntity(
      images: images ?? this.images,
      description: description ?? this.description,
      caption: caption ?? this.caption,
    );
  }

  @override
  List<Object?> get props => [images, description, caption];
}
