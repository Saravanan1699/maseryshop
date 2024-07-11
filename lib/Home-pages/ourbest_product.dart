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
  const OurbestproductList({super.key});

  @override
  State<OurbestproductList> createState() => _OurbestproductListState();
}

class _OurbestproductListState extends State<OurbestproductList> {
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
    fetchFeaturedProducts();
    fetchTotalItems();
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      final response = await http.get(
          Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/homescreen'));
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
    final response = await http.get(Uri.parse(
        'https://sgitjobs.com/MaseryShoppingNew/public/api/totalitems'));
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
          'Our Best product',
          style: GoogleFonts.montserrat(
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
            );
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: Icon(
                      Icons.shopping_bag,
                      size: 24.0,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.blue,
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
                            fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    
      body: isLoading
          ?Center(
        child: Container(
          child: LoadingAnimationWidget.halfTriangleDot(
            size: 50.0, color: Colors.redAccent,
          ),
        ),
      )
          : hasError
              ? Center(child: Text('Failed to load data',
      style: GoogleFonts.montserrat(),))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double screenHeight = constraints.maxHeight;

                    TextStyle commonTextStyle = GoogleFonts.montserrat(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B2B2B),
                    );

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
                                Row(
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
                                    Spacer(),
                                    Card(
                                      elevation: 4,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: SizedBox(
                                        height: 30.0,
                                        width: 85.0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Sort',
                                            style: GoogleFonts.montserrat(),),
                                            SizedBox(width: 8.0),
                                            Icon(Icons.filter_list_outlined, color: Colors.black),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.white,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: SizedBox(
                                        height: 30.0,
                                        width: 85.0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Filter',
                                            style: GoogleFonts.montserrat(),),
                                            SizedBox(width: 8.0),
                                            Icon(Icons.filter_alt, color: Colors.black),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 15)
                                  ],
                                ),
                                ...featuredProducts.map((product) => Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ResponsiveCardRow(
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                    imagePath1: product.imagePaths.isNotEmpty ? product.imagePaths[0] : '',
                                    brand1: product.title,
                                    description1: product.description,
                                    price1: '\$${product.salePrice}',
                                    imagePath2: product.imagePaths.length > 1 ? product.imagePaths[1] : '',
                                    brand2: product.title,
                                    description2: product.description,
                                    price2: '\$${product.offerPrice}',
                                  ),
                                )).toList()
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

class ResponsiveCardRow extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String imagePath1;
  final String brand1;
  final String description1;
  final String price1;
  final String imagePath2;
  final String brand2;
  final String description2;
  final String price2;

  ResponsiveCardRow({
    required this.screenWidth,
    required this.screenHeight,
    required this.imagePath1,
    required this.brand1,
    required this.description1,
    required this.price1,
    required this.imagePath2,
    required this.brand2,
    required this.description2,
    required this.price2,
  });

  @override
  _ResponsiveCardRowState createState() => _ResponsiveCardRowState();
}

class _ResponsiveCardRowState extends State<ResponsiveCardRow> {
  bool _isExpanded1 = false;
  bool _isExpanded2 = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(10.0),
            ),            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.imagePath1.isNotEmpty 
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                        widget.imagePath1,
                        height: widget.screenHeight * 0.25,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Placeholder(fallbackHeight: widget.screenHeight * 0.25);
                        },
                      ),
                  )
                  : Placeholder(fallbackHeight: widget.screenHeight * 0.25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.brand1,style: GoogleFonts.montserrat(
                      fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.description1,
                    style: GoogleFonts.montserrat(fontSize: 15),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.price1, style: GoogleFonts.montserrat(fontSize: widget.screenWidth * 0.035, fontWeight: FontWeight.bold)),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added to Cart!',
                            style: GoogleFonts.montserrat(),)),
                        );
                      },
                      child: Text('Add to Cart',
                        style: GoogleFonts.montserrat(),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
        Expanded(
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(10.0),
            ),            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.imagePath2.isNotEmpty 
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                        widget.imagePath2,
                        height: widget.screenHeight * 0.25,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Placeholder(fallbackHeight: widget.screenHeight * 0.25);
                        },
                      ),
                  )
                  : Placeholder(fallbackHeight: widget.screenHeight * 0.25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.brand2, style: GoogleFonts.montserrat(
                      fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.description2,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.price2, style: GoogleFonts.montserrat(fontSize: widget.screenWidth * 0.035, fontWeight: FontWeight.bold)),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added to Cart!',
                            style: GoogleFonts.montserrat(),)),
                        );
                      },
                      child: Text('Add to Cart',
                        style: GoogleFonts.montserrat(),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }

}
