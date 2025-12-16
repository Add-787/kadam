# Kadam Mobile - Architecture Design

This document outlines the architecture and design principles used in the Kadam mobile application.

## Architecture Overview

The application follows **Clean Architecture** principles with a **feature-first** folder structure. This approach provides:

- Clear separation of concerns
- High testability
- Easy maintainability
- Scalability for team development

## Project Structure

```
lib/
├── main.dart                          # Entry point (dev by default)
├── main_dev.dart                      # Dev environment entry
├── main_prod.dart                     # Prod environment entry
├── app.dart                           # Main app widget
├── firebase_options_dev.dart          # Dev Firebase config (gitignored)
├── firebase_options_prod.dart         # Prod Firebase config (gitignored)
│
├── core/                              # Core functionality
│   ├── constants/                     # App-wide constants
│   │   ├── app_constants.dart
│   │   └── firebase_constants.dart
│   ├── theme/                         # Theme configuration
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   ├── utils/                         # Utility functions
│   │   ├── validators.dart
│   │   └── helpers.dart
│   ├── errors/                        # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── routes/                        # App routing
│       └── app_routes.dart
│
├── features/                          # Feature modules
│   ├── auth/                          # Authentication feature
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository_impl.dart
│   │   │   └── datasources/
│   │   │       ├── auth_remote_datasource.dart
│   │   │       └── auth_local_datasource.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── signup_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── signup_screen.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           └── auth_button.dart
│   │
│   ├── settings/                      # Settings feature (implemented)
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── settings_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── settings_repository_impl.dart
│   │   │   └── datasources/
│   │   │       └── settings_local_datasource.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── settings.dart
│   │   │   ├── repositories/
│   │   │   │   └── settings_repository.dart
│   │   │   └── usecases/
│   │   │       ├── load_settings_usecase.dart
│   │   │       └── update_theme_mode_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── settings_provider.dart
│   │       ├── screens/
│   │       │   └── settings_screen.dart
│   │       └── widgets/
│   │
│   └── [other_features]/
│
└── shared/                            # Shared across features
    ├── widgets/                       # Reusable widgets
    │   ├── custom_button.dart
    │   ├── loading_indicator.dart
    │   └── error_widget.dart
    ├── models/                        # Shared models
    └── services/                      # Shared services
        ├── storage_service.dart
        └── notification_service.dart
```

## Architecture Layers

### 1. Presentation Layer (`presentation/`)

**Responsibility**: Handle UI and user interactions

**Components**:
- **Screens**: Full-page views
- **Widgets**: Reusable UI components
- **Providers/Controllers**: State management (using Provider pattern)

**Rules**:
- Only depends on Domain layer
- No direct access to Data layer
- Contains UI logic only, no business logic

**Example**:
```dart
// presentation/providers/settings_provider.dart
class SettingsProvider with ChangeNotifier {
  final LoadSettingsUseCase loadSettingsUseCase;
  final UpdateThemeModeUseCase updateThemeModeUseCase;
  
  Settings _settings = const Settings(themeMode: ThemeMode.system);
  
  Future<void> loadSettings() async {
    _settings = await loadSettingsUseCase();
    notifyListeners();
  }
}
```

### 2. Domain Layer (`domain/`)

**Responsibility**: Pure business logic and rules

**Components**:
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces (contracts)
- **UseCases**: Single-purpose business operations

**Rules**:
- No dependencies on other layers
- Pure Dart (no Flutter dependencies)
- Framework-independent

**Example**:
```dart
// domain/entities/settings.dart
class Settings {
  final ThemeMode themeMode;
  final String languageCode;
  
  const Settings({
    required this.themeMode,
    this.languageCode = 'en',
  });
}

// domain/usecases/load_settings_usecase.dart
class LoadSettingsUseCase {
  final SettingsRepository repository;
  
  LoadSettingsUseCase(this.repository);
  
  Future<Settings> call() async {
    return await repository.loadSettings();
  }
}
```

### 3. Data Layer (`data/`)

**Responsibility**: Data retrieval and storage

**Components**:
- **Models**: Data transfer objects with JSON serialization
- **Repositories**: Implementation of domain repository interfaces
- **DataSources**: Direct interaction with data sources (Firebase, API, local storage)

**Rules**:
- Implements Domain layer interfaces
- Handles data conversion (JSON, Firebase documents, etc.)
- Manages caching and data persistence

**Example**:
```dart
// data/models/settings_model.dart
class SettingsModel extends Settings {
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: _themeModeFromString(json['themeMode']),
      languageCode: json['languageCode'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'themeMode': _themeModeToString(themeMode),
      'languageCode': languageCode,
    };
  }
}

// data/repositories/settings_repository_impl.dart
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  
  @override
  Future<Settings> loadSettings() async {
    final model = await localDataSource.loadSettings();
    return model.toEntity();
  }
}
```

## Dependency Flow

```
Presentation Layer
       ↓
   Domain Layer
       ↑
    Data Layer
```

**Key Principle**: Dependencies point inward. The Domain layer is at the center and knows nothing about outer layers.

## State Management

The app uses **Provider** for state management:

- **ChangeNotifierProvider**: For reactive state
- **Provider**: For dependency injection
- **Consumer**: For listening to state changes in UI

### Why Provider?

- Simple and intuitive
- Official Flutter recommendation
- Works well with Clean Architecture
- Easy to test
- Lightweight

## Dependency Injection

Manual dependency injection is used for simplicity and clarity:

```dart
void main() async {
  // Setup dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  final dataSource = SettingsLocalDataSource(sharedPreferences);
  final repository = SettingsRepositoryImpl(dataSource);
  final useCase = LoadSettingsUseCase(repository);
  final provider = SettingsProvider(loadSettingsUseCase: useCase);
  
  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const App(),
    ),
  );
}
```

For larger apps, consider using:
- **get_it** for service locator pattern
- **injectable** for code generation

## Firebase Integration

### Multiple Environments

The app supports multiple Firebase environments:

- **Dev**: `firebase_options_dev.dart` → `main_dev.dart`
- **Prod**: `firebase_options_prod.dart` → `main_prod.dart`

### Running Different Environments

```bash
# Development
flutter run -t lib/main_dev.dart

# Production
flutter run -t lib/main_prod.dart
```

### Firebase Services Structure

Each Firebase service should be wrapped in a feature:

```
features/
  auth/
    data/
      datasources/
        auth_firebase_datasource.dart    # Firebase Auth
  
  posts/
    data/
      datasources/
        posts_firestore_datasource.dart  # Firestore
        posts_storage_datasource.dart    # Storage
```

## Feature Development Workflow

### Creating a New Feature

1. **Create feature folder structure**:
   ```bash
   mkdir -p lib/features/my_feature/{data/{models,repositories,datasources},domain/{entities,repositories,usecases},presentation/{providers,screens,widgets}}
   ```

2. **Start with Domain layer**:
   - Define entities (business objects)
   - Define repository interfaces
   - Create use cases

3. **Implement Data layer**:
   - Create models with JSON serialization
   - Implement data sources (Firebase, API, local)
   - Implement repositories

4. **Build Presentation layer**:
   - Create provider for state management
   - Build screens
   - Create reusable widgets

5. **Wire up dependencies** in `main.dart`

### Example: Adding Authentication Feature

```dart
// 1. Domain Entity
class User {
  final String id;
  final String email;
  final String name;
}

// 2. Domain Repository Interface
abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> signup(String email, String password);
  Future<void> logout();
}

// 3. Domain UseCase
class LoginUseCase {
  final AuthRepository repository;
  Future<User> call(String email, String password) =>
      repository.login(email, password);
}

// 4. Data Model
class UserModel extends User {
  factory UserModel.fromFirebase(firebaseUser) { ... }
  Map<String, dynamic> toJson() { ... }
}

// 5. Data Source
class AuthFirebaseDataSource {
  final FirebaseAuth firebaseAuth;
  Future<UserModel> signIn(String email, String password) { ... }
}

// 6. Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource dataSource;
  Future<User> login(String email, String password) { ... }
}

// 7. Provider
class AuthProvider with ChangeNotifier {
  final LoginUseCase loginUseCase;
  User? _user;
  Future<void> login(String email, String password) { ... }
}

// 8. Screen
class LoginScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>( ... );
  }
}
```

## Testing Strategy

### Unit Tests
- Test use cases (business logic)
- Test repositories
- Test models

### Widget Tests
- Test individual widgets
- Test screens

### Integration Tests
- Test complete user flows
- Test Firebase integration

### Test Structure
```
test/
  features/
    auth/
      domain/
        usecases/
          login_usecase_test.dart
      data/
        repositories/
          auth_repository_impl_test.dart
      presentation/
        providers/
          auth_provider_test.dart
```

## Best Practices

### 1. Single Responsibility
Each class/file should have one clear purpose.

### 2. Dependency Inversion
Depend on abstractions (interfaces), not concretions.

### 3. Immutability
Use `const` constructors and `final` fields where possible.

### 4. Error Handling
Create custom exceptions and failures:
```dart
// core/errors/exceptions.dart
class ServerException implements Exception {}
class CacheException implements Exception {}

// core/errors/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {}
class CacheFailure extends Failure {}
```

### 5. Code Organization
- One class per file
- Meaningful file and folder names
- Group related functionality

### 6. Comments and Documentation
- Document public APIs
- Explain complex logic
- Use TODO comments for future work

## Tools and Packages

### Core
- **flutter**: UI framework
- **firebase_core**: Firebase initialization
- **provider**: State management

### Firebase
- **firebase_auth**: Authentication
- **cloud_firestore**: NoSQL database
- **firebase_storage**: File storage

### State & Storage
- **provider**: State management
- **shared_preferences**: Local key-value storage

### Code Quality
- **flutter_lints**: Linting rules
- **flutter_test**: Testing framework

## Migration Guide

### From Old Structure to New

If you have code in the old structure (`lib/src/`):

1. **Identify the feature** the code belongs to
2. **Separate concerns**:
   - Business logic → Domain layer
   - Data operations → Data layer  
   - UI → Presentation layer
3. **Create interfaces** for dependencies
4. **Wire up** with dependency injection
5. **Test** each layer independently

## Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)

## Contributing

When adding new features:
1. Follow the established architecture
2. Write tests
3. Document public APIs
4. Update this design document if needed
