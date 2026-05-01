import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LocalEatsApp());
}

class LocalEatsApp extends StatelessWidget {
  const LocalEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: MaterialApp(
        title: 'LocalEats',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2E8B57),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E8B57),
            secondary: const Color(0xFFFF7F50),
          ),
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
