import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'models/restaurant_adapter.dart';
import 'services/hive_boxes.dart';
import 'services/import_to_firestore.dart';
import 'screens/dashboard_screen.dart';
import 'theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseReady = false;

  // 🟢 Initialize Firebase safely
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialized successfully");
    await FirestoreImportService.importRestaurants();
    firebaseReady = true;
  } catch (e) {
    debugPrint("⚠️ Firebase initialization failed: $e");
    firebaseReady = false;
  }

  // 💾 Initialize Hive for offline cache
  await Hive.initFlutter();
  Hive.registerAdapter(RestaurantAdapter());
  await HiveBoxes.openAll();

  runApp(RestaurantTrackerApp(firebaseReady: firebaseReady));
}

class RestaurantTrackerApp extends StatelessWidget {
  final bool firebaseReady;
  const RestaurantTrackerApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkTrac Restaurants',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.gold),
        useMaterial3: true,
        fontFamily: 'Poppins',
        cardTheme: const CardThemeData(
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: firebaseReady
          ? const AppInitializer()
          : const FirebaseOfflineFallback(),
    );
  }
}

/// 🧭 Shows a splash while verifying startup status
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});
  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const SplashScreen();
    }
    return const DashboardScreen();
  }
}

/// 🕒 Simple Disney-style gold shimmer splash
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 72, color: AppColors.gold),
            const SizedBox(height: 16),
            const Text(
              "ParkTrac Restaurants",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            CircularProgressIndicator(color: AppColors.gold.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }
}

/// 🪫 Fallback shown if Firebase failed to initialize
class FirebaseOfflineFallback extends StatelessWidget {
  const FirebaseOfflineFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 80, color: AppColors.gold),
              const SizedBox(height: 20),
              const Text(
                "Offline Mode Activated",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Firebase could not connect, but you can continue using your offline data.\n\nYou can sync when online again.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textDark, fontSize: 15),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Continue Offline"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
