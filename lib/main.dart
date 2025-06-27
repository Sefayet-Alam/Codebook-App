import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'screens/home_screen.dart';
import 'screens/sections_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/pdf_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // You can debug print to confirm key is loaded
  // print('GROQ API Key: ${Env.groqApiKey}'); // <-- Now it's securely loaded

  runApp(const CodebookApp());
}

class CodebookApp extends StatefulWidget {
  const CodebookApp({super.key});

  @override
  State<CodebookApp> createState() => _CodebookAppState();
}

class _CodebookAppState extends State<CodebookApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<FirestoreService>(
      create: (_) => FirestoreService(),
      child: MaterialApp(
        title: 'Codebook App',
        themeMode: _themeMode,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.sourceCodeProTextTheme(),
          scaffoldBackgroundColor: Colors.grey[100],
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark().copyWith(
          textTheme: GoogleFonts.sourceCodeProTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: HomeScreen(toggleTheme: toggleTheme),
        routes: {
          '/browse': (_) => const SectionsScreen(),
          '/ai': (_) => const AIChatScreen(),
          '/pdf': (_) => const PdfScreen(),
        },
      ),
    );
  }
}
