import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'shared/navigation/floating_bottom_nav.dart';
import 'features/feed/presentation/feed_screen.dart'; // <--- Import hinzugefügt

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const LatelyApp());
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

  // Placeholder Screens
  final List<Widget> _screens = [
    const FeedScreen(), // <--- Hier ist der neue Feed Screen
    const Center(child: Text("Freunde (Coming Soon)")),
    const Center(child: Text("Profil (Coming Soon)")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Wichtig für Glass-Effekt hinter der Bar
      body: Stack(
        children: [
          // 1. Hintergrund Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.3,
                colors: [AppColors.bgSurface, AppColors.bgDeep],
              ),
            ),
          ),

          // 2. Der aktive Screen
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // 3. Navigation Layer (Unten)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none, // Erlaubt dem Button überzustehen
              children: [
                // Die Glas-Leiste
                FloatingBottomNav(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  onRecordTap: () {}, // Callback für später
                ),

                // Der schwebende Record Button
                Positioned(
                  bottom: 50, // Zieht den Button nach oben raus
                  child: FloatingRecordButton(
                    onTap: () {
                      print("Aufnahme starten...");
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}