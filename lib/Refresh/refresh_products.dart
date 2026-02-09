import 'package:flutter/material.dart';

class RefreshProducts extends StatefulWidget {
  final Widget child;
  final Future Function() onRefresh;
  const RefreshProducts({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<RefreshProducts> createState() => _RefreshProductsState();
}

class _RefreshProductsState extends State<RefreshProducts> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
