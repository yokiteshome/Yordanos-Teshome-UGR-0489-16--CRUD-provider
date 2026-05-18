import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  List<Cart> _carts = [];
  bool _isLoading = false;
  String? _error;

  List<Cart> get carts => _carts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCarts() async {
    _setLoading(true);
    _error = null;
    try {
      _carts = await _cartService.fetchCarts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCart(int userId, List<Map<String, dynamic>> products) async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      final newCart = await _cartService.addCart(userId, products);
      _carts.insert(0, newCart);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCart(
    int cartId,
    List<Map<String, dynamic>> products,
  ) async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      await _cartService.updateCart(cartId, products);
      // Reload carts to ensure data is synced with API
      _carts = await _cartService.fetchCarts();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCart(int cartId) async {
    _setLoading(true);
    _error = null;
    notifyListeners();
    try {
      await _cartService.deleteCart(cartId);
      // Remove items with this cartId from local list
      _carts.removeWhere((c) => c.cartId == cartId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
