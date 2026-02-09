import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pagination/Controller/auth_controller.dart';
import 'package:provider/provider.dart';

class SliverHomescreen extends StatefulWidget {
  const SliverHomescreen({super.key});

  @override
  State<SliverHomescreen> createState() => _SliverHomescreenState();
}

class _SliverHomescreenState extends State<SliverHomescreen> {
  final ScrollController _scrollController = ScrollController();
  bool isScrollable = false;
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
          log("Reached bottom, loading more...");
          authController.getProductData();
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
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      body: Stack(
        children: [
          RefreshIndicator(
            edgeOffset: 50,
            onRefresh: () async {
              await Provider.of<AuthController>(
                context,
                listen: false,
              ).refreshProducts();
            },
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 8.0,
              interactive: true,
              radius: const Radius.circular(10),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  const SliverAppBar(
                    pinned: true,
                    expandedHeight: 50,
                    backgroundColor: Color.fromARGB(255, 129, 88, 199),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text("Sliver Home Screen"),
                      centerTitle: true,
                    ),
                  ),
                  Consumer<AuthController>(
                    builder: (context, controller, child) {
                      final products = controller.productDetails;

                      if (controller.isLoading && products.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == products.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                tileColor: const Color.fromARGB(
                                  255,
                                  97,
                                  178,
                                  240,
                                ),
                                leading: CircleAvatar(
                                  child: Text("${products[index].id}"),
                                ),
                                title: Text(products[index].title),
                                subtitle: Text(products[index].category),
                              ),
                            );
                          },
                          childCount:
                              products.length + (controller.hasMore ? 1 : 0),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          if (isScrollable)
            Positioned(
              bottom: 30,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Icon(Icons.arrow_upward),
              ),
            ),
        ],
      ),
    );
  }
}
