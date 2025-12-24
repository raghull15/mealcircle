import 'package:flutter/material.dart';

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final Set<String> _selectedItemIds = {};
  final List<Map<String, dynamic>> _allItems = [];

  int get cartCount => _selectedItemIds.length;

  List<Map<String, dynamic>> get cartItems {
    return _allItems.where((item) {
      final id = '${item["name"]}_${item["location"] ?? item["distance"]}';
      return _selectedItemIds.contains(id);
    }).toList();
  }

  void registerItem(Map<String, dynamic> item) {
    final id = '${item["name"]}_${item["location"] ?? item["distance"]}';
    if (!_allItems.any((i) => '${i["name"]}_${i["location"] ?? i["distance"]}' == id)) {
      _allItems.add(item);
    }
  }

  bool isSelected(Map<String, dynamic> item) {
    final id = '${item["name"]}_${item["location"] ?? item["distance"]}';
    return _selectedItemIds.contains(id);
  }

  void toggleSelection(Map<String, dynamic> item) {
    final id = '${item["name"]}_${item["location"] ?? item["distance"]}';
    if (_selectedItemIds.contains(id)) {
      _selectedItemIds.remove(id);
      item["selected"] = false;
    } else {
      _selectedItemIds.add(id);
      item["selected"] = true;
    }
    notifyListeners();
  }

  void removeItem(Map<String, dynamic> removedItem) {
    final id = '${removedItem["name"]}_${removedItem["location"] ?? removedItem["distance"]}';
    if (_selectedItemIds.contains(id)) {
      _selectedItemIds.remove(id);
      removedItem["selected"] = false;
      notifyListeners();
    }
  }

  void clearCart() {
    _selectedItemIds.clear();
    for (var item in _allItems) {
      item["selected"] = false;
    }
    notifyListeners();
    _allItems.clear();
  }
}