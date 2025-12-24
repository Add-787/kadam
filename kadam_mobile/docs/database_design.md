# Kadam - Database Design

## Overview
Kadam is a step tracking and fitness app that syncs health data from multiple platforms (Apple Health, Google Fit, Samsung Health, Fitbit) to Firebase Cloud Firestore. The database is designed to support leaderboards, user profiles, and historical health metrics.

---

## Complete Database Visualization

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                       KADAM COMPLETE DATABASE ARCHITECTURE                            │
│                                                                                       │
│  Legend:                                                                              │
│  [═══] = Collection    ─── = One-to-Many    ◄──► = Many-to-Many    ──▶ = References │
└─────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌─────────────────────┐
                                    │   HEALTH PLATFORMS  │
                                    │                     │
                    ┌───────────────┤ • Apple Health     │
                    │               │ • Google Fit       │
                    │               │ • Samsung Health   │
                    │               │ • Fitbit           │
                    │               └──────────┬──────────┘
                    │                          │
                    │                          │ Native APIs
                    │                          │
                    │                          ▼
                    │               ┌──────────────────────┐
                    │               │  METHOD CHANNELS     │
                    │               │  (Flutter ↔ Native)  │
                    │               └──────────┬───────────┘
                    │                          │
                    │                          │ Health Data
                    │                          │
                    │                          ▼
                    │               ┌──────────────────────┐
                    │               │   FIREBASE CLOUD     │
                    │               │     FIRESTORE        │
                    │               └──────────┬───────────┘
                    │                          │
                    │          ┌───────────────┼───────────────┐
                    │          │               │               │
                    ▼          ▼               ▼               ▼
╔═══════════════════════════════════╗  ╔═══════════════╗  ╔═══════════════╗
║        USERS COLLECTION           ║  ║ LEADERBOARDS  ║  ║  CHALLENGES   ║
║  ┌─────────────────────────────┐ ║  ║               ║  ║               ║
║  │ users/{userId}              │ ║  ║ (3 levels)    ║  ║ (Group comp.) ║
║  │ ─────────────────────────── │ ║  ╚═══════════════╝  ╚═══════════════╝
║  │ Profile:                    │ ║          │                   │
║  │ • userId, email, name       │ ║          │                   │
║  │ • photoURL, bio             │ ║          │                   │
║  │ • dailyStepGoal             │ ║          │                   │
║  │ • totalSteps, kadamScore    │ ║          │                   │
║  │ • currentStreak, bestStreak │ ║          │                   │
║  │ • friendCount, requestCount │ ║          │                   │
║  │                             │ ║          │                   │
║  │ Health Platforms:           │ ║          │                   │
║  │ • connectedPlatforms{}      │ ║          │                   │
║  │   - appleHealth: true       │ ║          │                   │
║  │   - googleFit: false        │ ║          │                   │
║  │   - samsungHealth: false    │ ║          │                   │
║  │   - fitbit: false           │ ║          │                   │
║  └─────────────────────────────┘ ║          │                   │
║              │                    ║          │                   │
║              │                    ║          │                   │
║   ┌──────────┼────────────┬──────┼──────┬───┼───────┐           │
║   │          │            │      │      │   │       │           │
║   ▼          ▼            ▼      ▼      ▼   ▼       ▼           │
║ ┌─────┐  ┌────────┐  ┌────────┐ ║  ┌────┐ ┌─────┐ ┌──────┐    │
║ │health│ │settings│  │achieve-│ ║  │frie│ │frie-│ │block-│    │
║ │_data │ │        │  │ ments  │ ║  │nds │ │nd_  │ │ed_   │    │
║ │{date}│ │prefer- │  │{achvId}│ ║  │{id}│ │reqs │ │users │    │
║ │      │ │ences   │  │        │ ║  │    │ │{id} │ │{id}  │    │
║ └──┬───┘ └────────┘  └────────┘ ║  └──┬─┘ └──┬──┘ └──────┘    │
║    │                             ║     │      │                 │
╚════╪═════════════════════════════╝     │      │                 │
     │                                   │      │                 │
     │ Steps, distance, calories         │      │                 │
     │ Source: Apple/Google/Samsung      │      │                 │
     └──────────────────┬────────────────┘      │                 │
                        │                        │                 │
                        │ Aggregates to          │                 │
                        │                        │                 │
                        ▼                        ▼                 │
            ╔═══════════════════════════════════════════╗          │
            ║      LEADERBOARDS COLLECTION              ║          │
            ║  ┌─────────────────────────────────────┐ ║          │
            ║  │ leaderboards/                       │ ║          │
            ║  │                                     │ ║          │
            ║  │ ┌─────────────────────────────────┐│ ║          │
            ║  │ │ global/ (Public - All Users)   ││ ║          │
            ║  │ │                                 ││ ║          │
            ║  │ │ ├── daily/                      ││ ║          │
            ║  │ │ │   └── {date}/                 ││ ║          │
            ║  │ │ │       └── rankings/{userId}   ││ ║          │
            ║  │ │ │           • steps             ││ ║          │
            ║  │ │ │           • rank              ││ ║          │
            ║  │ │ │           • kadamScore        ││ ║          │
            ║  │ │ │                               ││ ║          │
            ║  │ │ ├── weekly/                     ││ ║          │
            ║  │ │ │   └── {weekId}/               ││ ║          │
            ║  │ │ │       └── rankings/{userId}   ││ ║          │
            ║  │ │ │           • totalSteps        ││ ║          │
            ║  │ │ │           • daysActive        ││ ║          │
            ║  │ │ │                               ││ ║          │
            ║  │ │ └── all_time/                   ││ ║          │
            ║  │ │     └── rankings/{userId}       ││ ║          │
            ║  │ │         • totalSteps            ││ ║          │
            ║  │ │         • longestStreak         ││ ║          │
            ║  │ └─────────────────────────────────┘│ ║          │
            ║  │                                     │ ║          │
            ║  │ ┌─────────────────────────────────┐│ ║          │
            ║  │ │ friends/ (Private - Per User)  ││ ║          │
            ║  │ │                                 ││ ║          │
            ║  │ │ └── {userId}/                   ││ ║          │
            ║  │ │     ├── daily/{date}/           ││ ║          │
            ║  │ │     │   └── rankings/{friendId} ││ ║          │
            ║  │ │     │       • steps             ││ ║          │
            ║  │ │     │       • rank (among frnds)││ ║          │
            ║  │ │     │       • isFriend: true    ││ ║          │
            ║  │ │     │                           ││ ║          │
            ║  │ │     ├── weekly/{weekId}/        ││ ║          │
            ║  │ │     │   └── rankings/{friendId} ││ ║          │
            ║  │ │     │                           ││ ║          │
            ║  │ │     └── all_time/               ││ ║          │
            ║  │ │         └── rankings/{friendId} ││ ║          │
            ║  │ └─────────────────────────────────┘│ ║          │
            ║  └─────────────────────────────────────┘ ║          │
            ╚═══════════════════════════════════════════╝          │
                                                                   │
                                                                   │
                  ╔═══════════════════════════════════════════════╝
                  ║      CHALLENGES COLLECTION
                  ║  ┌─────────────────────────────────────┐
                  ║  │ challenges/{challengeId}            │
                  ║  │ ─────────────────────────────────── │
                  ║  │ Metadata:                           │
                  ║  │ • name, description                 │
                  ║  │ • type: 'daily'|'weekly'|'custom'   │
                  ║  │ • goal: 10000 (target value)        │
                  ║  │ • duration: 7 (days)                │
                  ║  │ • startDate, endDate                │
                  ║  │ • status: 'active'|'completed'      │
                  ║  │ • createdBy: userId                 │
                  ║  │ • participantCount, maxParticipants │
                  ║  │ • isPublic: true/false              │
                  ║  └─────────────────────────────────────┘
                  ║              │                 │
                  ║              │                 │
                  ║       ┌──────┴─────┐    ┌─────┴──────┐
                  ║       ▼            │    │            ▼
                  ║  ┌──────────┐      │    │      ┌──────────┐
                  ║  │particip- │      │    │      │leaderb-  │
                  ║  │ants/     │      │    │      │oard/     │
                  ║  │{userId}  │      │    │      │{userId}  │
                  ║  │          │      │    │      │          │
                  ║  │• current │      │    │      │• progress│
                  ║  │  Value   │      │    │      │• rank    │
                  ║  │• progress│◄─────┘    └─────▶│• last    │
                  ║  │• rank    │ updates           │  Updated │
                  ║  │• joinedAt│                   │          │
                  ║  │• complete│                   │(read-only│
                  ║  │  d:bool  │                   │ view)    │
                  ║  └──────────┘                   └──────────┘
                  ╚═══════════════════════════════════════════════


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                            RELATIONSHIP CONNECTIONS                                   │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌────────────┐                              ┌────────────┐
│   User A   │ ─────┐                 ┌──── │   User B   │
└────────────┘      │                 │     └────────────┘
                    │                 │
                    ▼                 ▼
            ┌───────────────────────────┐
            │   friend_requests/        │
            │                           │
            │  Request from A → B:      │
            │  • fromUserId: A          │
            │  • toUserId: B            │
            │  • status: 'pending'      │
            │  • type: 'outgoing' (A)   │
            │         'incoming' (B)    │
            └───────────┬───────────────┘
                        │
                        │ When accepted
                        │
                        ▼
            ┌───────────────────────────┐
            │   friends/                │
            │                           │
            │  A's friends/{B}          │
            │  B's friends/{A}          │
            │                           │
            │  Both can now see each    │
            │  other in friend          │
            │  leaderboards             │
            └───────────┬───────────────┘
                        │
                        │ Creates entries in
                        │
                        ▼
        ┌─────────────────────────────────┐
        │ leaderboards/friends/           │
        │                                 │
        │ A/daily/{date}/rankings/{B}     │
        │ B/daily/{date}/rankings/{A}     │
        └─────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                               DATA FLOW SEQUENCE                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘

1. USER REGISTRATION
   ┌──────┐     ┌──────────┐     ┌──────────┐
   │ User │────▶│ Firebase │────▶│ users/   │
   │      │     │   Auth   │     │ {userId} │
   └──────┘     └──────────┘     └──────────┘

2. HEALTH DATA SYNC
   ┌────────────┐     ┌──────────┐     ┌──────────────┐     ┌──────────────┐
   │ HealthKit/ │────▶│  Method  │────▶│   Flutter    │────▶│ users/{id}/  │
   │ Google Fit │     │ Channels │     │ Health Svc   │     │ health_data/ │
   └────────────┘     └──────────┘     └──────────────┘     └──────┬───────┘
                                                                     │
                                                                     │ Aggregates
                                                                     │
       ┌─────────────────────────────────────────────────────────────┘
       │
       ▼
   ┌──────────────────────┐
   │ Leaderboards Update  │
   │                      │
   │ • Global rankings    │
   │ • Friend rankings    │
   │ • Challenge progress │
   └──────────────────────┘

3. FRIEND REQUEST FLOW
   ┌───────┐  search   ┌───────┐  send req  ┌────────────────┐
   │User A │──────────▶│User B │◄───────────│ friend_requests│
   └───────┘           └───┬───┘            └────────────────┘
                           │
                           │ accepts
                           │
                           ▼
                   ┌───────────────┐
                   │   friends/    │
                   │   A/{B}       │
                   │   B/{A}       │
                   └───────────────┘
                           │
                           │ creates
                           │
                           ▼
                   ┌───────────────────┐
                   │ Friend Leaderboard│
                   │   entries         │
                   └───────────────────┘

4. CHALLENGE PARTICIPATION
   ┌───────┐  joins   ┌──────────────────┐  updates   ┌────────────────┐
   │ User  │─────────▶│ challenges/{id}/ │◄───────────│ health_data/   │
   └───────┘          │ participants/    │            │ (daily sync)   │
                      └────────┬─────────┘            └────────────────┘
                               │
                               │ reflects in
                               │
                               ▼
                      ┌─────────────────┐
                      │ challenges/{id}/│
                      │ leaderboard/    │
                      └─────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                          PRIVACY & VISIBILITY MATRIX                                  │
└─────────────────────────────────────────────────────────────────────────────────────┘

Data Type              │ Public  │ Friends │ Private │ Controlled By
───────────────────────┼─────────┼─────────┼─────────┼──────────────────────────
Profile (name, photo)  │    ✓    │    ✓    │         │ Always visible
Email                  │         │         │    ✓    │ Always private
Health data (daily)    │         │    ?    │    ✓    │ friendsCanViewHistory
Total steps            │    ?    │    ✓    │         │ showInGlobalLeaderboard
Global leaderboard     │    ?    │    ✓    │         │ showInGlobalLeaderboard
Friend leaderboard     │         │    ✓    │         │ Always visible to friends
Current steps (live)   │    ?    │    ✓    │         │ showInGlobalLeaderboard
Achievements           │    ?    │    ✓    │         │ User preference
Challenge participation│    ✓    │    ✓    │         │ Always visible if public
Friend requests        │    ✓    │    ✓    │         │ allowFriendRequests
───────────────────────┴─────────┴─────────┴─────────┴──────────────────────────

✓ = Always visible    ? = User controlled    (blank) = Never visible


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                            COLLECTION SIZE ESTIMATES                                  │
└─────────────────────────────────────────────────────────────────────────────────────┘

Assuming 10,000 active users:

Collection                  │ Documents    │ Size/Doc  │ Total Size  │ Growth
────────────────────────────┼──────────────┼───────────┼─────────────┼──────────
users/                      │    10,000    │    2 KB   │   20 MB     │ Slow
users/*/health_data/        │ 3,650,000    │    1 KB   │   3.65 GB   │ Daily
users/*/friends/            │    50,000    │   0.5 KB  │   25 MB     │ Medium
users/*/friend_requests/    │     5,000    │   0.3 KB  │   1.5 MB    │ High
users/*/achievements/       │    30,000    │   0.2 KB  │   6 MB      │ Medium
users/*/settings/           │    10,000    │    1 KB   │   10 MB     │ Rare
leaderboards/global/daily/  │ 3,650,000    │   0.5 KB  │   1.83 GB   │ Daily
leaderboards/friends/       │   500,000    │   0.5 KB  │   250 MB    │ Daily
challenges/                 │       100    │    2 KB   │   200 KB    │ Weekly
challenges/*/participants/  │    10,000    │   0.3 KB  │   3 MB      │ Medium
────────────────────────────┴──────────────┴───────────┴─────────────┴──────────
TOTAL                                                      ~5.78 GB

Note: Firestore costs based on:
- Document reads/writes (most expensive)
- Storage (cheap: $0.18/GB/month)
- Network egress (moderate)


┌─────────────────────────────────────────────────────────────────────────────────────┐
│                    DATA RETENTION STRATEGY & COST OPTIMIZATION                        │
└─────────────────────────────────────────────────────────────────────────────────────┘

## Strategy: 2-Month Rolling Window + Normalized Historical Data

### Retention Policy

```
┌────────────────────────────────────────────────────────────────────────┐
│                          DATA LIFECYCLE                                │
└────────────────────────────────────────────────────────────────────────┘

Day 0-60 (2 months)          │  Day 61+                
─────────────────────────────┼───────────────────────────────────
DETAILED DATA                │  NORMALIZED DATA
                             │
users/{id}/health_data/      │  users/{id}/health_summary/
├── {date}                   │  ├── monthly/{YYYY-MM}
│   ├── steps: 12,543        │  │   ├── totalSteps: 385,000
│   ├── distance: 9.2        │  │   ├── avgSteps: 12,833
│   ├── calories: 543        │  │   ├── bestDay: 18,234
│   ├── activeMinutes: 87    │  │   ├── streaks: 28
│   ├── floors: 12           │  │   ├── calories: 16,290
│   ├── source: "apple"      │  │   └── achievements: []
│   ├── stepsBySource: {}    │  │
│   └── lastSyncTime         │  └── yearly/{YYYY}
│                            │      ├── totalSteps: 4,562,000
Kept for 60 days             │      ├── avgDaily: 12,498
                             │      ├── bestMonth: "August"
                             │      ├── longestStreak: 94
                             │      └── topAchievements: []
                             │
                             │  Kept forever (minimal size)
```

### Data Normalization Process

```typescript
// Run daily via Cloud Functions
export const normalizeOldHealthData = functions.pubsub
  .schedule('0 2 * * *')  // 2 AM daily
  .onRun(async (context) => {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 60);
    
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .get();
    
    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      
      // Get all health_data older than 60 days
      const oldDataSnapshot = await admin.firestore()
        .collection(`users/${userId}/health_data`)
        .where('date', '<', cutoffDate)
        .get();
      
      if (oldDataSnapshot.empty) continue;
      
      // Group by month and calculate aggregates
      const monthlyData = groupByMonth(oldDataSnapshot.docs);
      
      // Save normalized monthly summaries
      for (const [month, data] of Object.entries(monthlyData)) {
        await admin.firestore()
          .doc(`users/${userId}/health_summary/monthly/${month}`)
          .set({
            totalSteps: data.totalSteps,
            avgSteps: data.avgSteps,
            bestDay: data.bestDay,
            bestDaySteps: data.bestDaySteps,
            daysActive: data.daysActive,
            totalDistance: data.totalDistance,
            totalCalories: data.totalCalories,
            longestStreak: data.longestStreak,
            achievements: data.achievements,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
      }
      
      // Delete old detailed records
      const batch = admin.firestore().batch();
      oldDataSnapshot.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
      
      console.log(`Normalized ${oldDataSnapshot.size} records for user ${userId}`);
    }
  });

function groupByMonth(docs: FirebaseFirestore.QueryDocumentSnapshot[]): MonthlyData {
  const monthlyData: { [month: string]: any } = {};
  
  docs.forEach(doc => {
    const data = doc.data();
    const date = new Date(data.date);
    const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
    
    if (!monthlyData[monthKey]) {
      monthlyData[monthKey] = {
        totalSteps: 0,
        totalDistance: 0,
        totalCalories: 0,
        daysActive: 0,
        bestDaySteps: 0,
        bestDay: null,
        dailySteps: [],
        achievements: [],
      };
    }
    
    const month = monthlyData[monthKey];
    month.totalSteps += data.steps || 0;
    month.totalDistance += data.distance || 0;
    month.totalCalories += data.calories || 0;
    month.daysActive += (data.steps > 0) ? 1 : 0;
    month.dailySteps.push(data.steps || 0);
    
    if (data.steps > month.bestDaySteps) {
      month.bestDaySteps = data.steps;
      month.bestDay = data.date;
    }
    
    if (data.achievements) {
      month.achievements.push(...data.achievements);
    }
  });
  
  // Calculate averages and streaks
  Object.keys(monthlyData).forEach(month => {
    const data = monthlyData[month];
    data.avgSteps = Math.round(data.totalSteps / data.daysActive);
    data.longestStreak = calculateStreak(data.dailySteps);
    delete data.dailySteps; // Remove temp data
  });
  
  return monthlyData;
}
```

### Cost Comparison

**Scenario: 10,000 active users over 1 year**

#### Current Approach (Keep All Data Forever)

```
Health Data Storage:
├── Year 1: 10,000 users × 365 days × 1 KB = 3.65 GB
├── Year 2: 10,000 users × 730 days × 1 KB = 7.30 GB
├── Year 3: 10,000 users × 1,095 days × 1 KB = 10.95 GB
└── Year 5: 10,000 users × 1,825 days × 1 KB = 18.25 GB

Storage Costs (at $0.18/GB/month):
├── Year 1: 3.65 GB × $0.18 = $0.66/month = $7.92/year
├── Year 2: 7.30 GB × $0.18 = $1.31/month = $15.72/year
├── Year 3: 10.95 GB × $0.18 = $1.97/month = $23.64/year
└── Year 5: 18.25 GB × $0.18 = $3.29/month = $39.48/year

TOTAL COST (5 years): $86.76
```

#### Optimized Approach (2-Month Window + Normalized Data)

```
Health Data Storage:
├── Detailed data (60 days): 10,000 users × 60 days × 1 KB = 600 MB
├── Monthly summaries: 10,000 users × 60 months × 0.5 KB = 300 MB
└── Total: 900 MB = 0.9 GB (steady state)

Storage Costs (at $0.18/GB/month):
├── Year 1: 0.9 GB × $0.18 = $0.16/month = $1.92/year
├── Year 2: 0.9 GB × $0.18 = $0.16/month = $1.92/year
├── Year 3: 0.9 GB × $0.18 = $0.16/month = $1.92/year
└── Year 5: 0.9 GB × $0.18 = $0.16/month = $1.92/year

TOTAL COST (5 years): $9.60

Additional Costs:
├── Cloud Function executions: ~$0.50/month = $6.00/year
├── Document deletions: ~$0.20/month = $2.40/year
└── Document writes (summaries): ~$0.10/month = $1.20/year

TOTAL WITH OPERATIONS: $9.60 + $9.60 = $19.20 (5 years)
```

### Cost Savings Analysis

```
┌──────────────────────────────────────────────────────────────────────┐
│                         COST COMPARISON                              │
├────────────┬─────────────┬─────────────────┬─────────────────────────┤
│  Period    │  Full Data  │  2-Month Window │  Savings                │
├────────────┼─────────────┼─────────────────┼─────────────────────────┤
│  Year 1    │   $7.92     │     $4.80       │  $3.12    (39%)         │
│  Year 2    │  $23.64     │     $9.60       │ $14.04    (59%)         │
│  Year 3    │  $47.28     │    $14.40       │ $32.88    (70%)         │
│  Year 5    │  $86.76     │    $19.20       │ $67.56    (78%)         │
├────────────┴─────────────┴─────────────────┴─────────────────────────┤
│  5-Year Savings: $67.56 (78% reduction)                              │
└──────────────────────────────────────────────────────────────────────┘

Savings Scale with Users:
├── 10,000 users: $67.56 saved over 5 years
├── 50,000 users: $337.80 saved over 5 years
└── 100,000 users: $675.60 saved over 5 years
```

### What Gets Preserved in Normalized Data

```typescript
// users/{userId}/health_summary/monthly/{YYYY-MM}
{
  month: "2025-12",
  totalSteps: 387,234,
  avgSteps: 12,491,
  bestDay: "2025-12-15",
  bestDaySteps: 18,432,
  daysActive: 31,
  totalDistance: 284.5,        // km
  totalCalories: 16,892,
  longestStreak: 28,
  achievements: [
    { id: "first_10k", unlockedOn: "2025-12-05" },
    { id: "week_streak", unlockedOn: "2025-12-12" }
  ],
  createdAt: Timestamp,
}

// users/{userId}/health_summary/yearly/{YYYY}
{
  year: "2025",
  totalSteps: 4,562,891,
  avgSteps: 12,501,
  bestMonth: "August",
  bestMonthSteps: 425,678,
  bestDay: "2025-08-12",
  bestDaySteps: 22,145,
  daysActive: 365,
  longestStreak: 94,
  totalDistance: 3,342.8,      // km
  totalCalories: 198,456,
  achievements: [/* top 10 */],
  createdAt: Timestamp,
}
```

### Data You Still Have Access To

**✅ Available (Recent 60 Days)**
- Exact daily step counts
- Source breakdown (Apple/Google/Samsung)
- Hourly activity patterns
- Distance, calories, floors, active minutes
- Sync timestamps
- Detailed for leaderboards & friend comparisons

**✅ Available (Historical - Normalized)**
- Monthly totals and averages
- Best day/month records
- Streak information
- Total achievements
- Yearly summaries
- Long-term trends

**❌ Lost After 60 Days**
- Exact daily breakdowns (only monthly aggregates)
- Hourly patterns for old dates
- Source attribution for old data
- Sync timestamps for old data

### Leaderboard Impact

```
┌──────────────────────────────────────────────────────────────────────┐
│              LEADERBOARD DATA RETENTION                              │
└──────────────────────────────────────────────────────────────────────┘

Current Implementation:
├── Daily leaderboards: Keep forever (for historical viewing)
├── Weekly leaderboards: Keep forever
└── All-time leaderboards: Keep forever

Storage: 1.83 GB (year 1) → 9.15 GB (year 5)

Optimized Approach:
├── Daily leaderboards: Keep 90 days (3 months)
├── Weekly leaderboards: Keep 1 year
└── All-time leaderboards: Keep forever (updated from summaries)

Storage: ~500 MB steady state

Leaderboard Normalization:
// Keep weekly/monthly winner archives
archives/leaderboards/
├── daily_winners/
│   └── {YYYY-MM}/
│       └── {date}  // Top 10 only
├── weekly_winners/
│   └── {YYYY}/
│       └── {week}  // Top 10 only
└── monthly_winners/
    └── {YYYY}/
        └── {month}  // Top 50

This allows "throwback" features like:
- "Top performers of December 2024"
- "Your best month: August 2025"
- Without storing all individual rankings
```

### Recommended Data Retention Policy

```yaml
retention_policy:
  health_data:
    detailed: 60 days          # Full granularity
    monthly_summary: Forever   # Aggregated stats
    yearly_summary: Forever    # Aggregated stats
  
  leaderboards:
    daily_global: 90 days      # Recent competition
    daily_friends: 90 days     # Friend comparison
    weekly: 1 year             # Seasonal trends
    monthly_archives: Forever  # Top performers
    all_time: Forever          # Historical records
  
  friends:
    active: Forever            # Current friends
    requests: 30 days          # After rejection/accept
    blocked: Forever           # Security
  
  challenges:
    active: Forever            # Ongoing
    completed: 1 year          # Recent history
    archived: Forever          # Basic info only
```

### Implementation Schedule

```
Phase 1 (Week 1):
└── Create health_summary collection structure
    └── Add monthly/yearly document schemas

Phase 2 (Week 2):
└── Implement normalization Cloud Function
    └── Test with small user subset

Phase 3 (Week 3):
└── Deploy data retention policies
    └── Schedule daily cleanup jobs

Phase 4 (Week 4):
└── One-time bulk normalization of existing data
    └── Monitor storage reduction

Phase 5 (Ongoing):
└── Automated daily process
    └── Monthly cost tracking
```

### Cost Summary

**For 10,000 Users:**

| Metric | Current | Optimized | Savings |
|--------|---------|-----------|---------|
| Storage (Year 1) | 3.65 GB | 0.9 GB | 75% |
| Storage (Year 5) | 18.25 GB | 0.9 GB | 95% |
| Monthly Cost (Year 1) | $0.66 | $0.40 | $0.26 |
| Monthly Cost (Year 5) | $3.29 | $0.40 | $2.89 |
| 5-Year Total | $86.76 | $19.20 | **$67.56 (78%)** |

**Additional Benefits:**
- ✅ Faster queries (less data to scan)
- ✅ Lower read costs (fewer documents)
- ✅ Better app performance
- ✅ Compliance with data minimization principles
- ✅ Easier backups and migrations
- ✅ Preserved insights (summaries, streaks, records)

**Trade-offs:**
- ❌ Can't see exact steps from 3 months ago
- ❌ Can't recreate historical hourly charts
- ❌ Some audit trail loss
- ⚠️ Requires Cloud Function implementation
- ⚠️ One-time migration effort

```

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          KADAM DATABASE ARCHITECTURE                          │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                              USERS COLLECTION                                 │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │ users/{userId}                                                      │     │
│  │ • userId, email, displayName, photoURL                             │     │
│  │ • dailyStepGoal, heightCm, weightKg                                │     │
│  │ • connectedPlatforms{}                                             │     │
│  │ • totalSteps, currentStreak, kadamScore                            │     │
│  │ • friendCount, pendingRequestsCount                                │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│         │                │              │              │              │      │
│         │                │              │              │              │      │
│         ▼                ▼              ▼              ▼              ▼      │
│  ┌─────────────┐ ┌──────────┐   ┌───────────┐ ┌──────────┐ ┌──────────┐   │
│  │health_data/ │ │settings/ │   │achievements│ │ friends/ │ │ blocked_ │   │
│  │  {date}     │ │preferences│   │{achievmtId}│ │{friendId}│ │ users/   │   │
│  │             │ │          │   │            │ │          │ │{blockedId}│  │
│  │• steps      │ │• notif.  │   │• name      │ │• canView │ │• reason  │   │
│  │• distance   │ │• privacy │   │• type      │ │• current │ │• blockedAt│  │
│  │• calories   │ │• sync    │   │• unlocked  │ │  Steps   │ │          │   │
│  │• source     │ │• units   │   │• tier      │ │• rank    │ │          │   │
│  │• stepsByS{} │ │          │   │            │ │          │ │          │   │
│  └─────────────┘ └──────────┘   └───────────┘ └──────────┘ └──────────┘   │
│                                                      │                        │
│                  ┌──────────────────────────────────┘                        │
│                  │                                                            │
│                  ▼                                                            │
│          ┌───────────────┐                                                   │
│          │friend_requests│                                                   │
│          │  {requestId}  │                                                   │
│          │               │                                                   │
│          │• fromUserId   │◄──────────────┐                                  │
│          │• toUserId     │               │                                  │
│          │• status       │               │                                  │
│          │• type         │               │                                  │
│          │• sentAt       │               │                                  │
│          └───────────────┘               │                                  │
└──────────────────────────────────────────┼──────────────────────────────────┘
                                            │
                                            │ (references userId)
                                            │
┌───────────────────────────────────────────┼──────────────────────────────────┐
│                      LEADERBOARDS COLLECTION              │                   │
│                                                           │                   │
│  ┌────────────────────────────────────────────────────────┘                  │
│  │                                                                            │
│  ▼                                                                            │
│  leaderboards/                                                               │
│  ├── global/                                                                 │
│  │   ├── daily/{date}/rankings/{userId} ◄────┐                              │
│  │   │   • steps, rank, kadamScore           │                              │
│  │   ├── weekly/{weekId}/rankings/{userId}   │                              │
│  │   │   • totalSteps, daysActive            │                              │
│  │   └── all_time/rankings/{userId}          │ (aggregated from users)      │
│  │       • totalSteps, longestStreak         │                              │
│  │                                            │                              │
│  └── friends/                                 │                              │
│      └── {userId}/                            │                              │
│          ├── daily/{date}/rankings/{friendId}─┤                              │
│          ├── weekly/{weekId}/rankings/{friendId}                             │
│          └── all_time/rankings/{friendId}                                    │
│              • steps, rank, isFriend                                         │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                         CHALLENGES COLLECTION                                 │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │ challenges/{challengeId}                                            │     │
│  │ • name, description, createdBy                                      │     │
│  │ • type, goal, duration                                              │     │
│  │ • startDate, endDate, status                                        │     │
│  │ • participantCount, maxParticipants                                 │     │
│  └────────────────────────────────────────────────────────────────────┘     │
│         │                                    │                               │
│         │                                    │                               │
│         ▼                                    ▼                               │
│  ┌──────────────────┐              ┌──────────────────┐                     │
│  │  participants/   │              │  leaderboard/    │                     │
│  │    {userId}      │              │    {userId}      │                     │
│  │                  │              │                  │                     │
│  │ • currentValue   │              │ • progress       │                     │
│  │ • progress       │              │ • rank           │                     │
│  │ • rank           │              │ • lastUpdated    │                     │
│  │ • joinedAt       │              │                  │                     │
│  │ • completed      │              │ (read-only)      │                     │
│  └──────────────────┘              └──────────────────┘                     │
│         │                                    ▲                               │
│         └────────────────────────────────────┘                               │
│              (participants data feeds leaderboard)                           │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                            DATA FLOW DIAGRAM                                  │
└──────────────────────────────────────────────────────────────────────────────┘

    ┌───────────┐  ┌───────────┐  ┌──────────┐  ┌─────────┐
    │Apple      │  │Google     │  │Samsung   │  │Fitbit   │
    │Health     │  │Fit        │  │Health    │  │         │
    └─────┬─────┘  └─────┬─────┘  └────┬─────┘  └────┬────┘
          │              │              │             │
          └──────────────┴──────────────┴─────────────┘
                         │
                         ▼
                ┌────────────────────┐
                │  Method Channels   │
                │  (Native Bridge)   │
                └─────────┬──────────┘
                          │
                          ▼
                ┌──────────────────────┐
                │   Flutter App        │
                │   Health Service     │
                └─────────┬────────────┘
                          │
                          ▼
          ┌───────────────────────────────────┐
          │      Firebase Sync Service        │
          └───────────────┬───────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌────────────┐    ┌──────────────┐  ┌─────────────┐
│users/      │    │leaderboards/ │  │challenges/  │
│{userId}/   │───▶│global/       │  │{id}/        │
│health_data │    │friends/      │  │leaderboard  │
└────────────┘    └──────────────┘  └─────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                         RELATIONSHIP TYPES                                    │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────┐          ┌──────────────┐
│ User         │ 1      * │HealthData    │
│              ├─────────▶│ (Daily)      │  ONE user has MANY health_data docs
└──────────────┘          └──────────────┘

┌──────────────┐          ┌──────────────┐
│ User         │ *      * │ User         │
│ (Sender)     ├─────────▶│ (Friend)     │  MANY-to-MANY friendship
└──────────────┘          └──────────────┘
       │                         ▲
       │  friend_requests        │
       └─────────────────────────┘

┌──────────────┐          ┌──────────────┐
│ User         │ *      * │ Challenge    │
│              ├─────────▶│              │  MANY users in MANY challenges
└──────────────┘          └──────────────┘

┌──────────────┐          ┌──────────────┐
│ User         │ 1      1 │ Settings     │
│              ├─────────▶│              │  ONE user has ONE settings doc
└──────────────┘          └──────────────┘

┌──────────────┐          ┌──────────────┐
│ User         │ 1      * │ Achievement  │
│              ├─────────▶│              │  ONE user has MANY achievements
└──────────────┘          └──────────────┘

┌──────────────┐          ┌──────────────┐
│ User         │ 1      * │ Leaderboard  │
│              ├─────────▶│ Ranking      │  ONE user in MANY leaderboards
└──────────────┘          └──────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│                         KEY INDEXES (Performance)                             │
└──────────────────────────────────────────────────────────────────────────────┘

health_data:
  ├── date (ASC)               → Time-series queries
  ├── steps (DESC)             → Top step counts
  └── timestamp (DESC)         → Recent syncs

friends:
  ├── currentSteps (DESC)      → Friend leaderboard
  ├── kadamScore (DESC)        → Score-based ranking
  └── friendsSince (DESC)      → Recent friends

friend_requests:
  ├── status (ASC)             → Filter by status
  ├── sentAt (DESC)            → Recent requests
  └── type (ASC)               → incoming/outgoing

leaderboards/*/rankings:
  ├── steps (DESC)             → Daily/weekly ranking
  ├── kadamScore (DESC)        → Score-based ranking
  └── rank (ASC)               → Position lookup

challenges/*/participants:
  ├── currentValue (DESC)      → Challenge ranking
  ├── progress (DESC)          → Progress tracking
  └── joinedAt (ASC)           → Early participants

┌──────────────────────────────────────────────────────────────────────────────┐
│                      PRIVACY & SECURITY LAYERS                                │
└──────────────────────────────────────────────────────────────────────────────┘

┌────────────────┐
│ User Settings  │
│ /preferences   │
└───────┬────────┘
        │
        ├─► showInGlobalLeaderboard: true/false
        ├─► leaderboardDisplayName: 'full' | 'initials' | 'anonymous'
        ├─► shareProfilePicture: true/false
        ├─► allowFriendRequests: true/false
        └─► friendsCanViewHistory: true/false
                │
                ▼
        ┌────────────────┐
        │ Firestore      │
        │ Security Rules │
        └───────┬────────┘
                │
                ├─► Global Leaderboard: Read if authenticated
                ├─► Friend Leaderboard: Read if owner
                ├─► Health Data: Read/Write if owner only
                ├─► Friend Requests: Create if authenticated
                └─► Blocked Users: Read/Write if owner only

```

---

## Database Structure

### Firebase Cloud Firestore Collections

```
firestore/
├── users/
│   ├── {userId}/
│   │   ├── profile (document fields)
│   │   ├── health_data/ (subcollection)
│   │   │   └── {date}/ (YYYY-MM-DD)
│   │   ├── settings/ (subcollection)
│   │   │   └── preferences (document)
│   │   ├── achievements/ (subcollection)
│   │   │   └── {achievementId}
│   │   ├── friends/ (subcollection)
│   │   │   └── {friendUserId}
│   │   ├── friend_requests/ (subcollection)
│   │   │   └── {requestId}
│   │   └── blocked_users/ (subcollection)
│   │       └── {blockedUserId}
│
├── leaderboards/
│   ├── daily/
│   │   └── {date}/ (YYYY-MM-DD)
│   │       └── rankings/ (subcollection)
│   │           └── {userId}
│   ├── weekly/
│   │   └── {weekId}/ (YYYY-WW)
│   │       └── rankings/ (subcollection)
│   │           └── {userId}
│   └── all_time/
│       └── rankings/ (subcollection)
│           └── {userId}
│
└── challenges/
    └── {challengeId}/
        ├── participants/ (subcollection)
        │   └── {userId}
        └── leaderboard/ (subcollection)
            └── {userId}
```

---

## Collection Schemas

### 1. **users/{userId}** (Document)

User profile and account information.

```typescript
{
  userId: string;              // Firebase Auth UID
  email: string;               // User email
  displayName: string;         // User's display name
  photoURL?: string;           // Profile picture URL
  createdAt: Timestamp;        // Account creation date
  updatedAt: Timestamp;        // Last profile update
  
  // Health settings
  dailyStepGoal: number;       // Default: 10000
  heightCm?: number;           // Height in centimeters
  weightKg?: number;           // Weight in kilograms
  
  // App preferences
  theme: string;               // 'light' | 'dark' | 'system'
  language: string;            // 'en' | 'hi' etc.
  
  // Platform connections
  connectedPlatforms: {
    appleHealth?: boolean;
    googleFit?: boolean;
    samsungHealth?: boolean;
    fitbit?: boolean;
  };
  
  // Stats (denormalized for quick access)
  totalSteps: number;          // All-time total steps
  currentStreak: number;       // Current daily streak
  longestStreak: number;       // Longest streak achieved
  kadamScore: number;          // Calculated score (0-100)
  
  // Social
  friendCount: number;         // Total friends
  pendingRequestsCount: number; // Incoming friend requests
}
```

### 2. **users/{userId}/friends/{friendUserId}** (Subcollection)

User's friends list.

```typescript
{
  userId: string;              // Friend's user ID
  displayName: string;         // Friend's display name
  photoURL?: string;           // Friend's profile picture
  
  // Friendship details
  friendsSince: Timestamp;     // When friendship was established
  
  // Privacy settings
  canViewSteps: boolean;       // Can see step count
  canViewProfile: boolean;     // Can see full profile
  
  // Activity
  lastActive?: Timestamp;      // Last time friend was active
  
  // Quick stats (denormalized for leaderboard)
  currentSteps: number;        // Today's steps
  kadamScore: number;          // Current score
  rank?: number;               // Position in friend leaderboard
}
```

**Indexes:**
- `currentSteps` (descending)
- `kadamScore` (descending)
- `friendsSince` (descending)

### 3. **users/{userId}/friend_requests/{requestId}** (Subcollection)

Incoming and outgoing friend requests.

```typescript
{
  requestId: string;           // Unique request ID
  
  // Request details
  fromUserId: string;          // Who sent the request
  toUserId: string;            // Who receives the request
  
  // User info (denormalized for quick display)
  senderDisplayName: string;
  senderPhotoURL?: string;
  recipientDisplayName: string;
  recipientPhotoURL?: string;
  
  // Status
  status: string;              // 'pending' | 'accepted' | 'rejected' | 'cancelled'
  type: string;                // 'incoming' | 'outgoing'
  
  // Timestamps
  sentAt: Timestamp;
  respondedAt?: Timestamp;
  expiresAt?: Timestamp;       // Auto-expire after 30 days
  
  // Optional message
  message?: string;            // Personal message with request
}
```

**Indexes:**
- `status` (ascending)
- `sentAt` (descending)
- `type` (ascending)

### 4. **users/{userId}/blocked_users/{blockedUserId}** (Subcollection)

Users that have been blocked.

```typescript
{
  userId: string;              // Blocked user ID
  displayName: string;         // Blocked user's display name
  photoURL?: string;           // Blocked user's profile picture
  
  blockedAt: Timestamp;
  reason?: string;             // Optional block reason
}
```

### 5. **users/{userId}/health_data/{date}** (Subcollection)

Daily health metrics for each user.

```typescript
{
  date: string;                // YYYY-MM-DD format
  steps: number;               // Total steps for the day
  distance: number;            // Distance in meters
  calories: number;            // Calories burned (kcal)
  heartRate?: number;          // Average heart rate (BPM)
  activeMinutes?: number;      // Active minutes
  
  // Multi-source tracking
  stepsBySource?: {
    apple_health?: number;
    google_fit?: number;
    samsung_health?: number;
    fitbit?: number;
  };
  
  // Metadata
  timestamp: Timestamp;        // When data was synced
  synced: boolean;             // Sync status
  source: string;              // Primary data source
  lastSyncedAt: Timestamp;     // Last sync timestamp
}
```

**Indexes:**
- `date` (ascending)
- `steps` (descending)
- `timestamp` (descending)

### 6. **users/{userId}/settings/preferences** (Document)

User preferences and app settings.

```typescript
{
  // Notifications
  notifications: {
    enabled: boolean;
    goalReminders: boolean;
    streakReminders: boolean;
    leaderboardUpdates: boolean;
    challengeInvites: boolean;
  };
  
  // Privacy
  privacy: {
    showInLeaderboard: boolean;
    shareProfilePicture: boolean;
    shareStepData: boolean;
    allowFriendRequests: boolean;
    friendsCanViewHistory: boolean;
  };
  
  // Sync settings
  sync: {
    autoSync: boolean;
    syncInterval: string;       // '1h' | '3h' | '6h'
    wifiOnly: boolean;
    backgroundSync: boolean;
  };
  
  // Units
  distanceUnit: string;         // 'km' | 'mi'
  
  updatedAt: Timestamp;
}
```

### 7. **users/{userId}/achievements/{achievementId}** (Subcollection)

User achievements and milestones.

```typescript
{
  achievementId: string;        // Achievement identifier
  name: string;                 // Achievement name
  description: string;          // Achievement description
  icon: string;                 // Icon identifier
  unlockedAt: Timestamp;        // When achievement was earned
  
  // Achievement criteria
  type: string;                 // 'steps' | 'streak' | 'challenge'
  threshold: number;            // Required value
  
  // Display
  tier: string;                 // 'bronze' | 'silver' | 'gold'
  rarity: string;               // 'common' | 'rare' | 'epic'
}
```

### 8. **leaderboards/daily/{date}/rankings/{userId}** (Document)

Daily leaderboard rankings.

```typescript
{
  userId: string;
  displayName: string;
  photoURL?: string;
  steps: number;
  distance: number;
  calories: number;
  rank: number;                 // Position in leaderboard
  kadamScore: number;           // Daily score
  
  // Metadata
  lastUpdated: Timestamp;
  date: string;                 // YYYY-MM-DD
}
```

**Indexes:**
- `steps` (descending)
- `kadamScore` (descending)
- `rank` (ascending)

### 9. **leaderboards/weekly/{weekId}/rankings/{userId}** (Document)

Weekly leaderboard rankings.

```typescript
{
  userId: string;
  displayName: string;
  photoURL?: string;
  totalSteps: number;           // Week total
  averageSteps: number;         // Daily average
  daysActive: number;           // Days with steps > 0
  rank: number;
  kadamScore: number;           // Weekly score
  
  weekId: string;               // YYYY-WW format
  weekStart: Timestamp;
  weekEnd: Timestamp;
  lastUpdated: Timestamp;
}
```

### 10. **leaderboards/all_time/rankings/{userId}** (Document)

All-time leaderboard rankings.

```typescript
{
  userId: string;
  displayName: string;
  photoURL?: string;
  totalSteps: number;           // All-time total
  currentStreak: number;
  longestStreak: number;
  rank: number;
  kadamScore: number;           // Overall score
  
  // Stats
  totalDays: number;            // Days tracked
  averageDailySteps: number;
  totalDistance: number;        // Total meters
  totalCalories: number;
  
  lastUpdated: Timestamp;
}
```

### 11. **challenges/{challengeId}** (Document)

Group challenges and competitions.

```typescript
{
  challengeId: string;
  name: string;
  description: string;
  createdBy: string;            // userId
  
  // Challenge details
  type: string;                 // 'steps' | 'distance' | 'streak'
  goal: number;                 // Target value
  duration: string;             // 'daily' | 'weekly' | 'custom'
  
  // Timing
  startDate: Timestamp;
  endDate: Timestamp;
  
  // Participation
  participantCount: number;
  maxParticipants?: number;
  
  // Status
  status: string;               // 'active' | 'completed' | 'cancelled'
  
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 12. **challenges/{challengeId}/participants/{userId}** (Subcollection)

Challenge participants and their progress.

```typescript
{
  userId: string;
  displayName: string;
  photoURL?: string;
  
  // Progress
  currentValue: number;         // Current steps/distance
  progress: number;             // Percentage (0-100)
  rank: number;
  
  // Status
  joinedAt: Timestamp;
  lastUpdated: Timestamp;
  completed: boolean;
  completedAt?: Timestamp;
}
```

---

## Data Models (Flutter/Dart)

### HealthData Model
```dart
class HealthData {
  final String id;
  final HealthPlatform source;
  final String dataType;
  final dynamic value;
  final String unit;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic>? metadata;
}
```

### HealthMetrics Model
```dart
class HealthMetrics {
  final DateTime date;
  final int steps;
  final double distance;           // meters
  final double calories;           // kcal
  final int? heartRate;            // BPM
  final int? activeMinutes;
  final Map<HealthPlatform, int>? stepsBySource;
}
```

### PlatformCapability Model
```dart
enum HealthPlatform {
  appleHealth,
  googleFit,
  samsungHealth,
  healthConnect,
  fitbit,
  none,
}

class PlatformCapability {
  final HealthPlatform platform;
  final bool isAvailable;
  final bool isAuthorized;
  final String version;
  final List<String> supportedDataTypes;
}
```

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
      
      // Health data subcollection
      match /health_data/{date} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }
      
      // Settings subcollection
      match /settings/{document=**} {
        allow read, write: if isOwner(userId);
      }
      
      // Achievements subcollection
      match /achievements/{achievementId} {
        allow read: if isAuthenticated();
        allow write: if isOwner(userId);
      }
      
      // Friends subcollection
      match /friends/{friendUserId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }
      
      // Friend requests subcollection
      match /friend_requests/{requestId} {
        allow read: if isOwner(userId);
        allow create: if isAuthenticated();
        allow update: if isOwner(userId) 
          || request.auth.uid == resource.data.fromUserId;
        allow delete: if isOwner(userId);
      }
      
      // Blocked users subcollection
      match /blocked_users/{blockedUserId} {
        allow read, write: if isOwner(userId);
      }
    }
    
    // Leaderboards - read-only for all authenticated users
    match /leaderboards/{type}/{period}/rankings/{userId} {
      allow read: if isAuthenticated();
      allow write: if false; // Only backend can write
    }
    
    // Challenges
    match /challenges/{challengeId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated() 
        && resource.data.createdBy == request.auth.uid;
      
      match /participants/{userId} {
        allow read: if isAuthenticated();
        allow write: if isOwner(userId);
      }
      
      match /leaderboard/{userId} {
        allow read: if isAuthenticated();
        allow write: if false; // Backend only
      }
    }
  }
}
```

---

## Background Sync Strategy

### Sync Intervals
- **WiFi + Charging**: Every 1 hour
- **WiFi**: Every 3 hours
- **Cellular**: Every 6 hours
- **Low Battery (<20%)**: Every 12 hours

### Sync Process
1. Fetch latest health data from native platforms
2. Calculate daily metrics (steps, distance, calories)
3. Update user's health_data collection
4. Update user's profile stats (totalSteps, currentStreak)
5. Update relevant leaderboards
6. Check for achievement unlocks

### Leaderboard Update Strategy
- **Daily**: Update every sync
- **Weekly**: Update once per hour
- **All-time**: Update every 6 hours

---

## Kadam Score Calculation

The Kadam Score (0-100) is calculated using multiple factors:

```dart
// Weights for score components
consistency: 30%    // Daily goal achievement
volume: 25%         // Total steps
intensity: 20%      // Workout sessions (future)
improvement: 15%    // Week-over-week growth
social: 10%         // Challenges & competition

// Streak bonuses
7 days = 10% bonus
14 days = 20% bonus
30 days = 30% bonus
60 days = 40% bonus
90 days = 50% bonus
```

---

## Data Retention Policy

- **Health Data**: 365 days (1 year) in Firestore
- **Leaderboards**: 90 days for daily, 52 weeks for weekly
- **Achievements**: Permanent
- **User Profiles**: Active until account deletion

---

## Future Enhancements

1. **Workout Sessions** - Track specific workouts
2. **Social Feed** - Activity feed showing friends' achievements
3. **Private Challenges** - Challenge specific friends
4. **Friend Groups** - Create groups of friends for group challenges
5. **Direct Messaging** - Chat with friends
6. **Gamification** - Badges, levels, rewards
7. **Analytics** - Advanced insights and trends
8. **Integrations** - More wearables and platforms
9. **Offline Mode** - Better offline support with local database

---

## Friend Request Flow

### Sending a Friend Request

1. **Search for user** by username/email
2. **Check if already friends** or request pending
3. **Check if blocked** by either user
4. **Create request document** in both users' collections:
   - Sender's `friend_requests` → type: "outgoing"
   - Recipient's `friend_requests` → type: "incoming"
5. **Update counters**: Increment recipient's `pendingRequestsCount`
6. **Send push notification** to recipient

### Accepting a Friend Request

1. **Update request status** to "accepted"
2. **Create friend documents** in both users' `friends` subcollections
3. **Update counters**: 
   - Increment both users' `friendCount`
   - Decrement recipient's `pendingRequestsCount`
4. **Optional**: Delete request documents
5. **Send notification** to sender

### Rejecting a Friend Request

1. **Update request status** to "rejected"
2. **Decrement** recipient's `pendingRequestsCount`
3. **Optional**: Delete request document after 24 hours
4. **Optional**: Send notification to sender

### Removing a Friend

1. **Delete friend documents** from both users' `friends` subcollections
2. **Update counters**: Decrement both users' `friendCount`
3. **Optional**: Send notification

---

## Friend Features

### Friend Leaderboard
- Query user's `friends` subcollection
- Sort by `currentSteps` or `kadamScore`
- Display top friends for the day/week

### Friend Activity
- Show friends' recent achievements
- Display friends' current step counts
- Compare progress with friends

### Privacy Controls
- Users can disable friend requests
- Control what friends can see:
  - Step count
  - Profile details
  - Activity history
- Block users to prevent friend requests

---

## Notes

- All timestamps use Firebase `Timestamp` type
- Dates are stored as strings in `YYYY-MM-DD` format for consistency
- Distance is always in meters (convert to km/miles in UI)
- Calories are in kilocalories (kcal)
- Health data supports multiple sources with conflict resolution (highest value wins)
