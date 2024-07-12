import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    List<String> imageList = images.isNotEmpty
        ? images.map((i) => 'https://sgitjobs.com/MaseryShoppingNew/public/${i['path'] ?? ''}').toList()
        : [];
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      salePrice: json['sale_price'] != null ? double.tryParse(json['sale_price'].toString()) ?? 0.0 : 0.0,
      offerPrice: json['offer_price'] != null ? double.tryParse(json['offer_price'].toString()) ?? 0.0 : 0.0,
      imagePaths: imageList,
    );
  }
}

class OurbestproductList extends StatefulWidget {
  const OurbestproductList({Key? key}) : super(key: key);

  @override
  State<OurbestproductList> createState() => _OurbestproductListState();
}

class _OurbestproductListState extends State<OurbestproductList> {
  TextEditingController _searchController = TextEditingController();
  List<Product> featuredProducts = [];
  bool isLoading = true;
  bool hasError = false;
  int totalItems = 0;

  @override
  void initState() {
    super.initState();
    fetchFeaturedProducts();
    fetchTotalItems();
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/homescreen'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']['allProducts'] as List;
        setState(() {
          featuredProducts = data.map((productJson) => Product.fromJson(productJson)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load featured products');
      }
    } catch (e) {
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
          'Our Best Products',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2B2B),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 15,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
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
        child: LoadingAnimationWidget.halfTriangleDot(
          size: 50.0,
          color: Colors.redAccent,
        ),
      )
          : hasError
          ? Center(child: Text('Failed to load data'))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
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
              SizedBox(height: 15.0),
              Text(
                '52,082+ Items',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15.0),
              Column(
                children: [
                  for (var i = 0; i < featuredProducts.length; i += 2)
                    ResponsiveCardRow(
                      screenWidth: MediaQuery.of(context).size.width,
                      screenHeight: MediaQuery.of(context).size.height,
                      product1: featuredProducts[i],
                      product2: (i + 1 < featuredProducts.length) ? featuredProducts[i + 1] : null,
                    ),
                ],
              ),
            ],
          ),
        ),
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

