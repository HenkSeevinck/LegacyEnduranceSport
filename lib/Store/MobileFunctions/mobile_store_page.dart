import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/woocommerce_store_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:provider/provider.dart';
import 'package:woocommerce_flutter_api/woocommerce_flutter_api.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MobileStorePage extends StatefulWidget {
  const MobileStorePage({super.key});

  @override
  State<MobileStorePage> createState() => _MobileStorePageState();
}

class _MobileStorePageState extends State<MobileStorePage> {
  Future<void>? _fetchDataFuture;
  Map<String, dynamic> productToView = {};
  int _selectedQuantity = 1;

  //----------------------------------------------------
  // initState load data when form is built
  @override
  void initState() {
    super.initState();
    final woocommerceStore = Provider.of<WoocommerceStore>(context, listen: false);
    _fetchDataFuture = _fetchData(woocommerceStore);
  }

  //----------------------------------------------------
  // Fetch data function
  Future<void> _fetchData(WoocommerceStore woocommerceStore) async {
    await woocommerceStore.fetchProducts();
  }

  //----------------------------------------------------
  // Store item in Cart local storage
  Future<void> _addToCart(Map<String, dynamic> product, {int quantity = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList('cartItems') ?? [];

    final itemId = product['id'].toString();
    final newItem = {'id': itemId, 'quantity': quantity};

    // Try to merge with existing item if present
    bool merged = false;
    for (var i = 0; i < cartItems.length; i++) {
      try {
        final existing = jsonDecode(cartItems[i]) as Map<String, dynamic>;
        if (existing['id'].toString() == itemId) {
          final existingQty = (existing['quantity'] is int) ? existing['quantity'] as int : int.tryParse(existing['quantity'].toString()) ?? 0;
          existing['quantity'] = existingQty + quantity;
          cartItems[i] = jsonEncode(existing);
          merged = true;
          break;
        }
      } catch (_) {
        // If an existing entry isn't JSON, skip it
        continue;
      }
    }

    if (!merged) {
      cartItems.add(jsonEncode(newItem));
    }

    await prefs.setStringList('cartItems', cartItems);
  }

  //----------------------------------------------------
  // Product Detail Widget
  Widget _buildProductDetail() {
    final localAppTheme = ResponsiveTheme(context).theme;

    String stripHtml(String html) {
      // Remove tags first
      final withoutTags = html.replaceAll(RegExp(r'<[^>]*>'), '');

      // Decode common HTML entities (nbsp/amp) and numeric/hex character references
      String decoded = withoutTags.replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&');

      // Hex references: &#xHHHH;
      decoded = decoded.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (Match m) {
        final hex = m.group(1)!;
        return String.fromCharCode(int.parse(hex, radix: 16));
      });

      // Decimal references: &#(\d+);
      decoded = decoded.replaceAllMapped(RegExp(r'&#(\d+);'), (Match m) {
        final dec = m.group(1)!;
        return String.fromCharCode(int.parse(dec));
      });

      // Ensure a space between a leading currency symbol/letter and the number
      // e.g. 'R6630,00' -> 'R 6630,00'
      decoded = decoded.replaceAllMapped(RegExp(r'^([^\s\d])(?=\d)'), (Match m) => '${m.group(1)} ');

      return decoded.trim();
    }

    final name = (productToView['name'] ?? 'Product').toString();
    final priceHtml = (productToView['price_html'] ?? '').toString();
    final priceString = priceHtml.isNotEmpty
        ? stripHtml(priceHtml)
        : (productToView['price'] != null ? 'R ${double.tryParse(productToView['price'].toString())?.toStringAsFixed(2) ?? productToView['price']}' : '—');
    final images = (productToView['images'] as List<dynamic>?) ?? [];
    final imageSrc = images.isNotEmpty ? (images[0]['src'] ?? '') : '';
    final shortDesc = stripHtml(productToView['short_description']?.toString() ?? '');
    final description = stripHtml(productToView['description']?.toString() ?? '');
    final categories = (productToView['categories'] as List<dynamic>?) ?? [];
    final tags = (productToView['tags'] as List<dynamic>?) ?? [];
    final stockQty = productToView['stock_quantity'] ?? 0;
    final stockStatus = (productToView['stock_status'] ?? 'instock').toString();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageSrc.isNotEmpty
                ? Image.network(imageSrc, height: 220, width: double.infinity, fit: BoxFit.contain)
                : Container(
                    height: 220,
                    color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.08),
                    alignment: Alignment.center,
                    child: const Icon(Icons.fitness_center, size: 56),
                  ),
          ),

          const SizedBox(height: 10),

          // Title + Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header2(header: name, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                const SizedBox(height: 10),
                header2(header: priceString, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                const SizedBox(height: 10),

                // Badges: categories + tags
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    for (final c in categories)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: localAppTheme['anchorColors']['primaryColor'], borderRadius: BorderRadius.circular(20)),
                        child: body(
                          header: (c['name'] ?? '').toString().toUpperCase(),
                          color: localAppTheme['anchorColors']['secondaryColor'],
                          context: context,
                        ),
                      ),
                    for (final t in tags)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: body(header: (t['name'] ?? '').toString().toUpperCase(), color: localAppTheme['anchorColors']['primaryColor'], context: context),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Short description
          if (shortDesc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(shortDesc, style: TextStyle(color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.9), fontSize: 14)),
            ),

          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: body(header: description, color: localAppTheme['anchorColors']['primaryColor'], context: context),
            ),

          const SizedBox(height: 16),

          // Stock and Quantity + Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header3(header: 'Availability', context: context, color: localAppTheme['anchorColors']['primaryColor']),
                      const SizedBox(height: 4),
                      body(
                        header: stockStatus == 'instock' ? 'In stock (${stockQty.toString()})' : stockStatus,
                        color: localAppTheme['anchorColors']['primaryColor'],
                        context: context,
                      ),
                    ],
                  ),
                ),

                // Quantity selector (simple)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: localAppTheme['anchorColors']['primaryColor']),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, color: localAppTheme['anchorColors']['primaryColor']),
                        onPressed: _selectedQuantity > 1 ? () => setState(() => _selectedQuantity = (_selectedQuantity - 1)) : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: body(header: '$_selectedQuantity', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: localAppTheme['anchorColors']['primaryColor']),
                        onPressed: () => setState(() => _selectedQuantity = (_selectedQuantity + 1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // CTA Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: elevatedButton(
                      label: 'ADD TO CART',
                      onPressed: () async {
                        await _addToCart(productToView, quantity: _selectedQuantity);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                      },
                      backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                      labelColor: localAppTheme['anchorColors']['secondaryColor'],
                      leadingIcon: null,
                      trailingIcon: null,
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  //----------------------------------------------------`
  // Product Tile Widget
  Widget _buildProductTile(WooProduct product) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final productName = (product.name != null && product.name!.trim().isNotEmpty) ? product.name! : 'Coaching Plan';
    final categoryLabel = product.categories.isNotEmpty ? (product.categories.first.name ?? '') : '';
    final imageSrc = (product.images.isNotEmpty ? product.images[0].src : null) ?? '';
    final priceValue = (product.price ?? 0).toDouble();
    final priceString = 'R ${priceValue.toStringAsFixed(2)}';

    return Semantics(
      label: '$productName${categoryLabel.isNotEmpty ? ', $categoryLabel' : ''}, $priceString',
      button: true,
      child: InkWell(
        onTap: () {
          setState(() {
            productToView = product.toJson();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Product Image with Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: imageSrc.isNotEmpty
                        ? Image.network(
                            imageSrc,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 180,
                              width: double.infinity,
                              color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.1),
                              child: const Icon(Icons.fitness_center),
                            ),
                          )
                        : Container(
                            height: 180,
                            width: double.infinity,
                            color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.1),
                            alignment: Alignment.center,
                            child: const Icon(Icons.fitness_center),
                          ),
                  ),
                  // Category Badge (e.g., "Ultra Running")
                  if (categoryLabel.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: localAppTheme['anchorColors']['primaryColor'], borderRadius: BorderRadius.circular(4)),
                        child: header3(header: categoryLabel.toUpperCase(), context: context, color: localAppTheme['anchorColors']['secondaryColor']),
                      ),
                    ),
                ],
              ),

              // 2. Product Details
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header2(header: productName, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                    const SizedBox(height: 10),
                    header2(header: priceString, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                    const SizedBox(height: 10),

                    // 3. CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: SizedBox(
                        height: 45,
                        child: elevatedButton(
                          label: 'VIEW DETAILS',
                          onPressed: () {
                            setState(() {
                              productToView = product.toJson();
                            });
                          },
                          backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                          labelColor: localAppTheme['anchorColors']['secondaryColor'],
                          leadingIcon: null,
                          trailingIcon: null,
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------
  // Build method with FutureBuilder
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        final localAppTheme = ResponsiveTheme(context).theme;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: body(header: 'Error: ${snapshot.error}', color: localAppTheme['anchorColors']['primaryColor'], context: context),
          );
        } else {
          final localAppTheme = ResponsiveTheme(context).theme;
          //final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
          //final appUser = appUserProvider.appUser;

          // Listen for changes so the UI rebuilds when products are fetched
          final woocommerceStore = Provider.of<WoocommerceStore>(context, listen: true);
          final products = woocommerceStore.products;

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: appheader(
                context: context,
                automaticallyImplyLeading: true,
                onPressed: () {
                  if (productToView.isNotEmpty) {
                    setState(() => productToView = {});
                  } else {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
                  }
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: localAppTheme['anchorColors']['primaryColor'], width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                // Switch between Loading and the Product Grid
                child: woocommerceStore.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                    ? const Center(child: Text("Products not found"))
                    : SingleChildScrollView(
                      child: Column(
                          children: [
                            shopPageHeaderImage(
                              imagePath: 'images/Shop.png',
                              context: context,
                              pageTitle: 'ONLINE STORE',
                            ),
                            SizedBox(height: 10),
                            productToView.isEmpty
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1, // Full width tiles look best for coaching plans
                                      childAspectRatio: 1.1,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      return _buildProductTile(products[index]);
                                    },
                                  )
                                : _buildProductDetail(),
                          ],
                        ),
                    ),
              ),
            ),
          );
        }
      },
    );
  }
}
