// lib/services/cart_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_library/models/cart_model.dart';

class CartService extends ChangeNotifier {
  static const _kCartKey = 'cart_items_v1';
  final List<CartItem> _items = [];

  CartService() {
    _loadFromPrefs();
  }

  List<CartItem> get items => List.unmodifiable(_items);

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kCartKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List decoded = json.decode(jsonStr);
        _items.clear();
        _items.addAll(decoded
            .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e))));
        notifyListeners();
      } catch (e) {
        // ignore parse errors, start with empty cart
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_items.map((i) => i.toMap()).toList());
    await prefs.setString(_kCartKey, encoded);
  }

  void addItem(CartItem item) {
    // find existing by product + options
    final idx = _items.indexWhere((i) =>
        i.productId == item.productId &&
        i.selectedColorIndex == item.selectedColorIndex &&
        i.selectedSizeIndex == item.selectedSizeIndex);

    if (idx != -1) {
      // merge quantities
      _items[idx].qty += item.qty;
    } else {
      _items.add(item);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void increaseQty(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].qty++;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void decreaseQty(int index) {
    if (index >= 0 && index < _items.length) {
      if (_items[index].qty > 1) {
        _items[index].qty--;
      } else {
        _items.removeAt(index);
      }
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removeAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _saveToPrefs();
    notifyListeners();
  }

  double get subtotal {
    return _items.fold(
        0.0, (sum, item) => sum + (item.discountedPrice * item.qty));
  }

  double get vat => subtotal * 0.05; // keep same 5% VAT example
  double get total => subtotal + vat;
}
