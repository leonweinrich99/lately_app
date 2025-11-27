import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:lucide_icons/lucide_icons.dart'; // Aktiviere dies, wenn du das Package installiert hast. Nutze Icons.x als Platzhalter.

void main() {
  runApp(const LatelyApp());
}

// --- 1. DESIGN SYSTEM (COLORS & THEME) ---

class AppColors {
  static const Color bgDeep = Color(0xFF0F2926);
  static const Color bgSurface = Color(0xFF1A403C);
  static const Color accent = Color(0xFF68C9C3);
  static const Color textLight = Color(0xFFE8F7F6);
  static const Color textDim = Color(0xFF8CA6A3);
  static const Color alert = Color(0xFF912D2D);
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
        // Wir nutzen TextTheme für globale Styles
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

// --- 2. BASIS LAYOUT MIT NOISE & NAV ---

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text("Feed Screen Platzhalter")),
    const Center(child: Text("Friends Screen Platzhalter")),
    const Center(child: Text("Profile Screen Platzhalter")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // WICHTIG: Erlaubt der Page hinter die Navbar zu scrollen
      extendBody: true,

      // Der Hintergrund-Stack (Farbe + Noise)
      body: Stack(
        children: [
          // 1. Basis Hintergrund (Gradient)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [AppColors.bgSurface, AppColors.bgDeep],
              ),
            ),
          ),

          // 2. Noise Overlay (Hier würdest du dein Image Asset nutzen)
          // Opacity(
          //   opacity: 0.05,
          //   child: Image.asset('assets/noise.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          // ),

          // 3. Der eigentliche Inhalt
          SafeArea(
            bottom: false, // Bottom wird von Navbar handled
            child: _screens[_currentIndex],
          ),
        ],
      ),

      // 4. Floating Glass Navigation
      bottomNavigationBar: _buildGlassNavBar(),
    );
  }

  Widget _buildGlassNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), // Schwebt über dem Rand
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Der Blur Effekt
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgSurface.withOpacity(0.7),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.music_note, "Feed", 0),
                _buildNavItem(Icons.book, "Freunde", 1),
                _buildRecordButton(), // Der große Knopf in der Mitte
                _buildNavItem(Icons.person, "Ich", 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.textLight : AppColors.textLight.withOpacity(0.4),
            size: 26,
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return Transform.translate(
      offset: const Offset(0, -20), // Schwebt aus der Leiste heraus
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.alert, Color(0xFF7A2424)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.alert.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            // Innerer Glanz (Fake Lichtkante)
            const BoxShadow(
                color: Colors.white24,
                blurRadius: 4,
                offset: Offset(-2, -2),
                blurStyle: BlurStyle.inner
            )
          ],
        ),
        child: const Icon(Icons.mic, color: Colors.white, size: 32),
      ),
    );
  }
}