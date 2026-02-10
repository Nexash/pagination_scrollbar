import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pagination/Controller/auth_controller.dart';
import 'package:pagination/Helper/overlay_dropdown.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final SearchOverlayController _overlayController = SearchOverlayController();
  bool isScrollable = false;
  final TextEditingController searchController = TextEditingController();
  List<String> filteredData = [];

  FocusNode keyboardFocus = FocusNode();
  Timer? _debounce;

  String typedValue = "";
  String prevValue = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        log("buttom reached");
        final authController = Provider.of<AuthController>(
          context,
          listen: false,
        );

        if (!authController.isLoading && authController.hasMore) {
          prevValue = typedValue;
          log("Reached bottom, loading more...");
          searchController.text.isEmpty
              ? authController.getProductData()
              : authController.onSearchChanged(typedValue);
        }
      }

      if (_scrollController.offset > 300) {
        if (isScrollable == false) {
          setState(() {
            isScrollable = true;
          });
        }
      } else {
        if (isScrollable == true) {
          setState(() {
            isScrollable = false;
          });
        }
      }
    });
    if (prevValue != typedValue) {
      setState(() {
        isScrollable = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    keyboardFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.deepPurple[200],
        appBar: AppBar(
          title: Center(child: Text("Product Details")),
          backgroundColor: Colors.deepPurple[300],
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Consumer<AuthController>(
                      builder: (context, controller, child) {
                        return CompositedTransformTarget(
                          link: _overlayController.layerLink,
                          child: TextField(
                            controller: searchController,
                            focusNode: keyboardFocus,
                            onChanged: (value) async {
                              final String currentQuery = value;
                              typedValue = value;

                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(0);
                              }

                              if (isScrollable) {
                                setState(() => isScrollable = false);
                              }

                              if (value.isEmpty) {
                                _debounce?.cancel();
                                _overlayController.hideOverlay();
                                return;
                              }

                              _overlayController.showOverlay(
                                context: context,
                                items: [],
                                isLoading: true,
                                onItemSelected: (selected) {
                                  searchController.text = selected;
                                  _overlayController.hideOverlay();
                                },
                              );

                              if (_debounce?.isActive ?? false)
                                _debounce!.cancel();

                              _debounce = Timer(
                                const Duration(milliseconds: 1000),
                                () async {
                                  await controller.onSearchChanged(
                                    currentQuery,
                                  );

                                  if (searchController.text == currentQuery &&
                                      typedValue.isNotEmpty) {
                                    _overlayController.showOverlay(
                                      context: context,
                                      items: controller.suggestions,
                                      isLoading: false,
                                      onItemSelected: (selected) {
                                        setState(() {
                                          searchController.text = selected;
                                          typedValue = selected;
                                        });
                                        _overlayController.hideOverlay();
                                      },
                                    );
                                  } else {
                                    log(
                                      "Skipped showing overlay for outdated query: $currentQuery",
                                    );
                                  }
                                },
                              );
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              fillColor: Colors.blueGrey,
                              hintText: "Search Product...",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                    isScrollable = false;
                                    _scrollController.animateTo(
                                      0,
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.fastOutSlowIn,
                                    );
                                    _overlayController.hideOverlay();
                                    keyboardFocus.unfocus();
                                  });
                                },
                                icon: Icon(Icons.clear_rounded, size: 30),
                                style: IconButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(10, 10),
                                  backgroundColor: Colors.transparent,

                                  foregroundColor: const Color.fromARGB(
                                    255,
                                    238,
                                    10,
                                    10,
                                  ),
                                  hoverColor: Colors.grey[300],
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 10,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Consumer<AuthController>(
                      builder: (context, controller, child) {
                        final products =
                            searchController.text.isEmpty
                                ? controller.productDetails
                                : controller.suggestions;
                        if (controller.isLoading && products.isEmpty) {
                          return Center(child: CircularProgressIndicator());
                        }

                        return RefreshIndicator(
                          color: Colors.white,
                          backgroundColor: Colors.blue,
                          strokeWidth: 4.0,
                          onRefresh: () async {
                            typedValue.isEmpty
                                ? await controller.refreshProducts()
                                : await controller.refreshSearchedProducts(
                                  typedValue,
                                );
                          },
                          child: Scrollbar(
                            thumbVisibility: true,
                            controller: _scrollController,
                            thickness: 8.0,
                            radius: const Radius.circular(10),
                            interactive: true,
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  products.length +
                                  (controller.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == products.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return ListTile(
                                  title: Text(
                                    "${products[index].id} ${products[index].title}",
                                  ),
                                  subtitle: Text(products[index].category),
                                  trailing: Text(
                                    products[index].price.toString(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              isScrollable
                  ? Positioned(
                    top: 80,
                    left: MediaQuery.of(context).size.width / 2 - 30,
                    child: FloatingActionButton(
                      backgroundColor: const Color.fromARGB(255, 219, 216, 216),
                      onPressed: () {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.fastOutSlowIn,
                          );
                        }
                      },
                      child: Icon(Icons.arrow_upward, color: Colors.black),
                    ),
                  )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
