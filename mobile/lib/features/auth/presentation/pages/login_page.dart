import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imphenhackaton/core/di/injection_container.dart';
import 'package:imphenhackaton/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/generate_caption_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => sl<AuthBloc>(),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            // Navigate to GenerateCaptionPage on successful login
            if (state.status == AuthStatus.authenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => const GenerateCaptionPage(),
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),

                      Text(
                        'CAPTIONIZE',
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6C8AF6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Subtitle
                      Text(
                        'Generate caption untuk produk Anda dengan AI',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Description box
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF6C8AF6).withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fitur Utama',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6C8AF6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const _FeatureItem(
                              icon: Icons.image_outlined,
                              text: 'Upload hingga 5 gambar produk',
                            ),
                            const SizedBox(height: 10),
                            const _FeatureItem(
                              icon: Icons.edit_outlined,
                              text: 'Tambahkan deskripsi produk',
                            ),
                            const SizedBox(height: 10),
                            const _FeatureItem(
                              icon: Icons.auto_awesome_outlined,
                              text: 'AI membuat caption otomatis',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      // Google Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Material(
                          color: const Color(0xFF6C8AF6),
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            onTap: state.status == AuthStatus.loading
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                          const SignInWithGoogleEvent(),
                                        );
                                  },
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: state.status == AuthStatus.loading
                                  ? Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.login,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Masuk dengan Google',
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
                      // const SizedBox(height: 24),
                      // // Terms text
                      // Text(
                      //   'Dengan melanjutkan, Anda menyetujui Syarat dan Ketentuan kami',
                      //   textAlign: TextAlign.center,
                      //   style: GoogleFonts.inter(
                      //     fontSize: 12,
                      //     color: Colors.grey.shade500,
                      //     height: 1.5,
                      //   ),
                      // ),
                      // const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF6C8AF6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
