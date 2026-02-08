import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveJoinedDate(DateTime date);
  Future<DateTime?> getJoinedDate();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _joinedDateKey = 'joined_date';

  @override
  Future<void> saveJoinedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_joinedDateKey, date.toIso8601String());
  }

  @override
  Future<DateTime?> getJoinedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_joinedDateKey);
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }
}
