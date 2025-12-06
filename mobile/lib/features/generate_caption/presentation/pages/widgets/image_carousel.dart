import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/widgets/img_nav_button.dart';

/// A carousel widget to display multiple images with navigation.
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    required this.imageFiles,
    this.width,
    this.height,
    this.onPageChanged,
    super.key,
  });

  final List<File> imageFiles;
  final double? width;
  final double? height;
  final ValueChanged<int>? onPageChanged;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImageError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat gambar',
            style: GoogleFonts.inter(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageCount = widget.imageFiles.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image carousel container
        Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? screenHeight * 0.3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xfff9f9f9),
              width: 8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // PageView for images
                PageView.builder(
                  controller: _pageController,
                  itemCount: imageCount,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                    widget.onPageChanged?.call(index);
                  },
                  itemBuilder: (context, index) {
                    return Image.file(
                      widget.imageFiles[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImageError();
                      },
                    );
                  },
                ),
                // Navigation arrows (only show if multiple images)
                if (imageCount > 1) ...[
                  // Left arrow
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: ImageNavButton(
                        icon: Icons.chevron_left,
                        onTap: _currentImageIndex > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                  // Right arrow
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: ImageNavButton(
                        icon: Icons.chevron_right,
                        onTap: _currentImageIndex < imageCount - 1
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Page indicators (only show if multiple images)
        if (imageCount > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              imageCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentImageIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? const Color(0xFF6C8AF6)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
