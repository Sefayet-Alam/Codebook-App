import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/sections_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/pdf_screen.dart';
import 'screens/login_screen.dart';
import 'services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    return StreamProvider<User?>.value(
      value: FirebaseAuth.instance.authStateChanges(),
      initialData: null,
      child: Consumer<User?>(
        builder: (context, user, _) {
          if (user == null) {
            // Not logged in → no FirestoreService provider needed
            return MaterialApp(
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
              home: const LoginScreen(),
              routes: {
                '/browse': (_) => const SectionsScreen(),
                // For these routes, user is not logged in,
                // so either redirect to Login or show empty screens
                '/ai': (_) => const LoginScreen(),
                '/pdf': (_) => const PdfScreen(),
              },
            );
          }

          // Logged in → provide FirestoreService with uid
          return Provider<FirestoreService>(
            create: (_) => FirestoreService(user.uid),
            // Removed dispose line because FirestoreService has no dispose method
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
                '/pdf': (_) => const PdfScreen(),
                // Pass uid and email from logged-in user:
                '/ai': (_) =>
                    AIChatScreen(uid: user.uid, email: user.email ?? ''),
              },
            ),
          );
        },
      ),
    );
  }
}
