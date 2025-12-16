# High Level Design for Kadam

## Overview
Kadam is a step tracking mobile application that enables users to track their steps from multiple devices and engage with friends through social features and competitive leaderboards. The app is built with Flutter for cross-platform support and uses Firebase as its backend infrastructure.

## Core Features
1. **Step Tracking** - Track steps from multiple devices with synchronization
2. **Social Features** - Connect with friends and share activity
3. **Leaderboards** - Compete with friends and groups
4. **Groups** - Create or join groups for collective challenges
5. **Multi-Device Support** - Seamless data sync across user devices

## Technology Stack

### Frontend
- **Framework**: Flutter (SDK ^3.5.1)
- **Language**: Dart
- **State Management**: Provider pattern with ChangeNotifier
- **Localization**: flutter_localizations with ARB files
- **Platforms**: iOS, Android, Web, Linux, macOS, Windows

### Backend
- **Platform**: Firebase
  - **Authentication**: Firebase Auth (for user management)
  - **Database**: Cloud Firestore (for real-time data sync)
  - **Storage**: Firebase Storage (for user assets)
  - **Functions**: Cloud Functions (for server-side logic)
  - **Analytics**: Firebase Analytics (for usage tracking)

## Architecture

### Application Architecture
The app follows a feature-based architecture with clear separation of concerns:

```
lib/src/
├── app.dart                    # Main app configuration and routing
├── localization/               # Internationalization (i18n)
├── sample_feature/             # Template feature module
└── settings/                   # App settings feature
    ├── settings_view.dart      # UI layer
    ├── settings_controller.dart # State management (ChangeNotifier)
    └── settings_service.dart   # Business logic & data persistence
```

### State Management Pattern
- **Provider**: Dependency injection and state management
- **ChangeNotifier**: Controllers extend ChangeNotifier for reactive updates
- **Services**: Handle data persistence and business logic
- **Views**: UI widgets that consume state via Provider

### Data Flow
1. **User Action** → View captures user input
2. **View** → Controller processes the action
3. **Controller** → Service handles business logic and Firebase operations
4. **Service** → Firebase updates data
5. **Firebase** → Real-time listeners notify controllers
6. **Controller** → notifyListeners() triggers UI rebuild
7. **View** → Displays updated state

## Key Modules

### 1. Authentication Module
- User registration and login via Firebase Auth
- Social login options (Google, Apple, etc.)
- Profile management
- Session persistence

### 2. Step Tracking Module
- Integration with device pedometer/health APIs
- Step count aggregation from multiple devices
- Daily, weekly, and monthly statistics
- Historical data storage in Firestore

### 3. Social Module
- Friend connections and management
- Activity feed showing friends' achievements
- Social sharing capabilities
- User profiles and avatars

### 4. Leaderboard Module
- Real-time leaderboard updates using Firestore
- Multiple leaderboard types (friends, groups, global)
- Time-based rankings (daily, weekly, monthly, all-time)
- Achievement badges and milestones

### 5. Groups Module
- Group creation and management
- Member invitations and permissions
- Group-specific leaderboards
- Group challenges and goals

### 6. Settings Module
- User preferences (theme, notifications, units)
- Privacy settings
- Device management
- Data sync settings

## Data Models

### User
```dart
class User {
  String id;
  String displayName;
  String email;
  String? photoUrl;
  DateTime createdAt;
  List<String> deviceIds;
  Map<String, dynamic> preferences;
}
```

### StepRecord
```dart
class StepRecord {
  String id;
  String userId;
  int stepCount;
  DateTime date;
  String deviceId;
  DateTime syncedAt;
}
```

### Leaderboard
```dart
class Leaderboard {
  String id;
  String type; // 'friends', 'group', 'global'
  String? groupId;
  DateTime period; // start of period
  List<LeaderboardEntry> entries;
}
```

### Group
```dart
class Group {
  String id;
  String name;
  String? description;
  String creatorId;
  List<String> memberIds;
  DateTime createdAt;
}
```

## Firebase Structure

### Firestore Collections
```
users/
  {userId}/
    - profile data
    - settings
    devices/
      {deviceId}/
        - device info

stepRecords/
  {recordId}/
    - step data
    - userId, deviceId, date, count

leaderboards/
  {leaderboardId}/
    - type, period
    entries/
      {userId}/
        - rank, stepCount

groups/
  {groupId}/
    - group data
    members/
      {userId}/
        - role, joinedAt

friends/
  {userId}/
    friends/
      {friendId}/
        - status, connectedAt
```

## Design Decisions

### 1. Provider over BLoC
- **Rationale**: Simpler learning curve, less boilerplate, sufficient for app complexity
- **Implementation**: Controllers extend ChangeNotifier, views use Provider.of or context.watch

### 2. Feature-Based Structure
- **Rationale**: Better scalability, clear boundaries, easier team collaboration
- **Implementation**: Each feature has its own folder with view, controller, and service

### 3. Firebase Backend
- **Rationale**: Real-time sync, scalability, built-in authentication, reduced backend development
- **Implementation**: Direct Firestore integration with local caching

### 4. Multi-Device Sync Strategy
- **Approach**: Each device uploads steps independently with device ID
- **Aggregation**: Cloud Functions aggregate steps per user per day
- **Conflict Resolution**: Latest timestamp wins for same-day records

### 5. Leaderboard Updates
- **Strategy**: Scheduled Cloud Functions update leaderboards periodically
- **Real-time**: Firestore listeners provide live updates to clients
- **Optimization**: Cached rankings with TTL to reduce reads

## Security Considerations
- Firebase Security Rules for data access control
- User can only read/write their own data
- Leaderboards are read-only for clients
- Group members can only see group data
- Friend connections require mutual consent

## Performance Optimizations
- Firestore pagination for large data sets
- Local caching with SharedPreferences
- Lazy loading of user avatars and images
- Efficient widget rebuilds using const constructors
- Background step sync to avoid UI blocking

## Future Enhancements
- Challenge system for individual and group goals
- Rewards and gamification elements
- Integration with wearables (Fitbit, Apple Watch)
- Advanced analytics and insights
- Premium features and subscription model

---

**Last Updated**: December 16, 2025