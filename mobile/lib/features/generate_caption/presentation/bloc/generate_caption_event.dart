part of 'generate_caption_bloc.dart';

sealed class GenerateCaptionEvent extends Equatable {
  const GenerateCaptionEvent();

  @override
  List<Object?> get props => [];
}

/// Pick images from gallery
class PickImagesFromGalleryEvent extends GenerateCaptionEvent {
  const PickImagesFromGalleryEvent();
}

/// Take photo from camera
class TakePhotoEvent extends GenerateCaptionEvent {
  const TakePhotoEvent();
}

/// Remove an image at specific index
class RemoveImageEvent extends GenerateCaptionEvent {
  const RemoveImageEvent(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

/// Update product description
class UpdateDescriptionEvent extends GenerateCaptionEvent {
  const UpdateDescriptionEvent(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

/// Generate caption for selected images
class GenerateCaptionSubmitEvent extends GenerateCaptionEvent {
  const GenerateCaptionSubmitEvent();
}

/// Reset to initial state
class ResetGenerateCaptionEvent extends GenerateCaptionEvent {
  const ResetGenerateCaptionEvent();
}
