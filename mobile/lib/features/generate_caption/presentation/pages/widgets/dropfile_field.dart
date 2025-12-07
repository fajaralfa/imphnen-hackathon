import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/widgets/image_carousel.dart';

class DropfileField extends StatelessWidget {
  const DropfileField({
    required this.width,
    required this.height,
    required this.onTap,
    this.images = const [],
    this.onRemoveImage,
    super.key,
  });

  final double width;
  final double height;
  final List<File> images;
  final VoidCallback onTap;
  final void Function(int index)? onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return images.isNotEmpty
        ? Stack(
            children: [
              ImageCarousel(
                imageFiles: images,
                width: width * 0.8,
                height: height * 0.28,
              ),
              // Remove button
              if (onRemoveImage != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => _showRemoveDialog(context),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )
        : Container(
            width: width * 0.8,
            height: height * 0.28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xfff9f9f9),
                width: 10,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.file_upload_outlined),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ketuk untuk pilih foto',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Maksimal 5 foto',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hapus Gambar',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua gambar?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Remove all images
              for (var i = images.length - 1; i >= 0; i--) {
                onRemoveImage?.call(i);
              }
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
