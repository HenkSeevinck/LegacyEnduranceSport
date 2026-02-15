import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Providers/woocommerce_store_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/Home/Page/homepage.dart';
import 'package:provider/provider.dart';
import 'package:woocommerce_flutter_api/woocommerce_flutter_api.dart';

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
  // Product Detail Widget
  Widget _buildProductDetail() {
    final localAppTheme = ResponsiveTheme(context).theme;

    String stripHtml(String html) {
      return html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();
    }

    final name = (productToView['name'] ?? 'Product').toString();
    final priceHtml = (productToView['price_html'] ?? '').toString();
    final priceString = priceHtml.isNotEmpty ? stripHtml(priceHtml) : (productToView['price'] != null ? 'R ${double.tryParse(productToView['price'].toString())?.toStringAsFixed(2) ?? productToView['price']}' : '—');
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
          // Image + Back button
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageSrc.isNotEmpty
                    ? Image.network(imageSrc, height: 220, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                        height: 220,
                        color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.08),
                        alignment: Alignment.center,
                        child: const Icon(Icons.fitness_center, size: 56),
                      ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => setState(() => productToView = {}),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title + Price
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header2(header: name, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                const SizedBox(height: 6),
                header2(header: priceString, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                const SizedBox(height: 10),

                // Badges: categories + tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final c in categories)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: localAppTheme['anchorColors']['primaryColor'], borderRadius: BorderRadius.circular(20)),
                        child: Text((c['name'] ?? '').toString().toUpperCase(), style: TextStyle(color: localAppTheme['anchorColors']['secondaryColor'], fontSize: 12)),
                    ),
                    for (final t in tags)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                        child: Text((t['name'] ?? '').toString(), style: TextStyle(color: localAppTheme['anchorColors']['primaryColor'], fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Short description
          if (shortDesc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(shortDesc, style: TextStyle(color: localAppTheme['anchorColors']['primaryColor'].withOpacity(0.9), fontSize: 14)),
            ),

          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Text(description, style: TextStyle(color: Colors.grey[800], fontSize: 14), maxLines: 8, overflow: TextOverflow.ellipsis),
            ),

          const SizedBox(height: 16),

          // Stock and Quantity + Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Availability', style: TextStyle(color: localAppTheme['anchorColors']['primaryColor'], fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(stockStatus == 'instock' ? 'In stock (${stockQty.toString()})' : stockStatus, style: TextStyle(color: Colors.green.shade700)),
                    ],
                  ),
                ),

                // Quantity selector (simple)
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _selectedQuantity > 1
                            ? () => setState(() => _selectedQuantity = (_selectedQuantity - 1))
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('$_selectedQuantity', style: const TextStyle(fontSize: 16)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _selectedQuantity = (_selectedQuantity + 1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // CTA Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: elevatedButton(
                      label: 'SUBSCRIBE',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscribed — proceed to checkout (placeholder)')));
                      },
                      backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                      labelColor: localAppTheme['anchorColors']['secondaryColor'],
                      leadingIcon: null,
                      trailingIcon: null,
                      context: context,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 56,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide(color: localAppTheme['anchorColors']['primaryColor'])),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $_selectedQuantity item(s) to cart')));
                    },
                    child: Icon(Icons.shopping_cart, color: localAppTheme['anchorColors']['primaryColor']),
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
                            fit: BoxFit.cover,
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
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header2(header: productName, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                    const SizedBox(height: 8),
                    header2(header: priceString, context: context, color: localAppTheme['anchorColors']['primaryColor']),
                    const SizedBox(height: 12),

                    // 3. CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: SizedBox(
                        height: 45,
                        child: elevatedButton(
                          label: 'VIEW PLAN',
                          onPressed: () {
                            setState(() {
                              productToView = product.toJson();
                            });
                            //print(productToView);
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
          //final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
          final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);
          final appUser = appUserProvider.appUser;

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
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
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
                    : productToView.isEmpty
                    ? Column(
                        children: [
                          pageHeaderImage(
                            imagePath: 'images/Goals.png',
                            context: context,
                            toolTip: 'ADD GOAL',
                            userProfileToShow: appUser,
                            pageTitle: 'SHOP',
                            isCoachView: false,
                            showCreateGoalPopupDialog: () => {},
                            buttonVisibility: false,
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1, // Full width tiles look best for coaching plans
                                childAspectRatio: 0.85,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return _buildProductTile(products[index]);
                              },
                            ),
                          ),
                        ],
                      )
                    : _buildProductDetail(),
              ),
            ),
          );
        }
      },
    );
  }
}
