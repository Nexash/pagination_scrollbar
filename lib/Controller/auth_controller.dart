import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pagination/Modal/product_modal.dart';
import 'package:pagination/Service/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  String? errorMessage;
  int skip = 0;
  int limit = 97;
  bool hasMore = true;

  bool isLoading = false;
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

  List<ProductModal> productDetails = [];

  Future<bool> getProductData() async {
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

  //  Future<bool> getProductData() async {
  //   isLoading = true;
  //   errorMessage = null;
  //   notifyListeners();
  //   try {
  //     //Get the full Map (the one starting with "products": [...])
  //     final response = await _authService.productDetails();

  //     //Dig into the Map to get the List hidden under the 'products' key
  //     // We cast it to List so we can use .map()
  //     final List rawList = response['products'];

  //     //Convert that raw list into your ProductModal list
  //     productDetails =
  //         rawList.map((item) {
  //           return ProductModal.fromJson(item as Map<String, dynamic>);
  //         }).toList();

  //     isLoading = false;
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     isLoading = false;
  //     errorMessage = e.toString();
  //     notifyListeners();
  //     return false;
  //   }
  // }
}
