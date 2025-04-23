/// This is the entry point of the Flutter application.
/// It sets up the core configuration and initializes the app with necessary providers.
///
/// Key components:
/// 1. MultiBlocProvider: Manages state management using BLoC pattern
/// 2. MaterialApp.router: Configures routing using GoRouter
/// 3. Theme configuration: Sets up light and dark themes
///
/// The app follows Clean Architecture principles with feature-based organization.

// These are packages we need to import from Flutter and third-party libraries
// Think of imports like borrowing tools from different toolboxes to use in our app
import 'package:flutter/material.dart'; // Core Flutter UI components
import 'package:flutter_bloc/flutter_bloc.dart'; // For BLoC state management (like a brain for our app)
import 'package:get_it/get_it.dart'; // For dependency injection (like a central supply station)
import 'package:hive_flutter/hive_flutter.dart'; // For local database storage (like a filing cabinet)
import 'package:provider/provider.dart'; // For simpler state management (like a messenger)
import 'package:shared_preferences/shared_preferences.dart'; // For saving simple app settings (like a notepad)
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb for platform detection

// These are imports from our own app code
import 'core/routes/app_router.dart'; // Controls navigation between screens
import 'core/theme/app_theme.dart'; // Defines how our app looks (colors, styles)
import 'core/theme/theme_provider.dart'; // Manages theme changes (light/dark mode)
import 'core/utils/platform_checker.dart'; // Added platform detection utilities
import 'features/authentication/data/models/user_model.dart'; // Structure for user data
import 'features/authentication/di/auth_module.dart'; // Sets up authentication features
import 'features/conversations/di/conversation_module.dart'; // Sets up conversation features
import 'features/conversations/presentation/bloc/conversation_bloc.dart'; // Controls conversation logic
import 'features/home/di/home_module.dart'; // Sets up home screen features
import 'features/home/presentation/cubit/home_cubit.dart'; // Controls logic for home screen
import 'features/authentication/presentation/bloc/auth_bloc.dart'; // Controls authentication logic

/// Application entry point - like the "main door" to our app
/// The async keyword means this function can wait for tasks to complete
void main() async {
  // This line makes sure Flutter is ready before we do anything else
  // Like warming up a car engine before driving
  WidgetsFlutterBinding.ensureInitialized();

  // Set up the basic services our app needs
  // This is like setting up utilities before people move into a house
  await initDependencies();

  // Set up specific features of our app
  // Like arranging furniture in different rooms of the house
  initAuthModule(); // Set up login/signup features
  initHomeModule(); // Set up home screen features
  initConversationModule(); // Set up conversation features

  // Start the app by creating the main widget
  // Like opening the front door and welcoming guests in
  runApp(const MyApp());
}

/// Initialize core dependencies - sets up the basic services our app needs
Future<void> initDependencies() async {
  // Initialize Hive with proper platform detection
  await Hive.initFlutter();

  // Tell Hive how to store User objects
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }

  // Open a box (like a drawer) to store user information
  final box = await Hive.openBox<UserModel>('auth_box');

  // Register the box with GetIt so any part of the app can access it
  GetIt.instance.registerLazySingleton<Box<UserModel>>(() => box);

  // Set up SharedPreferences for storing simple app settings
  final prefs = await SharedPreferences.getInstance();

  // Register SharedPreferences with GetIt for app-wide access
  GetIt.instance.registerLazySingleton<SharedPreferences>(() => prefs);

  // Create a ThemeProvider that will manage app appearance settings
  GetIt.instance
      .registerLazySingleton<ThemeProvider>(() => ThemeProvider(prefs));
      
  // Print platform info for debugging
  if (kIsWeb) {
    print('Application running on Web platform');
    // Add any web-specific initialization here
  } else if (PlatformChecker.isMobile) {
    print('Application running on Mobile platform');
    // Add any mobile-specific initialization here
  } else if (PlatformChecker.isDesktop) {
    print('Application running on Desktop platform');
    // Add any desktop-specific initialization here
  }
}

/// Root widget of the application - this is the main structure of our app
///
/// This widget:
/// - Sets up state management using BLoC (for complex logic)
/// - Configures the app theme (colors, styles)
/// - Initializes routing (how to move between screens)
/// - Provides global app settings (things every screen might need)
class MyApp extends StatelessWidget {
  // Constructor with optional key parameter
  // Like a blueprint for building this part of the app
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider wraps our app to provide services to all screens
    // Like a building with different utility systems (water, electricity) that serve every room
    return MultiProvider(
      providers: [
        // Set up the theme provider to manage light/dark mode
        // Like installing a central light switch system for the building
        ChangeNotifierProvider(
          create: (_) => GetIt.instance<ThemeProvider>(),
        ),
        // Set up HomeCubit to manage home screen logic
        // Like installing a control system for the home area
        BlocProvider<HomeCubit>(
          create: (context) => GetIt.instance<HomeCubit>(),
        ),
        // Set up AuthBloc to manage authentication logic
        // Like installing a security system for the building entrance
        BlocProvider<AuthBloc>(
          create: (context) => GetIt.instance<AuthBloc>(),
        ),
        // Set up ConversationBloc to manage conversation logic
        // Like installing a communication system for the conversation area
        BlocProvider<ConversationBloc>(
          create: (context) => GetIt.instance<ConversationBloc>(),
        ),
      ],
      // Consumer listens for theme changes and rebuilds the app when needed
      // Like having sensors that detect when to adjust the lighting
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // MaterialApp.router is the actual app with navigation controls
          // Like the finished building with all its rooms and hallways
          return MaterialApp.router(
            title: 'Speaking English With AI', // App name shown in device
            debugShowCheckedModeBanner:
                false, // Hides the "debug" banner in corner
            theme: AppTheme.lightTheme, // How the app looks in light mode
            darkTheme: AppTheme.darkTheme, // How the app looks in dark mode
            themeMode: themeProvider.themeMode, // Current mode (light/dark)
            routerConfig:
                AppRouter.router, // Controls navigation between screens
          );
        },
      ),
    );
  }
}
