import 'package:flutter/material.dart';

/// A responsive container that adjusts its width based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidthSmall;
  final double maxWidthMedium;
  final double maxWidthLarge;
  final EdgeInsetsGeometry padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidthSmall = 450,
    this.maxWidthMedium = 700,
    this.maxWidthLarge = 1200,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine max width based on screen size
    double maxWidth;
    if (screenWidth < 600) {
      maxWidth = maxWidthSmall;
    } else if (screenWidth < 1200) {
      maxWidth = maxWidthMedium;
    } else {
      maxWidth = maxWidthLarge;
    }

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: padding,
      child: child,
    );
  }
}
