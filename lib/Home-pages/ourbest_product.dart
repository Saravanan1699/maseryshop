import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Our Best product',
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
                  Positioned(
                    right: 4,
                    top: 4,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    
      body: isLoading
          ? Center(
        child: Container(
          child: LoadingAnimationWidget.flickr(
              leftDotColor: Colors.redAccent,
              rightDotColor: Colors.black,
              size: 40
          ),
        ),
      )
          : hasError
              ? Center(child: Text('Failed to load data'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double screenHeight = constraints.maxHeight;

                    TextStyle commonTextStyle = TextStyle(
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
                                        style: TextStyle(
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
                                            Text('Sort'),
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
                                            Text('Filter'),
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
                                    commonTextStyle: commonTextStyle,
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
  final TextStyle commonTextStyle;
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
    required this.commonTextStyle,
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
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.imagePath1.isNotEmpty 
                  ? Image.network(
                      widget.imagePath1,
                      height: widget.screenHeight * 0.25,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Placeholder(fallbackHeight: widget.screenHeight * 0.25);
                      },
                    )
                  : Placeholder(fallbackHeight: widget.screenHeight * 0.25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.brand1, style: widget.commonTextStyle),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildDescription(widget.description1, _isExpanded1, () {
                    setState(() {
                      _isExpanded1 = !_isExpanded1;
                    });
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.price1, style: TextStyle(fontSize: widget.screenWidth * 0.035, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Card(
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.imagePath2.isNotEmpty 
                  ? Image.network(
                      widget.imagePath2,
                      height: widget.screenHeight * 0.25,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Placeholder(fallbackHeight: widget.screenHeight * 0.25);
                      },
                    )
                  : Placeholder(fallbackHeight: widget.screenHeight * 0.25),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.brand2, style: widget.commonTextStyle),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildDescription(widget.description2, _isExpanded2, () {
                    setState(() {
                      _isExpanded2 = !_isExpanded2;
                    });
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.price2, style: TextStyle(fontSize: widget.screenWidth * 0.035, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String description, bool isExpanded, VoidCallback onReadMore) {
    final maxLines = isExpanded ? null : 3;
    final overflow = isExpanded ? TextOverflow.visible : TextOverflow.ellipsis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          maxLines: maxLines,
          overflow: overflow,
        ),
        if (description.length > 100) // Adjust the length threshold as needed
          InkWell(
            onTap: onReadMore,
            child: Text(
              isExpanded ? 'Read Less' : 'Read More',
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }
}
