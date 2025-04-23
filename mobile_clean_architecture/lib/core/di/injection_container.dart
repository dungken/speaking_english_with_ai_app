import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/authentication/data/models/user_model.dart';
import '../../features/authentication/di/auth_module.dart';
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../network/network_info.dart';

/// Global ServiceLocator instance
final sl = GetIt.instance;

/// Initialize dependencies
Future<void> init() async {
  // Features - Authentication
  // Bloc
  sl.registerFactory(
    () => AuthBloc(authRepository: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(box: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // External
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  final box = await Hive.openBox<UserModel>('user_box');
  sl.registerLazySingleton<Box<UserModel>>(() => box);

  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  // Hive box for local storage
  // This should be initialized after Hive.init() is called
  sl.registerLazySingletonAsync<Box>(() async {
    return await Hive.openBox('auth_box');
  });

  // Wait for async dependencies to initialize
  await sl.allReady();
}
