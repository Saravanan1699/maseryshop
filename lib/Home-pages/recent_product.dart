import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Base_Url/BaseUrl.dart';
import '../bottombar.dart';
import '../cartpage.dart';
import '../home.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final double salePrice;
  final double offerPrice;
  final List<String> imagePaths;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.salePrice,
    required this.offerPrice,
    required this.imagePaths,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var images = json['product']?['image'] as List? ?? [];
    List<String> imageList = images
        .map((i) => 'https://sgitjobs.com/MaseryShoppingNew/public/${i['path']}')
        .toList();
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      salePrice: double.parse(json['sale_price'] ?? '0'),
      offerPrice: double.parse(json['offer_price'] ?? '0'),
      imagePaths: imageList,
    );
  }
}

class GraphicsCard1 extends StatefulWidget {
  const GraphicsCard1({super.key});

  @override
  State<GraphicsCard1> createState() => _GraphicsCard1State();
}

class _GraphicsCard1State extends State<GraphicsCard1> {
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<dynamic> recentProducts = [];
  bool isLoading = true;
  bool hasError = false;
  int totalItems = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchFeaturedProducts();
    fetchTotalItems();
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}homescreen'));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        print("Response body: $responseBody"); // Debugging line
        final data = jsonDecode(response.body)['data']['recent_products'] as List;
        setState(() {
          recentProducts = data.map((productJson) => Product.fromJson(productJson)).toList();
          isLoading = false;
        });
      } else {
        print("Failed with status code: ${response.statusCode}"); // Debugging line
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      print("Error: $e"); // Debugging line
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> fetchTotalItems() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}totalitems'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        totalItems = int.parse(data['total_items']);
      });
    } else {
      throw Exception('Failed to load total items');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Recent product',
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.w700, // Regular weight for the description
            color: Color(0xFF2B2B2B),
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xffF2F2F2),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  size: 15,
                ),
                onPressed: () {
                  setState(() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                  });
                },
              ),
            );
          },
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
                },
                icon: Icon(
                  Icons.shopping_bag,
                  size: 24.0,
                  color: Colors.blue,
                ),
              ),
              if (totalItems > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$totalItems',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body:  isLoading
          ? Center(
        child: Container(
          child: LoadingAnimationWidget.halfTriangleDot(
            size: 50.0,
            color: Colors.redAccent,
          ),
        ),
      )
          : hasError
          ? Center(child: Text('Failed to load data'))
          : LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search any Product...',
                    hintStyle: GoogleFonts.montserrat(
                    ),
                    prefixIcon:
                    Icon(Icons.search, color: Color(0xffBBBBBB)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xffF2F2F2),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          '52,082+ Items',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      for (var i = 0; i < recentProducts.length; i += 2)
                        ResponsiveCardRow(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          product1: recentProducts[i],
                          product2: (i + 1 < recentProducts.length)
                              ? recentProducts[i + 1]
                              : null,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {
        },
      ),

    );
  }
}

class ResponsiveCardRow extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final Product product1;
  final Product? product2;

  ResponsiveCardRow({
    required this.screenWidth,
    required this.screenHeight,
    required this.product1,
    this.product2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProductCard(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            product: product1,
          ),
        ),
        if (product2 != null)
          Expanded(
            child: ProductCard(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              product: product2!,
            ),
          ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final Product product;

  ProductCard({
    required this.screenWidth,
    required this.screenHeight,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          product.imagePaths.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              product.imagePaths[0],
              height: screenHeight * 0.25,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Placeholder(
                    fallbackHeight: screenHeight * 0.25);
              },
            ),
          )
              : Placeholder(fallbackHeight: screenHeight * 0.25),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(product.title,
                style: GoogleFonts.montserrat(
                    fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.description,
              style: GoogleFonts.montserrat(fontSize: 15),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('\$${product.salePrice}',
                style: GoogleFonts.montserrat(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  // Handle the add to cart action here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to Cart!')),
                  );
                },
                child: Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
