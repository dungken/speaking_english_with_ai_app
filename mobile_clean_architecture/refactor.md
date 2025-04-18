# Screek App Refactoring Guide

## Current Architecture Analysis

The codebase follows a feature-first organization with clean architecture principles. Here's the current structure:

```
lib/
├── core/                 # Core functionality and shared components
├── features/            # Feature modules
│   ├── authentication/
│   ├── conversations/
│   ├── home/
│   ├── image_description/
│   ├── onboarding/
│   ├── practice_mistakes/
│   ├── profile/
│   ├── settings/
│   └── topics/
└── main.dart
```

Each feature module currently follows this structure:
```
feature/
├── data/               # Data layer implementation
├── di/                # Dependency injection
├── domain/            # Domain layer (entities, use cases)
└── presentation/      # UI components and state management
```

## Refactoring Recommendations

### 1. Core Module Enhancement

#### Create the following structure in core/:
```
core/
├── error/             # Error handling
│   ├── exceptions.dart
│   └── failures.dart
├── network/           # Network related code
│   ├── api_client.dart
│   └── network_info.dart
├── usecases/          # Base use case classes
│   └── usecase.dart
├── utils/             # Utility functions and constants
└── widgets/           # Shared widgets
```

### 2. Feature Module Standardization

Each feature should follow this structure:
```
feature/
├── data/
│   ├── datasources/           # Remote and local data sources
│   ├── models/               # Data models
│   └── repositories/         # Repository implementations
├── domain/
│   ├── entities/            # Business objects
│   ├── repositories/        # Repository interfaces
│   └── usecases/           # Business logic
├── presentation/
│   ├── bloc/               # State management
│   ├── pages/              # Screen widgets
│   └── widgets/            # Feature-specific widgets
└── di/                    # Feature-specific DI
```

### 3. Implementation Guidelines

#### Domain Layer
- Keep entities pure Dart classes with no framework dependencies
- Implement repository interfaces with clear contracts
- Create focused use cases with single responsibility
- Example structure:
```dart
// domain/entities/user.dart
class User {
  final String id;
  final String name;
  // ... other properties
}

// domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
}

// domain/usecases/get_user.dart
class GetUser implements UseCase<User, String> {
  final UserRepository repository;
  
  @override
  Future<Either<Failure, User>> call(String userId) {
    return repository.getUser(userId);
  }
}
```

#### Data Layer
- Implement repository interfaces from domain layer
- Handle data source operations and error mapping
- Example structure:
```dart
// data/models/user_model.dart
class UserModel extends User {
  UserModel({
    required String id,
    required String name,
  }) : super(id: id, name: name);
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Implementation
  }
}

// data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  
  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      // Implementation
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

#### Presentation Layer
- Implement BLoC pattern for state management
- Keep UI components focused and reusable
- Example structure:
```dart
// presentation/bloc/user_bloc.dart
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUser getUser;
  
  UserBloc({required this.getUser}) : super(UserInitial()) {
    on<LoadUser>((event, emit) async {
      emit(UserLoading());
      final result = await getUser(event.userId);
      result.fold(
        (failure) => emit(UserError(failure.message)),
        (user) => emit(UserLoaded(user))
      );
    });
  }
}

// presentation/pages/user_page.dart
class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<UserBloc>(),
      child: UserView(),
    );
  }
}
```

### 4. Dependency Injection

- Use get_it for service location
- Organize DI by feature
- Example structure:
```dart
// di/injection_container.dart
final getIt = GetIt.instance;

Future<void> init() async {
  // Features
  await initAuthFeature();
  await initUserFeature();
  // ... other features
}

Future<void> initAuthFeature() async {
  // Domain
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  
  // Data
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt())
  );
  
  // Presentation
  getIt.registerFactory(() => AuthBloc(getIt()));
}
```

### 5. Testing Structure

Organize tests to mirror the source code structure:
```
test/
├── core/
├── features/
│   └── feature_name/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── helpers/
```

### 6. Code Style and Best Practices

1. Use meaningful names for classes, methods, and variables
2. Keep methods focused and small (under 20 lines when possible)
3. Document public APIs and complex logic
4. Use proper error handling with Either type
5. Implement proper logging
6. Follow Flutter's style guide
7. Use proper state management patterns
8. Implement proper navigation using routes

### 7. Performance Considerations

1. Implement proper caching strategies
2. Use lazy loading where appropriate
3. Optimize image loading and caching
4. Implement proper memory management
5. Use const constructors where possible
6. Implement proper widget rebuilding strategies

## Next Steps

1. Create the enhanced core module structure
2. Refactor each feature module to follow the standardized structure
3. Implement proper error handling across all layers
4. Set up proper dependency injection
5. Add comprehensive testing
6. Document the codebase
7. Implement proper logging and monitoring
8. Set up CI/CD pipeline

## Migration Strategy

1. Start with core module enhancement
2. Pick one feature module as a pilot
3. Refactor the pilot feature following the new structure
4. Use the pilot as a template for other features
5. Gradually migrate other features
6. Add tests as features are migrated
7. Update documentation continuously

Remember to maintain backward compatibility during the refactoring process and ensure proper testing at each step. 