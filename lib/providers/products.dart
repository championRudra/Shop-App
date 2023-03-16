// ignore_for_file: prefer_final_fields, prefer_const_constructors
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  late String? authToken;
  late String? userId;

  Products(this.authToken, this.userId, this._items);

  void updateUser(String? token, String? id) {
    userId = id;
    authToken = token;
    notifyListeners();
  }
  // var _showFavouriteOnly = false;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favorite {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  // To fetch the data
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var params = filterByUser
        ? {
            'auth': authToken,
            'orderBy': '"creatorId"',
            'equalTo': '"$userId"',
          }
        : {
            'auth': authToken,
          };
    var url = Uri.https(
      'shopappudemy-b0658-default-rtdb.firebaseio.com',
      '/products.json',
      params,
    );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData.isEmpty) {
        return;
      }
      url = Uri.https(
        'shopappudemy-b0658-default-rtdb.firebaseio.com',
        '/userFavourites/$userId.json',
        {'auth': authToken},
      );
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProduct = [];
      extractedData.forEach(
        (prodId, prodData) {
          loadedProduct.add(
            Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite: favouriteData == null
                  ? false
                  : favouriteData[prodId] ?? false,
            ),
          );
        },
      );
      _items = loadedProduct;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
      'shopappudemy-b0658-default-rtdb.firebaseio.com',
      '/products.json',
      {
        'auth': authToken,
      },
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        description: product.description,
        id: json.decode(response.body)['name'],
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProd) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
        'shopappudemy-b0658-default-rtdb.firebaseio.com',
        '/products/$id.json',
        {'auth': '$authToken'},
      );
      await http.patch(url,
          body: json.encode({
            'title': newProd.title,
            'description': newProd.description,
            'price': newProd.price,
            'imageUrl': newProd.imageUrl,
          }));
      _items[prodIndex] = newProd;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(
      'shopappudemy-b0658-default-rtdb.firebaseio.com',
      '/products/$id.json',
      {'auth': '$authToken'},
    );
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
