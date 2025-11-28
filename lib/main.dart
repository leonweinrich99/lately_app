import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/core/theme/app_colors.dart';
import 'src/shared/navigation/floating_bottom_nav.dart';
import 'src/features/feed/presentation/feed_screen.dart';
import 'src/features/recorder/presentation/record_screen.dart'; // Importieren!

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: LatelyApp()));
}

class LatelyApp extends StatelessWidget {
  const LatelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lately',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDeep,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(
              color: AppColors.textLight, fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.inter(color: AppColors.textLight),
          bodyMedium: GoogleFonts.inter(color: AppColors.textDim),
        ),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const Center(child: Text("Freunde (Coming Soon)")),
    const Center(child: Text("Profil (Coming Soon)")),
  ];

  void _openRecorder() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RecordScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // Von unten einschweben
          const end = Offset.zero;
          const curve = Curves.easeOutQuart;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Hintergrund
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.3,
                colors: [AppColors.bgSurface, AppColors.bgDeep],
              ),
            ),
          ),

          // Inhalt
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              onRecordTap: _openRecorder, // Hier rufen wir die Funktion auf
            ),
          ),
        ],
      ),
    );
  }
}