import 'package:flutter/gestures.dart';

void sidebarOnHover(
  PointerEvent details,
  bool isExpanded,
  void Function(bool, double) updateSidebar,
) {
  if (details.position.dx < 50 && !isExpanded) {
    updateSidebar(true, 250);
  } else if (details.position.dx > 250 && isExpanded) {
    updateSidebar(false, 50);
  }
}