import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart.dart';

class CartService {
  static const String _baseUrl = 'https://dummyjson.com/carts';

  Future<List<Cart>> fetchCarts() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> cartsJson = data['carts'];
      List<Cart> allProducts = [];
      for (var cartJson in cartsJson) {
        final int cartId = cartJson['id'];
        final List<dynamic> productsJson = cartJson['products'];
        allProducts.addAll(
          productsJson.map((json) => Cart.fromJson(json, cartId)).toList(),
        );
      }
      return allProducts;
    } else {
      throw Exception('Failed to load carts');
    }
  }

  Future<Cart> addCart(int userId, List<Map<String, dynamic>> products) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId, 'products': products}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Cart.fromJson(data['products'][0], data['id']);
    } else {
      throw Exception('Failed to add cart');
    }
  }

  Future<Cart> updateCart(
    int cartId,
    List<Map<String, dynamic>> products,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$cartId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'merge': true, 'products': products}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Cart.fromJson(data['products'][0], data['id']);
    } else {
      throw Exception('Failed to update cart');
    }
  }

  Future<void> deleteCart(int cartId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$cartId'));
    // Accept multiple success status codes
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete cart');
    }
  }
}
