import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imphenhackaton/core/di/injection_container.dart';
import 'package:imphenhackaton/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imphenhackaton/features/auth/presentation/pages/login_page.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/generate_caption_page.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
      child: const _SplashscreenView(),
    );
  }
}

class _SplashscreenView extends StatelessWidget {
  const _SplashscreenView();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          // User has valid token, go to GenerateCaptionPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => const GenerateCaptionPage(),
            ),
          );
        } else if (state.status == AuthStatus.unauthenticated) {
          // No valid token, go to LoginPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => const LoginPage(),
            ),
          );
        }
        // For loading and initial states, keep showing splash
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient (same as GenerateCaptionPage)
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C8AF6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 60,
                      color: Color(0xFF6C8AF6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App Title
                  Text(
                    'Caption Generator',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Generate caption untuk produk Anda dengan AI',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Loading indicator with custom styling
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Color(0xFF6C8AF6),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Loading text
                  Text(
                    'Menyiapkan aplikasi...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
