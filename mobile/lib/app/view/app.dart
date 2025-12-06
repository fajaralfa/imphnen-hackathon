import 'package:flutter/material.dart';
import 'package:imphenhackaton/features/auth/presentation/pages/login_page.dart';
import 'package:imphenhackaton/features/auth/presentation/pages/splashscreen.dart';
import 'package:imphenhackaton/features/counter/counter.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/pages/generate_caption_page.dart';
import 'package:imphenhackaton/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Splashscreen(),
      // home: const LoginPage(),
      // home: const GenerateCaptionPage(),
      // home: const CounterPage(),
    );
  }
}
