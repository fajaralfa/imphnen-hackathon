import 'package:image_picker/image_picker.dart';
import 'package:imphenhackaton/core/error/exceptions.dart';

/// Local data source for image picking operations.
abstract class GenerateCaptionLocalDataSource {
  /// Pick multiple images from gallery.
  Future<List<XFile>> pickImagesFromGallery({int maxImages = 5});

  /// Take a photo using camera.
  Future<XFile?> pickImageFromCamera();
}

/// Implementation using image_picker package.
class GenerateCaptionLocalDataSourceImpl
    implements GenerateCaptionLocalDataSource {
  GenerateCaptionLocalDataSourceImpl({required ImagePicker imagePicker})
      : _imagePicker = imagePicker;

  final ImagePicker _imagePicker;

  @override
  Future<List<XFile>> pickImagesFromGallery({int maxImages = 5}) async {
    try {
      final images = await _imagePicker.pickMultiImage(
        limit: maxImages,
        imageQuality: 80,
      );
      return images;
    } catch (e) {
      throw const CacheException();
    }
  }

  @override
  Future<XFile?> pickImageFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      throw const CacheException();
    }
  }
}
