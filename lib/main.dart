import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mealcircle/Frontscreens/logo.dart';
import 'package:mealcircle/services/user_provider.dart';
import 'package:mealcircle/Frontscreens/login_screen.dart';
import 'package:mealcircle/finder/finder_cart_manager.dart';
import 'package:mealcircle/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
    // Local initialization only
    print('✅ App initialized successfully (Local Mode)');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FinderCartManager()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Meal Circle',
        theme: ThemeData(useMaterial3: true),
        routes: {'/login': (context) => const LoginScreen()},
        home: const IntroScreen(),
      ),
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize UserProvider when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      userProvider
          .initialize()
          .then((_) {
            print('✅ UserProvider initialized successfully');
            print('📊 Current user: ${userProvider.currentUser?.name}');
            print('💾 Donations loaded: ${userProvider.donations.length}');
          })
          .catchError((e) {
            print('❌ Error initializing UserProvider: $e');
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF15622F), Color(0xFF2AC962)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: height * 0.10),
              const MealCircleLogo(size: 220),
              const Spacer(),
              const _QuoteText(),
              const Spacer(flex: 3),
              const _DiveButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiveButton extends StatelessWidget {
  const _DiveButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC8E6C9),
            foregroundColor: Colors.black87,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Let\'s Dive!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuoteText extends StatelessWidget {
  const _QuoteText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        '" Every Bite Of Food Matters,\nNothing Should Go To Waste "',
        textAlign: TextAlign.center,
        style: GoogleFonts.kaushanScript(
          fontSize: 32,
          color: Colors.white,
          height: 1.4,
          shadows: const [
            Shadow(color: Colors.black38, blurRadius: 3, offset: Offset(0, 2)),
          ],
        ),
      ),
    );
  }
}

class MealCircleLogoLocal extends StatelessWidget {
  final double size;

  const MealCircleLogoLocal({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }
}
