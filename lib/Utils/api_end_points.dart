class ApiEndPoints {
  static const String baseUrl = "https://dummyjson.com/products";
  static const String productDetails = "https://dummyjson.com/products";
  static String productDetailsPartial(int limit, int skip) {
    return "$productDetails?limit=$limit&skip=$skip";
  }
}
