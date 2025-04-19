import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../utils/app_colors.dart';
import '../widgets/components/app_bar/home_app_bar.dart';
import '../widgets/home_content.dart';

/// The main HomeScreen widget that serves as the container for the app's home view.
/// Implements authentication checks and theme management while delegating
/// UI rendering to specialized component widgets.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for page transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start animation after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Redirect to authentication screen if user is not authenticated
        if (state is Unauthenticated) {
          context.go('/auth');
        }
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final isDarkMode = themeProvider.isDarkMode;

          return Scaffold(
            backgroundColor: AppColors.getBackgroundColor(isDarkMode),
            appBar: HomeAppBar(
              isDarkMode: isDarkMode,
              onThemeToggle: () => themeProvider.toggleTheme(),
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: HomeContent(isDarkMode: isDarkMode),
            ),
          );
        },
      ),
    );
  }
}
