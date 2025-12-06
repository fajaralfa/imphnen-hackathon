import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:imphenhackaton/core/error/failures.dart';

/// Repository interface for caption generation feature.
abstract class GenerateCaptionRepository {
  /// Pick multiple images from gallery.
  /// Returns list of selected images (respects maxImages limit).
  Future<Either<Failure, List<File>>> pickImagesFromGallery({
    int maxImages = 5,
  });

  /// Take a photo using camera.
  /// Returns the captured image file.
  Future<Either<Failure, File>> pickImageFromCamera();

  /// Generate caption for the given images.
  /// [images] - List of product images
  /// [description] - Optional product description
  /// Returns generated caption string.
  Future<Either<Failure, String>> generateCaption({
    required List<File> images,
    String? description,
  });
}
