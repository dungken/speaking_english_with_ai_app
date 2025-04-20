# Library Implementation Guide for Speak AI Flutter App

This document provides detailed guidance on how to implement the key libraries in your English learning application, focusing on the core features you've specified.

## Setting Up Clean Architecture

The application follows a clean architecture pattern with three main layers:

### 1. Presentation Layer
Libraries: `flutter_bloc`, `auto_route`, `flutter_screenutil`

```dart
// Example BLoC implementation for Role Play feature

// role_play_event.dart
abstract class RolePlayEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class StartRolePlaySession extends RolePlayEvent {
  final String userRole;
  final String aiRole;
  final String situation;
  
  StartRolePlaySession({
    required this.userRole,
    required this.aiRole,
    required this.situation,
  });
  
  @override
  List<Object> get props => [userRole, aiRole, situation];
}

// role_play_state.dart
abstract class RolePlayState extends Equatable {
  @override
  List<Object> get props => [];
}

class RolePlayInitial extends RolePlayState {}
class RolePlayLoading extends RolePlayState {}
class RolePlayActive extends RolePlayState {
  final Conversation conversation;
  
  RolePlayActive({required this.conversation});
  
  @override
  List<Object> get props => [conversation];
}

// role_play_bloc.dart
class RolePlayBloc extends Bloc<RolePlayEvent, RolePlayState> {
  final ConversationRepository conversationRepository;
  final SpeechService speechService;
  
  RolePlayBloc({
    required this.conversationRepository,
    required this.speechService,
  }) : super(RolePlayInitial()) {
    on<StartRolePlaySession>(_onStartRolePlaySession);
  }
  
  Future<void> _onStartRolePlaySession(
    StartRolePlaySession event,
    Emitter<RolePlayState> emit,
  ) async {
    emit(RolePlayLoading());
    
    try {
      final conversation = await conversationRepository.createConversation(
        userRole: event.userRole,
        aiRole: event.aiRole,
        situation: event.situation,
      );
      
      emit(RolePlayActive(conversation: conversation));
    } catch (error) {
      // Handle error state
    }
  }
}
```

### 2. Domain Layer
Libraries: `equatable`, `dartz` (for functional error handling)

```dart
// Example domain entity and repository interface

// entities/conversation.dart
class Conversation extends Equatable {
  final String id;
  final String userRole;
  final String aiRole;
  final String situation;
  final String enhancedSituation;
  final List<Message> messages;
  
  const Conversation({
    required this.id,
    required this.userRole,
    required this.aiRole,
    required this.situation,
    required this.enhancedSituation,
    required this.messages,
  });
  
  @override
  List<Object> get props => [id, userRole, aiRole, situation, enhancedSituation, messages];
}

// repository interfaces
abstract class ConversationRepository {
  Future<Conversation> createConversation({
    required String userRole,
    required String aiRole,
    required String situation,
  });
  
  Future<Message> addUserMessage({
    required String conversationId,
    required String content,
  });
  
  Future<List<Feedback>> getFeedbackForMessage({
    required String messageId,
  });
}
```

### 3. Data Layer
Libraries: `dio`, `mongo_dart`, `hive` or `isar`, `retrofit`

```dart
// Example repository implementation

// data/repositories/conversation_repository_impl.dart
class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationRemoteDataSource remoteDataSource;
  final ConversationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  ConversationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Conversation> createConversation({
    required String userRole,
    required String aiRole,
    required String situation,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final conversationModel = await remoteDataSource.createConversation(
          userRole: userRole,
          aiRole: aiRole,
          situation: situation,
        );
        
        await localDataSource.cacheConversation(conversationModel);
        return conversationModel.toDomain();
      } catch (e) {
        // Handle remote data source errors
        throw ServerException();
      }
    } else {
      // Handle offline mode
      throw NetworkException();
    }
  }
  
  // Other methods...
}

// data/datasources/conversation_remote_data_source.dart
class ConversationRemoteDataSource {
  final Dio dio;
  
  ConversationRemoteDataSource({required this.dio});
  
  Future<ConversationModel> createConversation({
    required String userRole,
    required String aiRole,
    required String situation,
  }) async {
    try {
      final response = await dio.post(
        '/conversations',
        data: {
          'userRole': userRole,
          'aiRole': aiRole,
          'situation': situation,
        },
      );
      
      return ConversationModel.fromJson(response.data);
    } catch (e) {
      throw ServerException();
    }
  }
}
```

## Voice Recording and Processing Implementation

Libraries: `flutter_sound`, `speech_to_text`, `path_provider`

```dart
// services/speech_service.dart
class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  String _recognizedText = '';
  
  Future<void> initialize() async {
    _isInitialized = await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
  }
  
  Future<void> startListening({
    required Function(String text) onResult,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    await _speechToText.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        onResult(_recognizedText);
      },
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
  }
  
  Future<void> stopListening() async {
    await _speechToText.stop();
    return _recognizedText;
  }
  
  bool get isListening => _speechToText.isListening;
}

// Audio recording implementation
class AudioRecordingService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  String? _recordingPath;
  
  Future<void> initialize() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    
    await _recorder.openRecorder();
    _isInitialized = true;
  }
  
  Future<void> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final directory = await getTemporaryDirectory();
    _recordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
    
    await _recorder.startRecorder(
      toFile: _recordingPath,
      codec: Codec.aacADTS,
    );
  }
  
  Future<String?> stopRecording() async {
    await _recorder.stopRecorder();
    return _recordingPath;
  }
  
  Future<void> dispose() async {
    await _recorder.closeRecorder();
    _isInitialized = false;
  }
}
```

## Progress Tracking Implementation

Libraries: `fl_chart`, `table_calendar`, `shared_preferences`

```dart
// Example progress tracking repository
class ProgressRepository {
  final SharedPreferences _preferences;
  final String _streakKey = 'user_streak';
  final String _lastPracticeKey = 'last_practice_date';
  
  ProgressRepository({required SharedPreferences preferences})
      : _preferences = preferences;
  
  Future<void> recordPracticeSession() async {
    final now = DateTime.now();
    final lastPracticeStr = _preferences.getString(_lastPracticeKey);
    
    if (lastPracticeStr != null) {
      final lastPractice = DateTime.parse(lastPracticeStr);
      final difference = now.difference(lastPractice).inDays;
      
      if (difference == 1) {
        // Consecutive day - increase streak
        final currentStreak = _preferences.getInt(_streakKey) ?? 0;
        await _preferences.setInt(_streakKey, currentStreak + 1);
      } else if (difference > 1) {
        // Streak broken - reset to 1
        await _preferences.setInt(_streakKey, 1);
      }
    } else {
      // First practice session
      await _preferences.setInt(_streakKey, 1);
    }
    
    // Update last practice date
    await _preferences.setString(_lastPracticeKey, now.toIso8601String());
  }
  
  int getCurrentStreak() {
    return _preferences.getInt(_streakKey) ?? 0;
  }
  
  // Additional methods for tracking other metrics...
}

// Example chart implementation for progress visualization
class ProgressChart extends StatelessWidget {
  final List<PracticeSession> sessions;
  
  const ProgressChart({Key? key, required this.sessions}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true),
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: (value) {
                // Format dates for x-axis
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return DateFormat('MM/dd').format(date);
              },
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: sessions.map((session) {
                return FlSpot(
                  session.date.millisecondsSinceEpoch.toDouble(),
                  session.score.toDouble(),
                );
              }).toList(),
              isCurved: true,
              colors: [Theme.of(context).primaryColor],
              barWidth: 4,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Image Description Feature Implementation

Libraries: `cached_network_image`, `firebase_storage` or `aws_s3`

```dart
// Example image description repository
class ImageDescriptionRepository {
  final FirebaseStorage _storage;
  final ImageLocalDataSource _localDataSource;
  
  ImageDescriptionRepository({
    required FirebaseStorage storage,
    required ImageLocalDataSource localDataSource,
  })  : _storage = storage,
        _localDataSource = localDataSource;
  
  Future<List<DescriptionImage>> getImagesForTopic(String topicId) async {
    // First check local cache
    final cachedImages = await _localDataSource.getCachedImagesForTopic(topicId);
    if (cachedImages.isNotEmpty) {
      return cachedImages;
    }
    
    // If not available locally, fetch from storage
    try {
      final storageRef = _storage.ref().child('topics/$topicId');
      final listResult = await storageRef.listAll();
      
      final List<DescriptionImage> images = [];
      for (var item in listResult.items) {
        final url = await item.getDownloadURL();
        final metadata = await item.getMetadata();
        
        // Extract pre-description from metadata
        final description = metadata.customMetadata?['description'] ?? '';
        
        final image = DescriptionImage(
          id: item.name,
          url: url,
          topicId: topicId,
          preDescription: description,
        );
        
        images.add(image);
      }
      
      // Cache images locally
      await _localDataSource.cacheImages(images);
      
      return images;
    } catch (e) {
      throw StorageException();
    }
  }
  
  Future<void> saveUserDescription({
    required String imageId,
    required String description,
    required String audioPath,
  }) async {
    // Implementation for saving user's description
  }
}
```

## Offline Functionality

Libraries: `connectivity_plus`, `hive` or `isar`, `workmanager`

```dart
// Example NetworkInfo implementation
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  
  NetworkInfoImpl({required this.connectivity});
  
  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

// Example of local data source with Hive
class ConversationLocalDataSourceImpl implements ConversationLocalDataSource {
  final Box<ConversationModel> conversationsBox;
  
  ConversationLocalDataSourceImpl({required this.conversationsBox});
  
  @override
  Future<void> cacheConversation(ConversationModel conversation) async {
    await conversationsBox.put(conversation.id, conversation);
  }
  
  @override
  Future<ConversationModel> getConversation(String id) async {
    final conversation = conversationsBox.get(id);
    if (conversation != null) {
      return conversation;
    } else {
      throw CacheException();
    }
  }
  
  @override
  Future<List<ConversationModel>> getAllConversations() async {
    return conversationsBox.values.toList();
  }
}

// Background sync service
class SyncService {
  final WorkManager workManager = WorkManager();
  
  Future<void> initialize() async {
    await workManager.initialize();
    
    // Register periodic sync task
    await workManager.registerPeriodicTask(
      'syncData',
      'syncDataTask',
      frequency: Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }
  
  // Implementation for sync task handler
}
```

## Dependency Injection Setup

Libraries: `get_it`, `injectable`

```dart
// Example dependency injection setup
@InjectableInit()
void configureDependencies() => getIt.init();

@module
abstract class AppModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
  
  @preResolve
  Future<Box<ConversationModel>> get conversationsBox async {
    await Hive.initFlutter();
    Hive.registerAdapter(ConversationModelAdapter());
    return await Hive.openBox<ConversationModel>('conversations');
  }
  
  @singleton
  Dio get dio => Dio(BaseOptions(
    baseUrl: 'https://your-api-endpoint.com/api',
    connectTimeout: 5000,
    receiveTimeout: 3000,
  ));
  
  @singleton
  FirebaseStorage get storage => FirebaseStorage.instance;
  
  @singleton
  Connectivity get connectivity => Connectivity();
  
  @singleton
  NetworkInfo get networkInfo => NetworkInfoImpl(connectivity: get_it<Connectivity>());
}

@singleton
class ConversationRemoteDataSource {
  final Dio dio;
  
  ConversationRemoteDataSource(this.dio);
  
  // Implementation...
}

@singleton
class ConversationLocalDataSource {
  final Box<ConversationModel> box;
  
  ConversationLocalDataSource(this.box);
  
  // Implementation...
}

@singleton
class ConversationRepository {
  final ConversationRemoteDataSource remoteDataSource;
  final ConversationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  ConversationRepository({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  // Implementation...
}
```

## Testing Setup

Libraries: `mockito`, `bloc_test`, `integration_test`

```dart
// Example unit test for Role Play BLoC
void main() {
  late RolePlayBloc rolePlayBloc;
  late MockConversationRepository mockConversationRepository;
  late MockSpeechService mockSpeechService;
  
  setUp(() {
    mockConversationRepository = MockConversationRepository();
    mockSpeechService = MockSpeechService();
    rolePlayBloc = RolePlayBloc(
      conversationRepository: mockConversationRepository,
      speechService: mockSpeechService,
    );
  });
  
  tearDown(() {
    rolePlayBloc.close();
  });
  
  group('StartRolePlaySession', () {
    const userRole = 'Job Applicant';
    const aiRole = 'Interviewer';
    const situation = 'Job Interview';
    
    final conversation = Conversation(
      id: '1',
      userRole: userRole,
      aiRole: aiRole,
      situation: situation,
      enhancedSituation: 'Enhanced situation description',
      messages: [],
    );
    
    test('emits [RolePlayLoading, RolePlayActive] when successful', () async {
      // Arrange
      when(mockConversationRepository.createConversation(
        userRole: userRole,
        aiRole: aiRole,
        situation: situation,
      )).thenAnswer((_) async => conversation);
      
      // Assert
      expectLater(
        rolePlayBloc.stream,
        emitsInOrder([
          RolePlayLoading(),
          RolePlayActive(conversation: conversation),
        ]),
      );
      
      // Act
      rolePlayBloc.add(StartRolePlaySession(
        userRole: userRole,
        aiRole: aiRole,
        situation: situation,
      ));
    });
    
    // Additional tests...
  });
}
```

## Performance Optimization Techniques

1. **Lazy Loading**
   - Load data only when needed (e.g., pagination for conversation history)
   - Implement proper caching strategies

2. **Widget Optimization**
   - Use `const` constructors where possible
   - Implement `RepaintBoundary` for complex animations
   - Optimize lists with `ListView.builder`

3. **Image Optimization**
   - Use proper image caching
   - Implement progressive loading for images
   - Consider using appropriate image formats and sizes

4. **State Management**
   - Keep state as local as possible
   - Use efficient BLoC patterns
   - Minimize unnecessary widget rebuilds

5. **Network Optimization**
   - Implement proper request batching
   - Use GraphQL for flexible API queries if applicable
   - Implement efficient error handling and retry mechanisms

## Deployment Considerations

1. **CI/CD Setup**
   - Configure GitHub Actions or other CI/CD tools
   - Implement automated testing before deployment
   - Setup automatic version management

2. **Release Management**
   - Implement proper versioning
   - Create beta testing channels
   - Plan for phased rollouts

3. **Monitoring**
   - Implement Firebase Crashlytics for crash reporting
   - Set up analytics to track user engagement
   - Monitor API response times and errors

4. **Scalability**
   - Design backend services to handle increased load
   - Implement proper caching strategies
   - Consider serverless architecture for certain components

This implementation guide should provide you with a solid foundation for developing your English learning application with Flutter. The code examples are meant to illustrate the use of various libraries and how they fit into the clean architecture pattern. As you develop your application, you may need to adjust these examples to fit your specific requirements and architecture decisions.