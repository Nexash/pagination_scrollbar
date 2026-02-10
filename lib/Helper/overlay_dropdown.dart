import 'package:flutter/material.dart';
import 'package:pagination/Modal/product_modal.dart';

class SearchOverlayController {
  OverlayEntry? _overlayEntry;
  final LayerLink layerLink = LayerLink();

  void showOverlay({
    required BuildContext context,
    required List<ProductModal> items,
    required Function(String) onItemSelected, // Receives the product title
    bool isLoading = false,
  }) {
    // 1. Calculate the width of the TextField anchor
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    hideOverlay();

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width, // Matches your TextField width automatically
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 55), // Space between field and dropdown
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(maxHeight: 300),
                  child:
                      isLoading
                          ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : items.isEmpty
                          ? const ListTile(title: Text("No products found"))
                          : ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: items.length,
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final product = items[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.shopping_bag_outlined,
                                ),
                                title: Text(product.title),
                                subtitle: Text("\$${product.price}"),
                                onTap: () {
                                  // 2. Call the callback with the title
                                  onItemSelected(product.title);
                                  hideOverlay();
                                },
                              );
                            },
                          ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
