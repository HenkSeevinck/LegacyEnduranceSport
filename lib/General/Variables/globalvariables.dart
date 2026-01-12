library;

import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:provider/provider.dart';
// Avoid importing `google_fonts` here so fonts aren't accessed at library
// initialization time (which can trigger AssetManifest lookups before
// `main()` config runs). Widgets should call the font function at runtime.

//------------------------------------------------------------------------
// Corporate Anchor Colors (Add different Anchor Color combination to change the theme of the App)
Map<String, dynamic> anchorPair1 = {'primaryColor': const Color(0xFF000000), 'secondaryColor': const Color(0xFFFFFFFF)};

//------------------------------------------------------------------------
// Corporate Utility Colors
Map<String, dynamic> utilityPair1 = {'color1': const Color(0xFF007069), 'color2': const Color(0xFF85E5A7)};

Map<String, dynamic> utilityPair2 = {'color1': const Color(0xFF0072FD), 'color2': const Color(0xFF00D9FF)};

Map<String, dynamic> utilityPair3 = {'color1': const Color(0xFFFF7038), 'color2': const Color(0xFFFCDF20)};

Map<String, dynamic> utilityPair4 = {'color1': const Color(0xFF9E0D8F), 'color2': const Color(0xFFFF99FF)};

//------------------------------------------------------------------------
//Application Information
Map<String, dynamic> appInfo = {
  'name': 'APPLICATION BUILDER',
  'description': '''
TBA
''',
  'version': 0.0,
  'applicationID': 9,
};

//------------------------------------------------------------------------
//Responsive Themes, test
class ResponsiveTheme {
  final BuildContext context;

  InternalStatusProvider get internalStatusProvider => Provider.of<InternalStatusProvider>(context, listen: false);
  get platform => internalStatusProvider.platform;
  ResponsiveTheme(this.context);

  double get header1Size => platform == 'DesktopWeb' || platform == 'Desktop'
    ? MediaQuery.of(context).size.width * 0.02 
    : platform == 'MobileWeb' || platform == 'Mobile'
      ? MediaQuery.of(context).size.width * 0.06 
      : MediaQuery.of(context).size.width * 0.02;

  double get header2Size => platform == 'DesktopWeb' || platform == 'Desktop'
    ? MediaQuery.of(context).size.width * 0.01 
    : platform == 'MobileWeb' || platform == 'Mobile'
      ? MediaQuery.of(context).size.width * 0.04 
      : MediaQuery.of(context).size.width * 0.01;
  
  double get header3Size => platform == 'DesktopWeb' || platform == 'Desktop'
    ? MediaQuery.of(context).size.width * 0.00875 
    : platform == 'MobileWeb' || platform == 'Mobile'
      ? MediaQuery.of(context).size.width * 0.03 
      : MediaQuery.of(context).size.width * 0.00875;
  
  double get bodySize => platform == 'DesktopWeb' || platform == 'Desktop'
    ? MediaQuery.of(context).size.width * 0.00875 
    : platform == 'MobileWeb' || platform == 'Mobile'
      ? MediaQuery.of(context).size.width * 0.03 
      : MediaQuery.of(context).size.width * 0.00875;
  
  double get formInputFieldHeight => platform == 'DesktopWeb' || platform == 'Desktop'
    ? MediaQuery.of(context).size.height * 0.0175 * 3 * 3 
    : platform == 'MobileWeb' || platform == 'Mobile'
      ? 50
      : MediaQuery.of(context).size.height * 0.0175 * 3;

  double get pageHeaderHeight => MediaQuery.of(context).size.height * 0.15;
  
  double get pageFooterHeight => MediaQuery.of(context).size.height * 0.075;

  Map<String, dynamic> get theme => {
    'anchorColors': anchorPair1, 
    'utilityColorPair1': utilityPair1, 
    'utilityColorPair2': utilityPair2, 
    'utilityColorPair3': utilityPair3, 
    'utilityColorPair4': utilityPair4, 
    'logo': 'images/Legacy-Endurance-Logo.png', 
    'font': ({TextStyle? textStyle}) => (textStyle ?? const TextStyle()).copyWith(fontFamily: 'Roboto'),
    'header1Size': header1Size, 
    'header2Size': header2Size, 
    'header3Size': header3Size,
    'formInputFieldHeight': formInputFieldHeight,
    'bodySize': bodySize, 
    'pageHeaderHeight': pageHeaderHeight, 
    'pageFooterHeight': pageFooterHeight,
    };
}
