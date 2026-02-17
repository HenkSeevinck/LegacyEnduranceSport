// Conditionally export platform-specific implementations.
export 'web_view_checkout_mobile.dart'
  if (dart.library.html) 'web_view_checkout_web.dart';
