import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/General/Providers/woocommerce_store_provider.dart';

class CartPopup extends StatefulWidget {
  const CartPopup({super.key});

  @override
  State<CartPopup> createState() => _CartPopupState();
}

class _CartPopupState extends State<CartPopup> {
  List<Map<String, dynamic>> _cartItems = [];
  bool _loading = true;
  double _total = 0.0;
  bool _processingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('cartItems') ?? [];

    final woocommerceStore = Provider.of<WoocommerceStore>(context, listen: false);
    final products = woocommerceStore.products;

    final items = <Map<String, dynamic>>[];
    double total = 0.0;
    for (final s in stored) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        final id = m['id'].toString();
        final qty = (m['quantity'] is int) ? m['quantity'] as int : int.tryParse(m['quantity'].toString()) ?? 1;

        String title = id;
        try {
          final found = products.firstWhere((p) {
            try {
              final pid = (p.id ?? p.toJson()['id']).toString();
              return pid == id;
            } catch (_) {
              try {
                return p.toJson()['id'].toString() == id;
              } catch (_) {
                return false;
              }
            }
          });
          title = (found.name ?? found.toJson()['name'] ?? id).toString();

          // Try to extract an image URL from the product object
          String image = '';
          try {
            final imgs = found.images;
            if (imgs.isNotEmpty) {
              image = (imgs[0].src ?? '').toString();
            }
          } catch (_) {
            try {
              final imgsJson = (found.toJson()['images'] as List<dynamic>?) ?? [];
              if (imgsJson.isNotEmpty) image = (imgsJson[0]['src'] ?? '').toString();
            } catch (_) {}
          }

          // Try to extract price
          double price = 0.0;
          try {
            final pval = found.price;
            if (pval != null) price = double.tryParse(pval.toString()) ?? 0.0;
          } catch (_) {
            try {
              final pj = found.toJson()['price'];
              price = double.tryParse(pj.toString()) ?? 0.0;
            } catch (_) {}
          }

          total += price * qty;

          items.add({'id': id, 'quantity': qty, 'title': title, 'image': image, 'price': price});
        } catch (_) {
          // product not found in current list — fallback to id
          items.add({'id': id, 'quantity': qty, 'title': title, 'image': '', 'price': 0.0});
        }
      } catch (_) {
        // fallback for legacy plain-id entries
        items.add({'id': s, 'quantity': 1, 'title': s, 'image': '', 'price': 0.0});
      }
    }

    setState(() {
      _cartItems = items;
      _loading = false;
      _total = total;
    });
  }

  Future<void> _removeItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('cartItems') ?? [];
    list.removeWhere((s) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return m['id'].toString() == id;
      } catch (_) {
        return s == id;
      }
    });
    await prefs.setStringList('cartItems', list);
    await _loadCart();
  }

  Future<void> _clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cartItems');
    await _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;

    return AlertDialog(
      backgroundColor: localAppTheme['anchorColors']['secondaryColor'],
      title: header1(header: 'Shopping Cart:', color: localAppTheme['anchorColors']['primaryColor'], context: context),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setStateDialog) {
              return Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_cartItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: body(header: 'Your cart is empty', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                      )
                    else
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _cartItems.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            final img = (item['image'] ?? '').toString();
                            return ListTile(
                              leading: img.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        img,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 56,
                                          height: 56,
                                          color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.1),
                                          alignment: Alignment.center,
                                          child: Icon(Icons.fitness_center, color: localAppTheme['anchorColors']['primaryColor']),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.shopping_bag, color: localAppTheme['anchorColors']['primaryColor']),
                                    ),
                              title: body(header: item['title'] ?? item['id'], color: localAppTheme['anchorColors']['primaryColor'], context: context),
                              subtitle: body(header: 'Quantity: ${item['quantity']}', color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.8), context: context),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: localAppTheme['anchorColors']['primaryColor']),
                                onPressed: () async {
                                  await _removeItem(item['id'].toString());
                                },
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 12.0),

                    Row(
                      children: [
                        Expanded(
                          child: elevatedButton(
                            label: 'CLEAR CART',
                            onPressed: _cartItems.isEmpty ? null : () async => await _clearCart(),
                            backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                            labelColor: localAppTheme['anchorColors']['secondaryColor'],
                            leadingIcon: null,
                            trailingIcon: null,
                            context: context,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: elevatedButton(
                            label: 'CANCEL',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                            labelColor: localAppTheme['anchorColors']['secondaryColor'],
                            leadingIcon: null,
                            trailingIcon: null,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),

                    // Total and Payment
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              body(header: 'Total', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                              Text('R ${_total.toStringAsFixed(2)}', style: TextStyle(color: localAppTheme['anchorColors']['primaryColor'], fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          elevatedButton(
                            label: _processingPayment ? 'PROCESSING...' : 'PROCESS PAYMENT',
                            onPressed: _cartItems.isEmpty || _processingPayment
                                ? null
                                : () async {
                                    setState(() => _processingPayment = true);
                                    await Future.delayed(const Duration(seconds: 1));
                                    setState(() => _processingPayment = false);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment processing (placeholder)')));
                                  },
                            backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                            labelColor: localAppTheme['anchorColors']['secondaryColor'],
                            leadingIcon: null,
                            trailingIcon: null,
                            context: context,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
