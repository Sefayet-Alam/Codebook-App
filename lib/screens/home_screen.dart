import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 🌟 Lottie animated background
        Positioned.fill(
          child: Lottie.asset(
            'assets/lottie/coding-bg.json',
            fit: BoxFit.cover,
            repeat: true,
          ),
        ),

        // 🌟 Main UI
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
                ),
                onPressed: toggleTheme,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // 🔥 Logo
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      child: Image.asset(
                        'assets/images/codebook.png',
                        key: const ValueKey('logo'),
                        height: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🧡 Welcome Message
                  Text(
                    'Welcome to Codebook App',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildButton(context, 'Browse your Codebook', '/browse'),
                  const SizedBox(height: 20),
                  _buildButton(context, 'Get AI Help', '/ai'),
                  const SizedBox(height: 20),
                  _buildButton(context, 'Print PDF', '/pdf'),
                  const SizedBox(height: 30),

                  // 🚪 Quit Button
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
