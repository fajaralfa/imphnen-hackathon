import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imphenhackaton/core/di/injection_container.dart';
import 'package:imphenhackaton/features/auth/presentation/pages/login_page.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/bloc/generate_caption_bloc.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/result_page.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/widgets/description.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/widgets/dropfile_field.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/widgets/image_source_picker.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/widgets/title.dart';

class GenerateCaptionPage extends StatelessWidget {
  const GenerateCaptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GenerateCaptionBloc>(),
      child: const GenerateCaptionView(),
    );
  }
}

class GenerateCaptionView extends StatelessWidget {
  const GenerateCaptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return BlocConsumer<GenerateCaptionBloc, GenerateCaptionState>(
      listener: (context, state) {
        // Show error snackbar
        if (state.status == GenerateCaptionStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // Handle auth failure - auto logout and navigate to login
        if (state.status == GenerateCaptionStatus.authFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Session expired'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Navigate to login page and clear navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (context) => const LoginPage(),
            ),
            (route) => false,
          );
        }

        // Navigate to result page on success
        if (state.status == GenerateCaptionStatus.success &&
            state.caption != null) {
          showResultPage(
            context,
            imageFiles: state.images,
            caption: state.caption!,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // Background gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    width: width,
                    fit: BoxFit.cover,
                    'assets/png/bottomgr.png',
                  ),
                ),
              ),
              // Main content
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 35,
                        right: 35,
                        top: 50,
                        bottom: 20,
                      ),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: TitleWidget(),
                          ),
                          const SizedBox(height: 35),
                          DropfileField(
                            width: width,
                            height: height,
                            images: state.images,
                            onTap: () => _showImagePicker(context, state),
                            onRemoveImage: (index) {
                              context.read<GenerateCaptionBloc>().add(
                                    RemoveImageEvent(index),
                                  );
                            },
                          ),
                          const SizedBox(height: 25),
                          const DescriptionWidget(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  // Bottom buttons
                  _BottomButtons(
                    state: state,
                    onAddTap: () => _showImagePicker(context, state),
                    onGenerateTap: () {
                      context.read<GenerateCaptionBloc>().add(
                            const GenerateCaptionSubmitEvent(),
                          );
                    },
                  ),
                ],
              ),
              // Loading overlay
              if (state.status == GenerateCaptionStatus.generating)
                ColoredBox(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF6C8AF6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Membuat caption...',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePicker(BuildContext context, GenerateCaptionState state) {
    if (!state.canAddMoreImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maksimal ${GenerateCaptionState.maxImages} gambar',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ImageSourcePicker.show(
      context,
      remainingSlots: state.remainingSlots,
      onCameraTap: () {
        context.read<GenerateCaptionBloc>().add(const TakePhotoEvent());
      },
      onGalleryTap: () {
        context.read<GenerateCaptionBloc>().add(
              const PickImagesFromGalleryEvent(),
            );
      },
    );
  }
}

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    required this.state,
    required this.onAddTap,
    required this.onGenerateTap,
  });

  final GenerateCaptionState state;
  final VoidCallback onAddTap;
  final VoidCallback onGenerateTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 30,
        top: 8,
      ),
      child: Row(
        children: [
          // Add more images button
          Material(
            color: state.canAddMoreImages
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.3),
            shape: const CircleBorder(
              side: BorderSide(color: Color(0xfff9f9f9)),
            ),
            child: InkWell(
              onTap: state.canAddMoreImages ? onAddTap : null,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Badge(
                  isLabelVisible: state.images.isNotEmpty,
                  label: Text('${state.images.length}'),
                  backgroundColor: const Color(0xFF6C8AF6),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 20,
                    color: state.canAddMoreImages ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Generate button
          Expanded(
            child: Material(
              color: state.canGenerate
                  ? const Color(0xFF6C8AF6)
                  : const Color.fromARGB(255, 211, 213, 221),
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: state.canGenerate ? onGenerateTap : null,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: state.canGenerate
                          ? Colors.transparent
                          : const Color.fromARGB(255, 211, 213, 221),
                      // : const Color(0xfff9f9f9),
                    ),
                  ),
                  child: Text(
                    state.images.isEmpty
                        ? 'Pilih Foto Dulu'
                        : 'Generate Caption',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      // Disabled text now uses primary color for better contrast
                      color: state.canGenerate
                          ? Colors.white
                          : const Color(0xFF6C8AF6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
