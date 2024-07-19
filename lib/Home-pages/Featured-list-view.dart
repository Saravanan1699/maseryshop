import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../ProductDetailsPage.dart';
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
  final String slug;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.salePrice,
    required this.offerPrice,
    required this.imagePaths,
    required this.slug,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var images = json['product']['image'] as List;
    List<String> imageList = images
        .map(
            (i) => 'https://sgitjobs.com/MaseryShoppingNew/public/${i['path']}')
        .toList();
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      salePrice: double.parse(json['sale_price']),
      offerPrice: double.parse(json['offer_price']),
      imagePaths: imageList,
      slug: json['slug'] ?? '', // Ensure default value or handle null cases
    );
  }
}

class GraphicsCard extends StatefulWidget {

  const GraphicsCard({super.key});

  @override
  State<GraphicsCard> createState() => _GraphicsCardState();
}

class _GraphicsCardState extends State<GraphicsCard> {
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<Product> featuredProducts = [];
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
    fetchData();
    fetchTotalItems();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
          Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/homescreen'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          featuredProducts = (data['featured_products'] as List)
              .map((productJson) => Product.fromJson(productJson))
              .toList();
          totalItems = data['total_items'] != null
              ? int.parse(data['total_items'])
              : 0; // Ensure total_items is parsed safely
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> fetchTotalItems() async {
    try {
      final response = await http.get(
        Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/totalitems'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalItems = int.parse(data['total_items']);
        });
      } else {
        throw Exception('Failed to load total items');
      }
    } catch (e) {
      print('Error fetching total items: $e');
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
          'Featured product',
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.w700,
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
      body: isLoading
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
                    hintStyle: GoogleFonts.montserrat(),
                    prefixIcon: Icon(Icons.search, color: Color(0xffBBBBBB)),
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
                      for (var i = 0; i < featuredProducts.length; i += 2)
                        ResponsiveCardRow(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          product1: featuredProducts[i],
                          product2: (i + 1 < featuredProducts.length)
                              ? featuredProducts[i + 1]
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

  Future<void> addToCart(BuildContext context, Product product) async {
    try {
      final response = await http.post(
        Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/addToCart/${product.slug}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product': {'id': product.id, 'slug': product.slug},
          'quantity': 3,
          'shipTo': 1,
          'shippingZoneId': 1,
          'handling': 1,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Added ${product.slug} to cart')),
        );
      } else if (response.statusCode == 402) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseBody['message'] ??
                  'This item is already in the cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add product to cart')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Card(
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
                  return Placeholder(fallbackHeight: screenHeight * 0.25);
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await addToCart(context, product);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Add to Cart'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
