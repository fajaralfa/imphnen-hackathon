import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generate Caption',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          // style: TextStyle(
          //   fontSize: 32,
          //   fontWeight: FontWeight.bold,
          //   color: Colors.white,
          // ),
        ),
        Text(
          'Upload Foto, Biar AI yang Pusing Cari Caption',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xff807979),
          ),
          // style: TextStyle(
          //   fontSize: 16,
          //   color: Colors.white70,
          // ),
        ),
      ],
    );
  }
}
