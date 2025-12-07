import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imphenhackaton/features/generate_caption/generate_caption.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/widgets/image_carousel.dart';
import 'package:share_plus/share_plus.dart';

/// Shows the result page as a fullscreen bottom sheet.
///
/// [imageFiles] - List of image files from gallery/camera (max 5)
/// [caption] - The generated caption text
Future<void> showResultPage(
  BuildContext context, {
  required List<File> imageFiles,
  required String caption,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // builder: (context) => BlocProvider.value(
    //   value: context.read<GenerateCaptionBloc>(),
    //   child: ResultPage(
    //     imageFiles: imageFiles,
    //     caption: caption,
    //   ),
    // ),
    builder: (context) => ResultPage(
      imageFiles: imageFiles,
      caption: caption,
    ),
  );
}

class ResultPage extends StatefulWidget {
  const ResultPage({
    required this.imageFiles,
    required this.caption,
    super.key,
  });

  final List<File> imageFiles;
  final String caption;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isCopied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.caption));
    setState(() => _isCopied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Caption berhasil disalin!',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: const Color(0xFF6C8AF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  Future<void> _shareContent(BuildContext context) async {
    final xFiles = widget.imageFiles.map((f) => XFile(f.path)).toList();
    // Share.shareXFiles(xFiles, text: widget.caption);

    _copyToClipboard();

    final result = await Share.shareXFiles(
      xFiles,
      text: widget.caption,
    );

    print('Share result: ${result.status}');

    if (result.status == ShareResultStatus.success) {
      if (context.mounted) {
        // context
        //     .read<GenerateCaptionBloc>()
        //     .add(const ResetGenerateCaptionEvent());
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Caption dan gambar berhasil dibagikan!',
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: const Color(0xFF6C8AF6),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
            );
          }
        });
      }
    }
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       'Fitur share akan segera hadir!',
    //       style: GoogleFonts.inter(),
    //     ),
    //     backgroundColor: const Color(0xFF6C8AF6),
    //     behavior: SnackBarBehavior.floating,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: height,
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAFA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            // Background gradient at bottom
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   child: IgnorePointer(
            //     child: ClipRRect(
            //       borderRadius: const BorderRadius.vertical(
            //         top: Radius.circular(24),
            //       ),
            //       child: Image.asset(
            //         'assets/png/bottomgr.png',
            //         width: width,
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            // ),
            // Main content
            Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hasil Caption',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Caption berhasil dibuat!',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xff807979),
                            ),
                          ),
                        ],
                      ),
                      // Close button
                      Material(
                        color: Colors.white,
                        shape: const CircleBorder(
                          side: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.close, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image carousel
                        ImageCarousel(
                          imageFiles: widget.imageFiles,
                          height: height * 0.3,
                        ),
                        const SizedBox(height: 24),
                        // Caption section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Caption',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Copy button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _copyToClipboard,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isCopied
                                            ? Icons.check
                                            : Icons.copy_outlined,
                                        size: 16,
                                        color: const Color(0xFF6C8AF6),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isCopied ? 'Disalin!' : 'Salin',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFF6C8AF6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Caption text box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1.5,
                            ),
                          ),
                          child: SelectableText(
                            widget.caption,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Share button at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFAFAFA).withValues(alpha: 0),
                      const Color(0xFFFAFAFA),
                    ],
                  ),
                ),
                child: Material(
                  color: const Color(0xFF6C8AF6),
                  borderRadius: BorderRadius.circular(30),
                  elevation: 4,
                  shadowColor: const Color(0xFF6C8AF6).withValues(alpha: 0.4),
                  child: InkWell(
                    onTap: () => _shareContent(context),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.share_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Bagikan ke Sosial Media',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation button for image carousel
