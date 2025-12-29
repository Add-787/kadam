import 'dart:io';
import 'dart:math';

import 'package:flutter/src/services/platform_channel.dart';

import 'health_channel.dart';
import '../models/health_data.dart';
import '../models/platform_capability.dart';

/// Mock implementation of HealthChannel for testing and development
///
/// This class simulates health data without requiring actual device sensors
/// or health platform APIs. Useful for:
/// - Testing UI without physical device
/// - Development on emulators
/// - Unit testing
/// - Demo purposes
class MockHealthChannel implements HealthChannel {
  final Random _random = Random();
  bool _isAvailable = true;
  bool _hasPermissions = false;

  // Simulated step counts
  int _todaySteps = 0;
  final Map<DateTime, int> _dailySteps = {};

  MockHealthChannel() {
    _initializeMockData();
  }

  /// Initialize mock data with realistic values
  void _initializeMockData() {
    // Generate today's steps (between 2000 and 15000)
    _todaySteps = 2000 + _random.nextInt(13000);

    // Generate past 30 days of step data
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      _dailySteps[dateKey] = 1000 + _random.nextInt(14000);
    }

    // Set today's steps
    final today = DateTime(now.year, now.month, now.day);
    _dailySteps[today] = _todaySteps;
  }

  @override
  Future<bool> isAvailable() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _isAvailable;
  }

  @override
  Future<bool> hasPermissions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _hasPermissions;
  }

  @override
  Future<bool> requestPermissions({List<String>? dataTypes}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate 80% success rate
    _hasPermissions = _random.nextDouble() > 0.2;
    return _hasPermissions;
  }

  @override
  Future<List<HealthData>> querySteps({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (!_hasPermissions) {
      throw Exception('Permissions not granted');
    }

    final List<HealthData> records = [];

    // Generate hourly step records for the date range
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    while (current.isBefore(end)) {
      final dayKey = DateTime(current.year, current.month, current.day);
      final dailyTotal = _dailySteps[dayKey] ?? (1000 + _random.nextInt(14000));

      // Create 24 hourly records for this day
      for (int hour = 0; hour < 24; hour++) {
        final hourStart =
            DateTime(current.year, current.month, current.day, hour);
        final hourEnd = hourStart.add(const Duration(hours: 1));

        if (hourStart.isAfter(end)) break;

        // Distribute daily steps across hours (more steps during day hours)
        final hourSteps = _calculateHourlySteps(hour, dailyTotal);

        if (hourSteps > 0) {
          records.add(HealthData(
            id: 'mock_steps_${hourStart.millisecondsSinceEpoch}',
            source: HealthPlatform.mock,
            dataType: 'steps',
            value: hourSteps.toDouble(),
            unit: 'count',
            startTime: hourStart,
            endTime: hourEnd,
            metadata: {
              'sourceApp': _getMockSourceApp(),
              'deviceModel': 'Mock Device',
            },
          ));
        }
      }

      current = current.add(const Duration(days: 1));
    }

    return records;
  }

  @override
  Future<List<HealthData>> queryDistance({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (!_hasPermissions) {
      throw Exception('Permissions not granted');
    }

    final List<HealthData> records = [];

    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    while (current.isBefore(end)) {
      // Generate distance based on steps (roughly 0.0008 km per step)
      final dayKey = DateTime(current.year, current.month, current.day);
      final dailySteps = _dailySteps[dayKey] ?? 5000;
      final dailyDistance = (dailySteps * 0.0008 * 1000).toInt(); // in meters

      final dayStart = DateTime(current.year, current.month, current.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      if (dailyDistance > 0) {
        records.add(HealthData(
          id: 'mock_distance_${dayStart.millisecondsSinceEpoch}',
          source: HealthPlatform.mock,
          dataType: 'distance',
          value: dailyDistance.toDouble(),
          unit: 'meters',
          startTime: dayStart,
          endTime: dayEnd,
          metadata: {
            'sourceApp': _getMockSourceApp(),
            'deviceModel': 'Mock Device',
          },
        ));
      }

      current = current.add(const Duration(days: 1));
    }

    return records;
  }

  @override
  Future<List<HealthData>> queryCalories({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (!_hasPermissions) {
      throw Exception('Permissions not granted');
    }

    final List<HealthData> records = [];

    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    while (current.isBefore(end)) {
      // Generate calories based on steps (roughly 0.04 calories per step)
      final dayKey = DateTime(current.year, current.month, current.day);
      final dailySteps = _dailySteps[dayKey] ?? 5000;
      final dailyCalories = (dailySteps * 0.04).toInt();

      final dayStart = DateTime(current.year, current.month, current.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      if (dailyCalories > 0) {
        records.add(HealthData(
          id: 'mock_calories_${dayStart.millisecondsSinceEpoch}',
          source: HealthPlatform.mock,
          dataType: 'calories',
          value: dailyCalories.toDouble(),
          unit: 'kcal',
          startTime: dayStart,
          endTime: dayEnd,
          metadata: {
            'sourceApp': _getMockSourceApp(),
            'deviceModel': 'Mock Device',
          },
        ));
      }

      current = current.add(const Duration(days: 1));
    }

    return records;
  }

  @override
  Future<int> getTodaySteps() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_hasPermissions) {
      throw Exception('Permissions not granted');
    }

    return _todaySteps;
  }

  @override
  Future<int> getDailySteps(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_hasPermissions) {
      throw Exception('Permissions not granted');
    }

    final dateKey = DateTime(date.year, date.month, date.day);
    return _dailySteps[dateKey] ?? 0;
  }

  @override
  Future<PlatformCapability> getCapabilities() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return PlatformCapability(
      platform: HealthPlatform.mock,
      isAvailable: _isAvailable,
      isAuthorized: _hasPermissions,
      version: '1.0.0-mock',
      supportedDataTypes: ['steps', 'distance', 'calories', 'heart_rate'],
    );
  }

  @override
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _hasPermissions = false;
  }

  /// Calculate hourly steps distribution (more during waking hours)
  int _calculateHourlySteps(int hour, int dailyTotal) {
    // Distribution pattern: less at night, more during day
    final double factor;
    if (hour >= 0 && hour < 6) {
      factor = 0.01; // Night: 1%
    } else if (hour >= 6 && hour < 8) {
      factor = 0.05; // Morning: 5%
    } else if (hour >= 8 && hour < 12) {
      factor = 0.10; // Late morning: 10%
    } else if (hour >= 12 && hour < 14) {
      factor = 0.08; // Lunch: 8%
    } else if (hour >= 14 && hour < 18) {
      factor = 0.12; // Afternoon: 12%
    } else if (hour >= 18 && hour < 21) {
      factor = 0.08; // Evening: 8%
    } else {
      factor = 0.03; // Late night: 3%
    }

    return (dailyTotal * factor).toInt();
  }

  /// Get random mock source app
  String _getMockSourceApp() {
    final apps = [
      'Mock Health',
      'Test Fitness',
      'Demo Tracker',
      'Sample Health',
    ];
    return apps[_random.nextInt(apps.length)];
  }

  // Mock-specific methods for testing

  /// Set whether the mock channel is available
  void setAvailable(bool available) {
    _isAvailable = available;
  }

  /// Set whether permissions are granted
  void setPermissions(bool granted) {
    _hasPermissions = granted;
  }

  /// Set today's step count
  void setTodaySteps(int steps) {
    _todaySteps = steps;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _dailySteps[today] = steps;
  }

  /// Set step count for a specific date
  void setDailySteps(DateTime date, int steps) {
    final dateKey = DateTime(date.year, date.month, date.day);
    _dailySteps[dateKey] = steps;
  }

  /// Reset all mock data
  void reset() {
    _isAvailable = true;
    _hasPermissions = false;
    _dailySteps.clear();
    _initializeMockData();
  }

  /// Simulate increasing steps (for live testing)
  void simulateWalking({int stepsPerSecond = 2}) {
    _todaySteps += stepsPerSecond;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _dailySteps[today] = _todaySteps;
  }

  @override
  MethodChannel get channel => MethodChannel('mock_health_channel');

  @override
  HealthPlatform get platform => HealthPlatform.mock;

  @override
  Future<List<HealthData>> queryHeartRate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (!_hasPermissions) {
      throw Exception('Permissions not granted');
    }
    
    final List<HealthData> records = [];
    
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    
    while (current.isBefore(end)) {
      // Generate heart rate samples (5-minute intervals during waking hours)
      for (int hour = 6; hour < 23; hour++) {
        for (int minute = 0; minute < 60; minute += 5) {
          final sampleTime = DateTime(
            current.year,
            current.month,
            current.day,
            hour,
            minute,
          );
          
          if (sampleTime.isAfter(end)) break;
          
          // Generate realistic heart rate (60-100 bpm at rest, higher during activity)
          final baseHeartRate = 65 + _random.nextInt(20);
          final activityBonus = _random.nextInt(30);
          final heartRate = baseHeartRate + activityBonus;
          
          records.add(HealthData(
            id: 'mock_hr_${sampleTime.millisecondsSinceEpoch}',
            source: HealthPlatform.mock,
            dataType: 'heart_rate',
            value: heartRate.toDouble(),
            unit: 'bpm',
            startTime: sampleTime,
            endTime: sampleTime,
            metadata: {
              'sourceApp': _getMockSourceApp(),
              'deviceModel': 'Mock Device',
            },
          ));
        }
      }
      
      current = current.add(const Duration(days: 1));
    }
    
    return records;
  }

  @override
  Future<Map<String, List<HealthData>>> queryMultiple({
    required List<String> dataTypes,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (!_hasPermissions) {
      throw Exception('Permissions not granted');
    }
    
    final Map<String, List<HealthData>> results = {};
    
    for (final dataType in dataTypes) {
      switch (dataType.toLowerCase()) {
        case 'steps':
          results['steps'] = await querySteps(
            startDate: startDate,
            endDate: endDate,
          );
          break;
        case 'distance':
          results['distance'] = await queryDistance(
            startDate: startDate,
            endDate: endDate,
          );
          break;
        case 'calories':
          results['calories'] = await queryCalories(
            startDate: startDate,
            endDate: endDate,
          );
          break;
        case 'heart_rate':
          results['heart_rate'] = await queryHeartRate(
            startDate: startDate,
            endDate: endDate,
          );
          break;
        default:
          results[dataType] = [];
      }
    }
    
    return results;
  }

  @override
  Stream<HealthData>? subscribeToUpdates({
    required List<String> dataTypes,
  }) {
    if (!_hasPermissions) {
      return null;
    }
    
    // Return a stream that emits mock health data every 10 seconds
    return Stream.periodic(const Duration(seconds: 10), (count) {
      final dataType = dataTypes[count % dataTypes.length];
      final now = DateTime.now();
      
      switch (dataType.toLowerCase()) {
        case 'steps':
          simulateWalking(stepsPerSecond: 5);
          return HealthData(
            id: 'mock_steps_update_$count',
            source: HealthPlatform.mock,
            dataType: 'steps',
            value: 5.0,
            unit: 'count',
            startTime: now,
            endTime: now,
            metadata: {
              'sourceApp': _getMockSourceApp(),
              'deviceModel': 'Mock Device',
              'isRealtime': true,
            },
          );
        case 'heart_rate':
          final heartRate = 65 + _random.nextInt(35);
          return HealthData(
            id: 'mock_hr_update_$count',
            source: HealthPlatform.mock,
            dataType: 'heart_rate',
            value: heartRate.toDouble(),
            unit: 'bpm',
            startTime: now,
            endTime: now,
            metadata: {
              'sourceApp': _getMockSourceApp(),
              'deviceModel': 'Mock Device',
              'isRealtime': true,
            },
          );
        default:
          return HealthData(
            id: 'mock_update_$count',
            source: HealthPlatform.mock,
            dataType: dataType,
            value: _random.nextDouble() * 100,
            unit: 'unknown',
            startTime: now,
            endTime: now,
            metadata: {
              'sourceApp': _getMockSourceApp(),
              'deviceModel': 'Mock Device',
              'isRealtime': true,
            },
          );
      }
    });
  }
}
