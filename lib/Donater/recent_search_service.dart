import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchesService {
  static const String _key = 'recent_searches';
  static const int _maxSearches = 10;

  static final RecentSearchesService _instance = RecentSearchesService._internal();
  factory RecentSearchesService() => _instance;
  RecentSearchesService._internal();

  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? searchesJson = prefs.getString(_key);
      
      if (searchesJson != null) {
        final List<dynamic> searchesList = jsonDecode(searchesJson);
        return searchesList.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error loading recent searches: $e');
      return [];
    }
  }

  Future<bool> addSearch(String searchTerm) async {
    try {
      if (searchTerm.trim().isEmpty) return false;

      final searches = await getRecentSearches();
      
      searches.remove(searchTerm);
      searches.insert(0, searchTerm);
      
      if (searches.length > _maxSearches) {
        searches.removeRange(_maxSearches, searches.length);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(searches));
      return true;
    } catch (e) {
      print('Error adding search: $e');
      return false;
    }
  }

  Future<bool> removeSearch(String searchTerm) async {
    try {
      final searches = await getRecentSearches();
      searches.remove(searchTerm);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(searches));
      return true;
    } catch (e) {
      print('Error removing search: $e');
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      return true;
    } catch (e) {
      print('Error clearing searches: $e');
      return false;
    }
  }
}