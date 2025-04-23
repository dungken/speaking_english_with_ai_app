# Speak AI Flutter Application - Developer Guide

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Core Module Walkthrough](#core-module-walkthrough)
5. [Feature Implementation Guide](#feature-implementation-guide)
6. [Audio Recording Implementation](#audio-recording-implementation)
7. [State Management Guide](#state-management-guide)
8. [API Integration](#api-integration)
9. [Common Tasks](#common-tasks)
10. [Troubleshooting](#troubleshooting)

## Project Overview

Speak AI is a language learning application built with Flutter that helps users practice conversations in different scenarios. The app features audio recording, speech-to-text conversion, AI-powered responses, and language feedback.

### Key Features
- Interactive conversation practice with AI
- Audio recording and playback
- Speech-to-text transcription
- Language feedback and assessment
- Role-play scenarios
- User progress tracking

## Architecture

This project follows **Clean Architecture** principles with a feature-first approach, organized into the following layers:

### Presentation Layer
- User interface components (screens, widgets)
- State management using BLoC pattern
- Navigation and routing

### Domain Layer
- Business logic and rules
- Use cases representing application actions
- Entity definitions (core business objects)
- Repository interfaces

### Data Layer
- Repository implementations
- Remote data sources (API clients)
- Local data sources (database, shared preferences)
- Data models and mappers

![Clean Architecture Diagram](https://i.imgur.com/jQBePni.png)


## Project Structure

The project follows a feature-first approach with shared code in the core directory:

```
lib/
│
├── core/                       # Shared functionality
│   ├── auth/                   # Authentication utilities
│   ├── config/                 # Application configuration
│   ├── constants/              # App-wide constants
│   ├── di/                     # Dependency injection
│   ├── error/                  # Error handling
│   ├── models/                 # Shared data models
│   ├── network/                # HTTP client setup
│   ├── platform/               # Platform-specific code
│   ├── presentation/           # Shared UI components
│   ├── routes/                 # Navigation routing
│   ├── services/               # Cross-feature services
│   ├── theme/                  # App styling and themes
│   ├── usecase/                # Base use case definitions
│   └── utils/                  # Utility functions
│
└── features/                   # App features
    ├── conversations/          # Conversation feature
    │   ├── data/
    │   │   ├── datasources/    # Data providers
    │   │   ├── models/         # Data models
    │   │   └── repositories/   # Repository implementations
    │   ├── domain/
    │   │   ├── entities/       # Business objects
    │   │   ├── repositories/   # Repository interfaces
    │   │   └── usecases/       # Business logic
    │   └── presentation/
    │       ├── bloc/           # Business Logic Component
    │       ├── screens/        # UI screens
    │       └── widgets/        # Reusable UI parts
    │
    └── [other_features]/       # Other app features follow the same structure
```

## Core Module Walkthrough

### auth/
**Purpose**: Manages user authentication, login sessions, and authorization.

### config/
**Purpose**: Contains environment-specific configurations and feature flags.

### constants/
**Purpose**: Defines app-wide constants including API endpoints, route names, and asset paths.
```dart
// Example: api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://api.speakaiapp.com/v1';
  static const String audioToTextEndpoint = '/audio2text';
  // ...
}
```

### di/
**Purpose**: Implements dependency injection using the Get_It package.
```dart
// Example: injection_container.dart
final getIt = GetIt.instance;

void initDependencies() {
  // Services
  getIt.registerLazySingleton(() => AudioService());
  
  // Repositories
  getIt.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  
  // Use Cases
  getIt.registerLazySingleton(() => GetConversation(getIt()));
  
  // BLoCs
  getIt.registerFactory(() => ConversationBloc(
    getConversation: getIt(),
    startConversation: getIt(),
  ));
}
```

### error/
**Purpose**: Provides error handling mechanisms and custom exceptions.

### models/
**Purpose**: Contains shared data models used across features.

### network/
**Purpose**: Houses HTTP client configuration, interceptors, and network utilities.

### platform/
**Purpose**: Contains platform-specific implementations and abstractions.

### presentation/
**Purpose**: Provides reusable UI components like buttons, loading indicators, etc.

### routes/
**Purpose**: Manages application navigation using Go Router.
```dart
// Example: app_router.dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/conversations',
      builder: (context, state) => const ConversationListScreen(),
    ),
    // ...
  ],
);
```

### services/
**Purpose**: Contains cross-feature services like audio recording, analytics, etc.

### theme/
**Purpose**: Defines application styling, theme data, and text styles.
```dart
// Example: app_colors.dart
class AppColors {
  static const Color primary = Color(0xFF2962FF);
  static const Color accent = Color(0xFF00B8D4);
  static const Color error = Color(0xFFD50000);
  // ...
  
  static Color getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF303030) : Colors.white;
  }
}
```

### usecase/
**Purpose**: Defines base classes for use cases to ensure consistency.

### utils/
**Purpose**: Contains utility functions for common tasks.

## Feature Implementation Guide

### Creating a New Feature

Follow these steps when implementing a new feature:

#### 1. Create Feature Directory Structure
```
lib/features/your_feature/
  ├── data/
  │   ├── datasources/
  │   ├── models/
  │   └── repositories/
  ├── domain/
  │   ├── entities/
  │   ├── repositories/
  │   └── usecases/
  └── presentation/
      ├── bloc/
      ├── screens/
      └── widgets/
```

#### 2. Define Domain Layer

```dart
// 1. Define Entities
// lib/features/your_feature/domain/entities/some_entity.dart
class SomeEntity extends Equatable {
  final String id;
  final String name;
  
  const SomeEntity({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
}

// 2. Define Repository Interfaces
// lib/features/your_feature/domain/repositories/some_repository.dart
abstract class SomeRepository {
  Future<Either<Failure, SomeEntity>> getSomeEntity(String id);
  Future<Either<Failure, List<SomeEntity>>> getAllEntities();
}

// 3. Implement Use Cases
// lib/features/your_feature/domain/usecases/get_some_entity.dart
class GetSomeEntity implements UseCase<SomeEntity, Params> {
  final SomeRepository repository;
  
  GetSomeEntity(this.repository);
  
  @override
  Future<Either<Failure, SomeEntity>> call(Params params) {
    return repository.getSomeEntity(params.id);
  }
}

class Params extends Equatable {
  final String id;
  
  const Params({required this.id});
  
  @override
  List<Object?> get props => [id];
}
```

#### 3. Implement Data Layer

```dart
// 1. Create Data Models
// lib/features/your_feature/data/models/some_model.dart
class SomeModel extends SomeEntity {
  const SomeModel({required String id, required String name})
      : super(id: id, name: name);
      
  factory SomeModel.fromJson(Map<String, dynamic> json) {
    return SomeModel(
      id: json['id'],
      name: json['name'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// 2. Implement Data Sources
// lib/features/your_feature/data/datasources/some_remote_data_source.dart
abstract class SomeRemoteDataSource {
  Future<SomeModel> getSomeEntity(String id);
  Future<List<SomeModel>> getAllEntities();
}

class SomeRemoteDataSourceImpl implements SomeRemoteDataSource {
  final http.Client client;
  
  SomeRemoteDataSourceImpl({required this.client});
  
  @override
  Future<SomeModel> getSomeEntity(String id) async {
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/entities/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      return SomeModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
  
  // ...
}

// 3. Implement Repository
// lib/features/your_feature/data/repositories/some_repository_impl.dart
class SomeRepositoryImpl implements SomeRepository {
  final SomeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  SomeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, SomeEntity>> getSomeEntity(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteEntity = await remoteDataSource.getSomeEntity(id);
        return Right(remoteEntity);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
  
  // ...
}
```

#### 4. Develop Presentation Layer

```dart
// 1. Define BLoC
// lib/features/your_feature/presentation/bloc/some_bloc.dart
class SomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetSomeEntityEvent extends SomeEvent {
  final String id;
  
  GetSomeEntityEvent({required this.id});
  
  @override
  List<Object?> get props => [id];
}

class SomeState extends Equatable {
  final bool isLoading;
  final SomeEntity? entity;
  final Failure? failure;
  
  const SomeState({
    this.isLoading = false,
    this.entity,
    this.failure,
  });
  
  SomeState copyWith({
    bool? isLoading,
    SomeEntity? entity,
    Failure? failure,
  }) {
    return SomeState(
      isLoading: isLoading ?? this.isLoading,
      entity: entity ?? this.entity,
      failure: failure ?? this.failure,
    );
  }
  
  @override
  List<Object?> get props => [isLoading, entity, failure];
}

class SomeBloc extends Bloc<SomeEvent, SomeState> {
  final GetSomeEntity getSomeEntity;
  
  SomeBloc({required this.getSomeEntity}) : super(const SomeState()) {
    on<GetSomeEntityEvent>(_onGetSomeEntity);
  }
  
  Future<void> _onGetSomeEntity(
    GetSomeEntityEvent event,
    Emitter<SomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    final result = await getSomeEntity(Params(id: event.id));
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        failure: failure,
      )),
      (entity) => emit(state.copyWith(
        isLoading: false,
        entity: entity,
      )),
    );
  }
}

// 2. Create Screens and Widgets
// lib/features/your_feature/presentation/screens/some_screen.dart
class SomeScreen extends StatelessWidget {
  final String entityId;
  
  const SomeScreen({Key? key, required this.entityId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Some Screen')),
      body: BlocProvider(
        create: (_) => getIt<SomeBloc>()
          ..add(GetSomeEntityEvent(id: entityId)),
        child: BlocBuilder<SomeBloc, SomeState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.failure != null) {
              return Center(child: Text('Error: ${state.failure}'));
            } else if (state.entity != null) {
              return Center(child: Text('Name: ${state.entity!.name}'));
            } else {
              return const Center(child: Text('No data'));
            }
          },
        ),
      ),
    );
  }
}
```

#### 5. Register Dependencies

```dart
// lib/core/di/injection_container.dart
void registerYourFeature() {
  // BLoC
  getIt.registerFactory(() => SomeBloc(getSomeEntity: getIt()));
  
  // Use Cases
  getIt.registerLazySingleton(() => GetSomeEntity(getIt()));
  
  // Repository
  getIt.registerLazySingleton<SomeRepository>(
    () => SomeRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  
  // Data Sources
  getIt.registerLazySingleton<SomeRemoteDataSource>(
    () => SomeRemoteDataSourceImpl(client: getIt()),
  );
}
```

## Audio Recording Implementation

The app uses the `record` package (version 6.0.0) for audio recording functionality, implemented in `lib/core/services/audio_services.dart`.

### Audio Service Class
```dart
class AudioService {
  final _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;
  
  // Initialize recorder and check permissions
  Future<void> initialize() async {
    if (!await _audioRecorder.hasPermission()) {
      throw Exception('Microphone permission not granted');
    }
  }
  
  // Start recording audio
  Future<void> startRecording() async {
    await initialize();
    
    if (_isRecording) {
      await stopRecording();
    }
    
    final directory = await getTemporaryDirectory();
    final recordingPath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _currentRecordingPath = recordingPath;
    
    try {
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: recordingPath,
      );
      _isRecording = true;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }
  
  // Stop recording and return file path
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      return _currentRecordingPath;
    }
    
    try {
      await _audioRecorder.stop();
      _isRecording = false;
      return _currentRecordingPath;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }
  
  // Upload audio to backend and get transcription
  Future<Map<String, dynamic>> uploadAudioAndGetTranscription(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Audio file not found', filePath);
    }
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.audioToTextEndpoint}'),
    );
    
    request.headers.addAll({
      'Authorization': 'Bearer ${ApiConstants.token}',
    });
    
    request.files.add(
      await http.MultipartFile.fromPath(
        'audio_file',
        filePath,
        contentType: MediaType('audio', _getAudioMimeSubtype(filePath)),
      ),
    );
    
    final response = await request.send();
    final responseData = json.decode(await response.stream.bytesToString());
    
    return {
      "audio_id": responseData["audio_id"] ?? "",
      "transcription": responseData["transcription"] ?? ""
    };
  }
}
```

### Usage Example
```dart
final audioService = getIt<AudioService>();

// Start recording
ElevatedButton(
  onPressed: () async {
    await audioService.startRecording();
    setState(() => isRecording = true);
  },
  child: Text('Start Recording'),
)

// Stop recording and process audio
ElevatedButton(
  onPressed: () async {
    final path = await audioService.stopRecording();
    setState(() => isRecording = false);
    
    if (path != null) {
      final result = await audioService.uploadAudioAndGetTranscription(path);
      final audioId = result['audio_id'];
      final transcription = result['transcription'];
      
      // Use the results...
    }
  },
  child: Text('Stop Recording'),
)
```

## State Management Guide

The app uses the BLoC (Business Logic Component) pattern with the `flutter_bloc` package for state management.

### Core Concepts
- **Events**: Represent user actions or system events
- **States**: Represent the UI state resulting from processing events
- **Bloc**: Converts events to states through use cases and repositories

### Example: Conversation BLoC

```dart
// Events
abstract class ConversationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartRecordingEvent extends ConversationEvent {}
class StopRecordingEvent extends ConversationEvent {}
class SendMessageEvent extends ConversationEvent {
  final String audioPath;
  
  SendMessageEvent({required this.audioPath});
  
  @override
  List<Object?> get props => [audioPath];
}

// State
class ConversationState extends Equatable {
  final bool isRecording;
  final bool isProcessing;
  final String? currentAudioPath;
  final String? transcription;
  final List<Message> messages;
  final Failure? error;
  
  const ConversationState({
    this.isRecording = false,
    this.isProcessing = false,
    this.currentAudioPath,
    this.transcription,
    this.messages = const [],
    this.error,
  });
  
  ConversationState copyWith({
    bool? isRecording,
    bool? isProcessing,
    String? currentAudioPath,
    String? transcription,
    List<Message>? messages,
    Failure? error,
  }) {
    return ConversationState(
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      currentAudioPath: currentAudioPath ?? this.currentAudioPath,
      transcription: transcription ?? this.transcription,
      messages: messages ?? this.messages,
      error: error,
    );
  }
  
  @override
  List<Object?> get props => [
    isRecording,
    isProcessing,
    currentAudioPath,
    transcription,
    messages,
    error,
  ];
}

// BLoC
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final AudioService audioService;
  final SendMessage sendMessage;
  
  ConversationBloc({
    required this.audioService,
    required this.sendMessage,
  }) : super(const ConversationState()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<SendMessageEvent>(_onSendMessage);
  }
  
  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await audioService.startRecording();
      emit(state.copyWith(isRecording: true));
    } catch (e) {
      emit(state.copyWith(
        isRecording: false,
        error: Failure(message: e.toString()),
      ));
    }
  }
  
  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final audioPath = await audioService.stopRecording();
      emit(state.copyWith(
        isRecording: false,
        currentAudioPath: audioPath,
        isProcessing: true,
      ));
      
      if (audioPath != null) {
        final result = await audioService.uploadAudioAndGetTranscription(audioPath);
        emit(state.copyWith(
          transcription: result['transcription'],
          isProcessing: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isRecording: false,
        isProcessing: false,
        error: Failure(message: e.toString()),
      ));
    }
  }
  
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true));
    
    final result = await sendMessage(SendMessageParams(
      audioPath: event.audioPath,
      transcription: state.transcription ?? '',
    ));
    
    result.fold(
      (failure) => emit(state.copyWith(
        isProcessing: false,
        error: failure,
      )),
      (messages) => emit(state.copyWith(
        isProcessing: false,
        messages: [...state.messages, ...messages],
        currentAudioPath: null,
        transcription: null,
      )),
    );
  }
}
```

## API Integration

The app communicates with a backend API for various features. Here's how API integration works:

### API Constants
```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://api.speakaiapp.com/v1';
  static const String audioToTextEndpoint = '/audio2text';
  static const String conversationsEndpoint = '/conversations';
  static const String messagesEndpoint = '/messages';
  static const String feedbackEndpoint = '/feedback';
  
  static String token = ''; // Set during authentication
}
```

### API Response Structure
The API typically returns responses in this structure:

```json
// Success response
{
  "data": { ... },
  "message": "Success message"
}

// Error response
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Error description"
  }
}
```

### Key API Endpoints

1. **Create Conversation**
   - Endpoint: `POST /conversations`
   - Purpose: Initiates a new conversation with AI
   - Request:
     ```json
     {
       "user_role": "Student",
       "ai_role": "Teacher",
       "situation": "Discussing homework assignment"
     }
     ```
   - Response:
     ```json
     {
       "conversation": {
         "id": "123",
         "user_id": "456",
         "user_role": "Student",
         "ai_role": "Teacher",
         "situation": "Discussing homework assignment",
         "started_at": "2025-04-22T03:15:26.998Z",
         "ended_at": null
       },
       "initial_message": {
         "id": "789",
         "conversation_id": "123",
         "sender": "ai",
         "content": "Hello, I'm your teacher. How can I help with your homework?",
         "timestamp": "2025-04-22T03:15:26.998Z",
         "audio_path": null,
         "transcription": null,
         "feedback_id": null
       }
     }
     ```

2. **Audio to Text**
   - Endpoint: `POST /audio2text`
   - Purpose: Converts audio to text and returns both audio_id and transcription
   - Request: Multipart form data with audio file
   - Response:
     ```json
     {
       "audio_id": "abc123",
       "transcription": "I need help with my math homework."
     }
     ```

3. **Send Message**
   - Endpoint: `POST /conversations/{conversation_id}/message`
   - Purpose: Sends a user message and gets AI response
   - Request:
     ```json
     {
       "audio_id": "abc123",
       "transcription": "I need help with my math homework."
     }
     ```
   - Response:
     ```json
     {
       "user_message": {
         "id": "101",
         "conversation_id": "123",
         "sender": "user",
         "content": "I need help with my math homework.",
         "timestamp": "2025-04-22T03:17:26.998Z",
         "audio_path": "/path/to/audio/abc123.wav",
         "transcription": "I need help with my math homework.",
         "feedback_id": "f101"
       },
       "ai_message": {
         "id": "102",
         "conversation_id": "123",
         "sender": "ai",
         "content": "Of course! What specific part are you struggling with?",
         "timestamp": "2025-04-22T03:17:27.998Z",
         "audio_path": null,
         "transcription": null,
         "feedback_id": null
       }
     }
     ```

4. **Get Feedback**
   - Endpoint: `GET /feedback/{message_id}`
   - Purpose: Retrieves feedback for a specific message
   - Response:
     ```json
     {
       "user_feedback": {
         "id": "f101",
         "user_feedback": "Your English was good but you could improve your grammar by using the past tense properly.",
         "created_at": "2025-04-22T03:17:30.998Z"
       },
       "is_ready": true
     }
     ```

## Common Tasks

### 1. Adding a New Screen

1. Create a new screen in the appropriate feature directory:
   ```
   lib/features/your_feature/presentation/screens/your_screen.dart
   ```

2. Add a route in the router:
   ```dart
   // lib/core/routes/app_router.dart
   GoRoute(
     path: '/your-path',
     builder: (context, state) => const YourScreen(),
   ),
   ```

3. Navigate to the screen:
   ```dart
   context.go('/your-path');
   ```

### 2. Adding a New API Endpoint

1. Add the endpoint to API constants:
   ```dart
   // lib/core/constants/api_constants.dart
   static const String newEndpoint = '/new-endpoint';
   ```

2. Create or update a data source to use the endpoint:
   ```dart
   Future<SomeModel> fetchSomeData() async {
     final response = await client.get(
       Uri.parse('${ApiConstants.baseUrl}${ApiConstants.newEndpoint}'),
       headers: {'Content-Type': 'application/json'},
     );
     
     if (response.statusCode == 200) {
       return SomeModel.fromJson(json.decode(response.body));
     } else {
       throw ServerException();
     }
   }
   ```

### 3. Creating a Custom Widget

1. Create a new widget in the appropriate directory:
   ```
   lib/features/your_feature/presentation/widgets/your_widget.dart
   ```
   or if it's shared:
   ```
   lib/core/presentation/widgets/your_widget.dart
   ```

2. Implement the widget:
   ```dart
   class YourWidget extends StatelessWidget {
     final String title;
     final VoidCallback onTap;
     
     const YourWidget({
       Key? key,
       required this.title,
       required this.onTap,
     }) : super(key: key);
     
     @override
     Widget build(BuildContext context) {
       return GestureDetector(
         onTap: onTap,
         child: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: AppColors.primary.withOpacity(0.1),
             borderRadius: BorderRadius.circular(8),
           ),
           child: Text(
             title,
             style: TextStyles.body(context),
           ),
         ),
       );
     }
   }
   ```

## Troubleshooting

### Common Issues and Solutions

1. **App crashes during audio recording**
   - Check microphone permissions
   - Verify the correct version of the record package (6.0.0)
   - Ensure paths are correctly handled for temporary files

2. **API calls fail**
   - Check network connection
   - Verify API endpoint URLs
   - Check authentication token
   - Look for API response format changes

3. **BLoC events not updating UI**
   - Ensure you're using the correct context with BlocProvider
   - Check that state properties are included in props list for Equatable
   - Verify that copyWith is properly implemented

4. **Missing dependencies**
   - Make sure all dependencies are registered in the dependency injection container
   - Check that the dependency tree is correct (dependencies of dependencies)

### Debugging Tips

1. Use `flutter run --debug` for development with hot reload
2. Add print statements or use a logger for quick debugging
3. Use Flutter DevTools for deeper analysis
4. Check API responses using a tool like Postman

### Best Practices

1. Always use the repository pattern for data access
2. Keep presentation logic in BLoC/Cubit, not in widgets
3. Use the dependency injection container for service location
4. Write tests for business logic and repositories
5. Follow the project's architecture patterns consistently