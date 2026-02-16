import 'package:flutter/material.dart';
import 'package:woocommerce_flutter_api/woocommerce_flutter_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  //-----------------------------------------------
  // Fetch products from WooCommerce
  Future<void> fetchProducts() async {
    // FIX: Schedule the state change for the next microtask 
    // to avoid "setState() called during build" errors.
    Future.microtask(() {
      isLoading = true;
      notifyListeners();
    });

    try {
      _products = await woocommerce.getProducts();
    } catch (e) {
      debugPrint("WooCommerce Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //-----------------------------------------------
  // Create a new order in WooCommerce
  /// Create an order in WooCommerce and return a payment/redirect URL (if available).
  ///
  /// The method will POST `orderData` to the WooCommerce REST API `/wp-json/wc/v3/orders`.
  /// It returns a `String?` which is the payment/redirect URL provided by the gateway (e.g. Payfast),
  /// or `null` if none is returned by the server.
  Future<String?> createOrder(Map<String, dynamic> orderData) async {
    isLoading = true;
    notifyListeners();

    try {
      // Build the authenticated URL using consumer key/secret as query params
      final uri = Uri.parse('${woocommerce.baseUrl}wp-json/wc/v3/orders')
          .replace(queryParameters: {
        'consumer_key': woocommerce.username,
        'consumer_secret': woocommerce.password,
      });

      final body = jsonEncode(orderData);

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('WooCommerce create order failed: ${resp.statusCode} ${resp.body}');
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(resp.body) as Map<String, dynamic>;

      // Common places that gateways/plugins expose a payment/redirect URL:
      // - data['payment_url']
      // - data['meta_data'] entries
      // - data['redirect'] or data['meta']['redirect']
      String? paymentUrl;
      if (data.containsKey('payment_url')) paymentUrl = data['payment_url']?.toString();

      if (paymentUrl == null && data.containsKey('meta_data')) {
        try {
          final meta = data['meta_data'] as List<dynamic>;
          for (final m in meta) {
            try {
              final map = m as Map<String, dynamic>;
              final key = (map['key'] ?? '').toString().toLowerCase();
              final value = map['value']?.toString();
              if (key.contains('payment') || key.contains('redirect') || key.contains('payfast')) {
                paymentUrl = value;
                break;
              }
            } catch (_) {}
          }
        } catch (_) {}
      }

      if (paymentUrl == null) {
        // Some gateways attach data to the response under different keys
        if (data.containsKey('redirect')) paymentUrl = data['redirect']?.toString();
        if (paymentUrl == null && data.containsKey('meta')) {
          try {
            final meta = data['meta'] as Map<String, dynamic>;
            if (meta.containsKey('redirect')) paymentUrl = meta['redirect']?.toString();
          } catch (_) {}
        }
      }

      return paymentUrl;
    } catch (e) {
      debugPrint('createOrder exception: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}