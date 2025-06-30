import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'ai_chat_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({super.key, required this.toggleTheme});

  void _quitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  String _shortEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex == -1) return email;
    String prefix = email.substring(0, atIndex);
    if (prefix.length > 3) {
      prefix = prefix.substring(0, 3);
    }
    return prefix; // keep original case (no capitalization)
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = AuthService();
    final user = FirebaseAuth.instance.currentUser;

    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Positioned.fill(
          child: Lottie.asset(
            'assets/lottie/coding-bg.json',
            fit: BoxFit.cover,
            repeat: true,
            // A bit dimmer overlay
            // Optionally can overlay a dark color to dim Lottie
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Codebook App'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
                  color: Colors.white70,
                ),
                onPressed: toggleTheme,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Classy circle avatar with subtle gradient and shadow
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade800, Colors.grey.shade900],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.7),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _shortEmail(user?.email ?? ''),
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Welcome text centered below avatar
                  Center(
                    child: Text(
                      'Welcome to Codebook App',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 4,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  _buildButton(context, 'Browse your Codebook', '/browse'),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AIChatScreen(
                              uid: user.uid,
                              email: user.email ?? '',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent[700],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                    child: const Text(
                      'Get AI Help',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildButton(context, 'Print PDF', '/pdf'),
                  const SizedBox(height: 48),

                  ElevatedButton.icon(
                    onPressed: () async {
                      await auth.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _quitApp,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Quit App'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String label, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent[700],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
