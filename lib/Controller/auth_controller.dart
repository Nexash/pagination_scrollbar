import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pagination/Modal/product_modal.dart';
import 'package:pagination/Service/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  String? errorMessage;
  int skip = 0;
  int limit = 10;
  bool hasMore = true;
  Timer? _debounce;
  String oldvalue = "";

  bool isLoading = false;

  bool isLoadingsearch = false;
  AuthController(this._authService) {
    getProductData();
  }
  Future<void> refreshProducts() async {
    productDetails.clear();
    hasMore = true;
    skip = 0;
    limit = 10;
    await getProductData();
  }

  Future<void> refreshSearchedProducts(String value) async {
    suggestions.clear();
    hasMore = true;
    skip = 0;
    limit = 10;
    await onSearchChanged(value);
  }

  List<ProductModal> productDetails = [];
  List<ProductModal> suggestions = [];

  Future<bool> getProductData() async {
    log("get products called");
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _authService.productDetails(limit, skip);

      final List rawList = response['products'];
      final int totalProducts = response['total'];
      await Future.delayed(const Duration(seconds: 1));
      final newItems =
          rawList.map((item) {
            return ProductModal.fromJson(item as Map<String, dynamic>);
          }).toList();
      productDetails.addAll(newItems);
      if (productDetails.length >= totalProducts) {
        hasMore = false;
      }
      log(hasMore.toString());
      log("MAin");
      log(productDetails.length.toString());
      skip += newItems.length;

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> onSearchChanged(String query) async {
    log("on search change called");

    if (query.isEmpty) {
      suggestions = [];
      isLoadingsearch = false;
      notifyListeners();
      return;
    }
    if (query != oldvalue) {
      suggestions = [];
      skip = 0;
      hasMore = true;
    }
    oldvalue = query;
    isLoadingsearch = true;
    notifyListeners();

    try {
      final response = await _authService.productSearch(limit, skip, query);
      final List rawList = response['products'];
      final int totalProducts = response['total'];
      await Future.delayed(const Duration(seconds: 1));
      final newItems =
          rawList.map((item) {
            return ProductModal.fromJson(item as Map<String, dynamic>);
          }).toList();
      suggestions.addAll(newItems);
      if (suggestions.length >= totalProducts) {
        hasMore = false;
      }
      log(hasMore.toString());
      log("search");
      log(productDetails.length.toString());
      skip += newItems.length;

      isLoadingsearch = false;
      notifyListeners();
    } catch (e) {
      isLoadingsearch = false;
      notifyListeners();
      print("Error fetching data: $e");
    }
    return;
  }
}
