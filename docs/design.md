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
- **State Management**: BLoC (Business Logic Component) with flutter_bloc
- **Navigation**: GoRouter (Declarative routing)
- **DI**: GetIt & Injectable
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
    ├── settings_bloc.dart      # Business logic & state
    ├── settings_event.dart     # Events
    ├── settings_state.dart     # State definitions
    └── settings_service.dart   # Data persistence
```

### State Management Pattern
### State Management Pattern
- **BLoC**: Handles business logic and state changes via Events and States
- **GetIt/Injectable**: For dependency injection of repositories/services
- **Services**: Handle raw data operations (Firestore, API)
- **Views**: Send Events to BLoCs and rebuild on State changes (BlocBuilder)

### Data Flow
### Data Flow
1. **User Action** → View adds an **Event** to the BLoC
2. **BLoC** → Processes event, calls Service/Repository
3. **Service** → Performs async work (Firebase, etc.)
4. **BLoC** → Emits new **State** based on result
5. **View** → UI rebuilds based on the new State

## Key Modules

### 1. Authentication Module
- **Sign Up**:
  - **Social Options**: Google, Apple (Recommended for lowest friction)
  - **Manual Fields**: Full Name, Email, Password, Confirm Password
- **Sign In**:
  - **Social Options**: Google, Apple
  - **Manual Fields**: Email, Password
- **Features**:
  - User registration and login via Firebase Auth
  - Profile management
  - Session persistence
  - *Note: Onboarding (Height, Weight, Gender) is deferred to after sign-up.*

### 2. Step Tracking Module
- **Reboot-Proof Tracking**: Real-time step counting using persistent delta-based accumulation to handle device reboots and sensor resets.
- **Time-Travel Support**: Seamlessly switch between live sensor data for the current day and historical data from Firestore for past dates.
- **Background Sync**: Automated background synchronization via `Workmanager` that persists accumulated totals and handles cross-day resets.
- **Historical Insights**: Daily, weekly, and monthly statistics retrieved from a unified repository.
- **Configurable Goals**: Customizable daily step goals with progress tracking.

### 3. Social Module
- Friend connections and management
- Activity feed showing friends' achievements
- Social sharing capabilities
- User profiles and avatars

### 4. Leaderboard Module
### 4. Leaderboard Module
- **Group Leaderboards**: Nested under Groups for easy access and permissions.
- **Friends Leaderboard**: Dynamic client-side sorting of friend data.
- **Time-based**: Weekly and Monthly resets.

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
  DateTime createdAt;
  List<String> connectedSources; // e.g. ["Apple Watch", "iPhone"]
  Map<String, dynamic> preferences;
  int dailyStepGoal; // default 10000
}

### Friend
```dart
class Friend {
  String uid; // The user ID of the friend (Foreign Key to User)
  DateTime connectedAt;
  String status; // e.g., 'pending', 'accepted'
}
```
```

### DailyStepRecord
```dart
class DailyStepRecord {
  String id; // format: "yyyy-MM-dd_deviceId"
  String userId;
  String date; // yyyy-MM-dd
  String deviceId; // The phone/tablet syncing the data
  int stepCount;
  int? caloriesBurned; 
  double? distanceMeters;
  int? flightsClimbed;
  DateTime lastUpdated;
  Map<String, int> hourlyBreakdown; // Optional: for graphs, simpler than raw intervals
}
```

### Group Leaderboard
```dart
class GroupLeaderboard {
  String id;
  String groupId; // Parent Group
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
    - daily_step_goal (int)
    daily_steps/
      {yyyy-MM-dd}/
        - stepCount
        - lastUpdated
    devices/
      {deviceId}/
        - device info

groups/
  {groupId}/
    - group data
    leaderboards/
      {leaderboardId}/
        - period (week/month)
        entries/
          {userId}/
            - rank, stepCount
    - group data
    members/
      {userId}/
        - role, joinedAt

friends/
      {friendId}/
        - status, connectedAt

### Entity Relationship Diagram
```mermaid
erDiagram
    USERS ||--o{ DEVICES : "subcollection: devices"
    USERS ||--o{ FRIENDS : "subcollection: friends"
    USERS ||--o{ DAILY_STEP_RECORDS : "subcollection: daily_steps"
    GROUPS ||--o{ GROUP_MEMBERS : "subcollection: members"
    GROUPS ||--o{ GROUP_LEADERBOARDS : "subcollection: leaderboards"

    USERS {
        string id PK
        string displayName
        string email
        string photoUrl
        settings map
    }

    DEVICES {
        string id PK
        string fcmToken
        string platform
    }

    DAILY_STEP_RECORDS {
        string id PK
        int stepCount
        timestamp lastUpdated
    }

    GROUPS {
        string id PK
        string name
        string creatorId FK
    }
```

    GROUP_LEADERBOARDS {
        string id PK
        string groupId FK
        timestamp period
    }
```
```

## Design Decisions

### 1. BLoC Pattern
- **Rationale**: Clear separation of concerns, excellent for event-driven flows (like step updates), and scalable for complex features.
- **Implementation**: strict Unidirectional Data Flow. `flutter_bloc` for UI binding.

### 2. Feature-Based Structure
- **Rationale**: Better scalability, clear boundaries, easier team collaboration
- **Implementation**: Each feature has its own folder with view, controller, and service

### 3. Firebase Backend
- **Rationale**: Real-time sync, scalability, built-in authentication, reduced backend development
- **Implementation**: Direct Firestore integration with local caching

### 4. Step Counting Logic & Sync Strategy
- **Actual Daily Step Count (Reboot-Proof)**:
    - **Persistent Delta Accumulation**: Switched from simple "Total - Start" subtraction to a delta-based accumulation. The app calculates the difference (delta) between consecutive sensor readings and adds it to a cumulative total.
    - **Reboot Handling**: Phone reboots reset the hardware sensor to 0. The app detects this by checking for negative deltas; if the current sensor value is less than the last known value, the app treats the current value as the new delta and continues accumulation.
    - **Source of Truth**: `SharedPreferences` serves as the local "source of truth" for cumulative daily steps, ensuring state is preserved across app kills and reboots.
- **Background Sync**:
    - Uses `Workmanager` to periodically sync the local accumulated total to Firestore.
    - The background task handles cross-day transitions by resetting the local counter when a new day begins.

### 5. Historical Data (Time-Travel)
- **Unified Repository**: `StepRepository` provides a transparent interface via `getStepsForDate(DateTime date)`.
- **Live vs. Historical**: 
    - For "Today", the app prioritizes live sensor data merged with the persistent local total.
    - For past dates, the app fetches historical records from Firestore.
- **Firestore Schema**: Daily steps are stored at `users/{userId}/daily_steps/{yyyy-MM-dd}` for efficient per-user querying and retrieval.

### 6. CI/CD Pipeline
- **Dual-Branch Strategy**: 
    - `dev` branch: Triggers full APK builds and distribution via Firebase App Distribution for internal testing.
    - Feature branches: Run lightweight static analysis, linting, and unit tests to ensure code quality before merging.

### 7. Leaderboard Updates
- **Strategy**: Scheduled Cloud Functions update leaderboards periodically
- **Real-time**: Firestore listeners provide live updates to clients
- **Optimization**: Cached rankings with TTL to reduce reads

## Security Considerations
- Firebase Security Rules for data access control
- **Minimal Data Collection**: We rely on Health Store calculations and explicitly do NOT collect height, weight, or gender to protect user privacy.
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

**Last Updated**: March 4, 2026