import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pagination/Controller/auth_controller.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      appBar: AppBar(title: Text("Product Details")),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Consumer<AuthController>(
                  builder: (context, controller, child) {
                    final products = controller.productDetails;
                    if (controller.isLoading &&
                        controller.productDetails.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return RefreshIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.blue,
                      strokeWidth: 4.0,
                      onRefresh: () async {
                        await controller.refreshProducts();
                      },
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: _scrollController,
                        thickness: 8.0,
                        radius: const Radius.circular(10),
                        interactive: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          // physics: const AlwaysScrollableScrollPhysics(),
                          itemCount:
                              products.length + (controller.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == controller.productDetails.length) {
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
                              trailing: Text(products[index].price.toString()),
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
                top: 5,
                left: MediaQuery.of(context).size.width / 2 - 20,
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
    );
  }
}
