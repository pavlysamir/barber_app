import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences _prefs;

  static init() async {
    WidgetsFlutterBinding.ensureInitialized();

    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> set({required String key, required dynamic value}) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      throw UnsupportedError('Unsupported Type');
    }
  }

  static String? getString({required String key}) {
    return _prefs.getString(key);
  }

  static bool? getBool({required String key}) {
    return _prefs.getBool(key);
  }

  static int? getInt({required String key}) {
    return _prefs.getInt(key);
  }

  static double? getDouble({required String key}) {
    return _prefs.getDouble(key);
  }

  static List<String>? getStringList({required String key}) {
    return _prefs.getStringList(key);
  }

  static saveIntList({required String key, required List<int> numbers}) {
    final jsonString = jsonEncode(numbers);
    _prefs.setString(key, jsonString);
  }

  static List<int> getIntList({required String key}) {
    final jsonString = _prefs.getString(key);

    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as int).toList();
    }

    return []; // أو null حسب اللي يناسبك
  }

  static Future<bool> delete({required String key}) async {
    return await _prefs.remove(key);
  }

  static Future<bool> clearAllData() async {
    return await _prefs.clear();
  }
}
