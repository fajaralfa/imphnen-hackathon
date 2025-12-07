import 'package:flutter/material.dart';

class CaptionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CaptionAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Generate Caption'),
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
