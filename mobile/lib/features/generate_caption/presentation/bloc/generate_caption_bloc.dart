import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imphenhackaton/core/error/failures.dart';
import 'package:imphenhackaton/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:imphenhackaton/features/generate_caption/domain/repositories/generate_caption_repository.dart';

part 'generate_caption_event.dart';
part 'generate_caption_state.dart';

class GenerateCaptionBloc
    extends Bloc<GenerateCaptionEvent, GenerateCaptionState> {
  GenerateCaptionBloc({
    required GenerateCaptionRepository repository,
    required AuthLocalDataSource authLocalDataSource,
  })  : _repository = repository,
        _authLocalDataSource = authLocalDataSource,
        super(const GenerateCaptionState()) {
    on<PickImagesFromGalleryEvent>(_onPickImagesFromGallery);
    on<TakePhotoEvent>(_onTakePhoto);
    on<RemoveImageEvent>(_onRemoveImage);
    on<UpdateDescriptionEvent>(_onUpdateDescription);
    on<GenerateCaptionSubmitEvent>(_onGenerateCaption);
    on<ResetGenerateCaptionEvent>(_onReset);
  }

  final GenerateCaptionRepository _repository;
  final AuthLocalDataSource _authLocalDataSource;

  Future<void> _onPickImagesFromGallery(
    PickImagesFromGalleryEvent event,
    Emitter<GenerateCaptionState> emit,
  ) async {
    emit(state.copyWith(status: GenerateCaptionStatus.pickingImages));

    final result = await _repository.pickImagesFromGallery(
      maxImages: state.remainingSlots,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: GenerateCaptionStatus.failure,
          errorMessage: 'Gagal memilih gambar',
        ),
      ),
      (newImages) {
        if (newImages.isEmpty) {
          emit(
            state.copyWith(
              status: state.images.isEmpty
                  ? GenerateCaptionStatus.initial
                  : GenerateCaptionStatus.imagesSelected,
            ),
          );
        } else {
          final allImages = [...state.images, ...newImages];
          final limitedImages =
              allImages.take(GenerateCaptionState.maxImages).toList();
          emit(
            state.copyWith(
              status: GenerateCaptionStatus.imagesSelected,
              images: limitedImages,
            ),
          );
        }
      },
    );
  }

  Future<void> _onTakePhoto(
    TakePhotoEvent event,
    Emitter<GenerateCaptionState> emit,
  ) async {
    if (!state.canAddMoreImages) {
      emit(
        state.copyWith(
          status: GenerateCaptionStatus.failure,
          errorMessage: 'Maksimal ${GenerateCaptionState.maxImages} gambar',
        ),
      );
      return;
    }

    emit(state.copyWith(status: GenerateCaptionStatus.pickingImages));

    final result = await _repository.pickImageFromCamera();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: state.images.isEmpty
              ? GenerateCaptionStatus.initial
              : GenerateCaptionStatus.imagesSelected,
        ),
      ),
      (image) => emit(
        state.copyWith(
          status: GenerateCaptionStatus.imagesSelected,
          images: [...state.images, image],
        ),
      ),
    );
  }

  void _onRemoveImage(
    RemoveImageEvent event,
    Emitter<GenerateCaptionState> emit,
  ) {
    final newImages = List<File>.from(state.images)..removeAt(event.index);
    emit(
      state.copyWith(
        status: newImages.isEmpty
            ? GenerateCaptionStatus.initial
            : GenerateCaptionStatus.imagesSelected,
        images: newImages,
      ),
    );
  }

  void _onUpdateDescription(
    UpdateDescriptionEvent event,
    Emitter<GenerateCaptionState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  Future<void> _onGenerateCaption(
    GenerateCaptionSubmitEvent event,
    Emitter<GenerateCaptionState> emit,
  ) async {
    if (!state.canGenerate) return;

    final isTokenExpired = await _authLocalDataSource.isTokenExpired();
    if (isTokenExpired) {
      emit(
        state.copyWith(
          status: GenerateCaptionStatus.authFailure,
          errorMessage: 'Session expired. Please login again.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: GenerateCaptionStatus.generating));

    final result = await _repository.generateCaption(
      images: state.images,
      description: state.description.isNotEmpty ? state.description : null,
    );

    result.fold(
      (failure) {
        if (failure is AuthFailure) {
          // Auth failure - trigger auto-logout
          emit(
            state.copyWith(
              status: GenerateCaptionStatus.authFailure,
              errorMessage:
                  failure.message ?? 'Session expired. Please login again.',
            ),
          );
        } else {
          // Other failures
          final message = failure is GeneralFailure
              ? failure.message
              : 'Gagal membuat caption';
          emit(
            state.copyWith(
              status: GenerateCaptionStatus.failure,
              errorMessage: message,
            ),
          );
        }
      },
      (caption) => emit(
        state.copyWith(
          status: GenerateCaptionStatus.success,
          caption: caption,
        ),
      ),
    );
  }

  void _onReset(
    ResetGenerateCaptionEvent event,
    Emitter<GenerateCaptionState> emit,
  ) {
    emit(const GenerateCaptionState());
  }
}
