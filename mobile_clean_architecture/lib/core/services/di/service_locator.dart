import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../features/conversations/di/conversation_module.dart';
import '../../network/network_info.dart';
import '../audio_services.dart';

final getIt = GetIt.instance;

/// Initialize the service locator with all required dependencies
Future<void> init() async {
  // Features
  initConversationModule();
  
  // Core
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt<InternetConnectionChecker>()));
  
  // Audio service
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  
  // External dependencies
  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton(() => InternetConnectionChecker());
}
