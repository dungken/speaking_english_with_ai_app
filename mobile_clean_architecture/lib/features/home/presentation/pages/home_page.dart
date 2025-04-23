import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/home_type.dart';
import '../bloc/user_bloc.dart';
import '../widgets/home_card.dart';
import '../widgets/user_profile_card.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDarkMode = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    context.read<HomeCubit>().loadHomeTypes();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadThemePreference();
  }

  void _loadThemePreference() {
    setState(() {
      _isDarkMode = _prefs.getBool('isDarkMode') ??
          Theme.of(context).brightness == Brightness.dark;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    // Save theme preference to shared preferences
    _prefs.setBool('isDarkMode', _isDarkMode);

    // Update the app theme
    if (mounted) {
      final themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      // Use a simple approach that works on all platforms
      final brightness = _isDarkMode ? Brightness.dark : Brightness.light;
      final theme = brightness == Brightness.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme;

      // Create a new MaterialApp with the updated theme
      // This is a workaround since we can't directly change the theme of the existing app
      // In a real app, you would use a ThemeBloc to manage theme state
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const HomePage(),
          ),
        ),
      );
    }
  }

  void _handleSignOut() {
    // Dispatch sign out event to the AuthBloc
    context.read<AuthBloc>().add(SignOutEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Add an AuthBloc listener to handle navigation on sign out
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Navigate to auth screen when user logs out
          context.go('/auth');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Speak AI'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              padding: const EdgeInsets.only(right: 10),
              onPressed: _toggleTheme,
              icon: Icon(
                _isDarkMode
                    ? Icons.brightness_2_rounded // 🌙 Dark Mode Icon
                    : Icons.brightness_5_rounded, // ☀️ Light Mode Icon
                size: 26,
              ),
            ),
            IconButton(
              padding: const EdgeInsets.only(right: 10),
              onPressed: _handleSignOut,
              icon: const Icon(
                Icons.logout,
                size: 26,
              ),
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue.shade900.withOpacity(0.3)
                    : Colors.blue.shade50,
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.purple.shade900.withOpacity(0.3)
                    : Colors.purple.shade50,
              ],
            ),
          ),
          child: BlocBuilder<HomeCubit, dynamic>(
            builder: (context, state) {
              // Simple approach without pattern matching
              if (state.toString().contains('initial') ||
                  state.toString().contains('loading')) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.toString().contains('loaded')) {
                // Extract homeTypes from the state
                final homeTypes = (state as dynamic).homeTypes as List<dynamic>;

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    const UserProfileCard()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'Learning Tools',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    ...homeTypes.map((type) => HomeCard(homeType: type)),
                  ],
                );
              } else if (state.toString().contains('error')) {
                // Extract message from the state
                final message = (state as dynamic).message as String;

                return Center(
                  child: Text(
                    'Error: $message',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
