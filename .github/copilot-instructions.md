# GitHub Copilot Instructions for Kadam Mobile

## Project Overview
Kadam is a step tracking app with community and social features. Users can track their steps from multiple devices and compete with friends and groups through leaderboards. 

Kadam Mobile is a Flutter application with multi-platform support (iOS, Android, Web, Linux, macOS, Windows). The project follows Flutter's recommended architecture patterns with proper separation of concerns.

## Technology Stack
- **Framework**: Flutter (SDK ^3.5.1)
- **Language**: Dart
- **Backend**: Firebase
- **Localization**: flutter_localizations with ARB files
- **Linting**: flutter_lints ^4.0.0

## Project Structure
The repository is organized as follows:
- **`kadam_mobile/`** - The Flutter application source code (all app development happens here)
- **`docs/`** - Reference documentation and project files
  - **`docs/design.md`** - System-level design documentation for the app. This file is updated after every commit when there are changes to the high-level design.

### Flutter App Structure (`kadam_mobile/`)
```
kadam_mobile/
├── lib/
│   ├── main.dart                 # App entry point
│   └── src/
│       ├── app.dart             # Main app widget
│       ├── localization/        # Localization files (ARB)
│       ├── sample_feature/      # Feature modules
│       └── settings/            # Settings feature
├── test/                        # Unit and widget tests
├── assets/                      # Images and other assets
├── android/                     # Android platform code
├── ios/                         # iOS platform code
├── web/                         # Web platform code
├── linux/                       # Linux platform code
├── macos/                       # macOS platform code
├── windows/                     # Windows platform code
└── pubspec.yaml                 # Dependencies and project config
```

## Coding Standards

### General Principles
- Write clean, readable, and maintainable Dart code
- Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter_lints` rules - all linter warnings should be addressed
- Prefer immutability: use `final` and `const` wherever possible
- Make widgets `const` when they don't depend on runtime data

### Widget Development
- **Stateless over Stateful**: Use `StatelessWidget` unless state management is needed
- **Const Constructors**: Always use `const` constructors for widgets that don't change
- **Widget Composition**: Break down complex widgets into smaller, reusable components
- **Named Parameters**: Use named parameters for widget constructors (required for clarity)
- **Key Usage**: Provide keys to widgets when needed for proper state management

### Code Organization
- One widget/class per file for major components
- Group related functionality into feature folders under `lib/src/`
- Keep business logic separate from UI code
- Use barrel files (index.dart) to export public APIs from feature modules

### Naming Conventions
- **Files**: Use `snake_case` (e.g., `settings_controller.dart`)
- **Classes**: Use `PascalCase` (e.g., `SettingsController`)
- **Variables/Functions**: Use `camelCase` (e.g., `loadSettings()`)
- **Private Members**: Prefix with underscore (e.g., `_privateMethod()`)
- **Constants**: Use `lowerCamelCase` for const values, `SCREAMING_SNAKE_CASE` for static const

### State Management
- Use **Provider** for state management
- Controllers/ViewModels should extend `ChangeNotifier` for reactive updates
- Wrap widgets with `ChangeNotifierProvider` or `MultiProvider` as needed
- Access state using `Provider.of<T>(context)` or `context.watch<T>()`
- Use `context.read<T>()` for one-time access without rebuilds
- Services handle data persistence and business logic
- Keep controllers focused on a single feature/concern

### Async/Await
- Always use `async`/`await` for asynchronous operations
- Handle errors with try-catch blocks
- Use `Future` and `Stream` appropriately
- Mark functions as `async` in `main()` when needed

### Localization
- All user-facing strings must be localized using the generated l10n classes
- Add new strings to ARB files in `lib/src/localization/`
- Never hardcode user-facing text in widgets
- Access localized strings via `AppLocalizations.of(context)`

### Assets
- Store images in `assets/images/` with appropriate resolution folders (2.0x, 3.0x)
- Reference assets properly in `pubspec.yaml`
- Use `AssetImage` or `Image.asset()` for loading images

### Testing
- Write unit tests for all business logic and controllers
- Write widget tests for complex UI components
- Place tests in the `test/` directory mirroring the `lib/` structure
- Use descriptive test names that explain what is being tested
- Mock external dependencies in tests

### Dependencies
- Avoid adding dependencies unless absolutely necessary
- Prefer Flutter/Dart standard libraries when possible
- Document why a dependency is needed in PRs
- Keep dependencies up to date regularly

### Comments and Documentation
- Use `///` for public API documentation
- Use `//` for implementation comments
- Document complex logic and non-obvious decisions
- Keep comments up to date with code changes

### Error Handling
- Provide meaningful error messages
- Handle edge cases gracefully
- Use assertions for debug-mode checks
- Log errors appropriately for debugging

### Performance
- Minimize widget rebuilds using `const` constructors
- Use `ListView.builder()` for long lists
- Avoid expensive operations in `build()` methods
- Profile and optimize hot paths

## Common Patterns

### Creating a New Feature
1. Create a folder in `lib/src/<feature_name>/`
2. Add view, controller, and service files as needed
3. Update routing in `app.dart` if needed
4. Add localized strings to ARB files
5. Write tests for new functionality

## Platform-Specific Considerations
- Test on multiple platforms before shipping
- Handle platform-specific features with `Platform.isX` checks or platform channels
- Ensure responsive UI works on different screen sizes
- Follow platform design guidelines (Material for Android, Cupertino for iOS)

## Git Practices
- Write clear, concise commit messages
- Keep commits atomic and focused
- Reference issue numbers in commits when applicable
- Don't commit generated files from `build/` directory

## Questions to Ask Before Implementing
1. Is this feature truly needed?
2. Can we use existing Flutter widgets/packages?
3. Does this follow the project's architecture?
4. Is the code testable?
5. Are all strings localized?
6. Is the implementation performant?

---

When suggesting code changes, always follow these instructions and maintain consistency with the existing codebase.
