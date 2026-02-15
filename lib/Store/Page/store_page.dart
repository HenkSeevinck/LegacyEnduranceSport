import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/Store/MobileFunctions/mobile_store_page.dart';
import 'package:provider/provider.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {


  //----------------------------------------------------
  // Desktop Layout
  Widget _buildDesktopStorePage() {
    return Scaffold(body: const Center(child: Text('Store Page - Desktop Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Fallback Layout
  Widget _buildFallbackStorePage() {
    return Scaffold(body: const Center(child: Text('Store Page - Fallback Layout Coming Soon')));
  }

  //----------------------------------------------------
  // Build method with FutureBuilder
  @override
  Widget build(BuildContext context) {
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final platform = internalStatusProvider.platform;

    if (platform == 'MobileWeb' || platform == 'Mobile') {
      return MobileStorePage();
    } else if (platform == 'ComputerWeb' || platform == 'Computer') {
      return _buildDesktopStorePage();
    } else {
      return _buildFallbackStorePage();
    }
  }
}
