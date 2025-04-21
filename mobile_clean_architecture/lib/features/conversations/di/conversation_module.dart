import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../core/network/network_info.dart';
import '../data/datasources/conversation_remote_datasource.dart';
import '../data/repositories/conversation_repository_impl.dart';
import '../domain/repositories/conversation_repository.dart';
import '../domain/usecases/add_message_usecase.dart';
import '../domain/usecases/create_conversation_usecase.dart';
import '../domain/usecases/generate_feedback_usecase.dart';
import '../domain/usecases/get_ai_response_usecase.dart';
import '../domain/usecases/get_conversation_usecase.dart';
import '../domain/usecases/get_user_conversations_usecase.dart';
import '../presentation/bloc/conversation_bloc.dart';

/// Initializes the conversation feature dependency injection
///
/// Registers all necessary dependencies for the conversation feature
void initConversationModule() {
  final GetIt sl = GetIt.instance;

  // Bloc
  sl.registerFactory<ConversationBloc>(
    () => ConversationBloc(
      createConversation: sl(),
      getConversation: sl(),
      addMessage: sl(),
      getAiResponse: sl(),
      generateFeedback: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateConversationUseCase(sl()));
  sl.registerLazySingleton(() => GetConversationUseCase(sl()));
  sl.registerLazySingleton(() => GetUserConversationsUseCase(sl()));
  sl.registerLazySingleton(() => AddMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetAiResponseUseCase(sl()));
  sl.registerLazySingleton(() => GenerateFeedbackUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ConversationRemoteDataSource>(
    () => ConversationRemoteDataSourceImpl(client: sl()),
  );

  // Core
  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  }

  // External
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }
  
  if (!sl.isRegistered<InternetConnectionChecker>()) {
    sl.registerLazySingleton(() => InternetConnectionChecker());
  }
}
