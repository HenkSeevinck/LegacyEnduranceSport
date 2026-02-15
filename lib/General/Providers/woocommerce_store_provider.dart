import 'package:flutter/material.dart';
import 'package:woocommerce_flutter_api/woocommerce_flutter_api.dart';

class WoocommerceStore with ChangeNotifier {

  List<WooProduct> _products = [];
  List<WooProduct> get products => _products;

  // Use the definition exactly as the package requires
  
  final woocommerce = WooCommerce(
    baseUrl: 'https://www.legacyendurancesport.com/',
    username: 'ck_82c310187772f4cb240c6726b4fd2c9bc529c558', // Put your Consumer Key here
    password: 'cs_b51b39d70a51aed109dacfbcc57e237565d06a79', // Put your Consumer Secret here
    isDebug: false,               // Keep true while developing to see errors in console
    useFaker: false,             // Set to true if you want to see test products immediately
  );

  bool isLoading = false;

  // Function to fetch your real products
  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      _products = await woocommerce.getProducts();
    } catch (e) {
      debugPrint("WooCommerce Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}