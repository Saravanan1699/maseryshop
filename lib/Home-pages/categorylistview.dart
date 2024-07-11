import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../home.dart';

class Product {
  final int id;
  final String brand;
  final String name;
  final String description;
  final double minPrice;
  final double maxPrice;
  final List<String> imageList;

  Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.imageList,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var images = json['image'] as List<dynamic>? ?? [];
    List<String> imageList = images
        .map(
            (i) => 'https://sgitjobs.com/MaseryShoppingNew/public/${i['path']}')
        .toList();

    return Product(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? 'Unknown',
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? 'No description',
      minPrice: double.tryParse(json['min_price']?.toString() ?? '0.0') ?? 0.0,
      maxPrice: double.tryParse(json['max_price']?.toString() ?? '0.0') ?? 0.0,
      imageList: imageList,
    );
  }
}

class Category {
  final int id;
  final String name;
  final String description;
  final List<Product> products;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var products = (json['products'] as List<dynamic>? ?? [])
        .map((productJson) => Product.fromJson(productJson))
        .toList();

    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? 'No description',
      products: products,
    );
  }
}

class CategoryDescription extends StatefulWidget {
  @override
  _CategoryDescriptionState createState() => _CategoryDescriptionState();
}

class _CategoryDescriptionState extends State<CategoryDescription> {
  Map<String, bool> _filterOptions = {
    'Asus': false,
    'Acer': false,
    'HP': false,
    'Samsung': false,
    'Lenovo': false,
    'Apple': false,
    'Android': false,
    'Samsung Galaxy A11': false,
    'Samsung Galaxy': false,
    'IQOO 5G': false,
    'Chandru': false,
  };
  Map<String, bool> _filtercategory = {
    'Asus': false,
    'Acer': false,
    'HP': false,
    'Samsung': false,
    'Lenovo': false,
    'Apple': false,
    'Xiaomi': false,
    'Dell': false,
    'Samsung Galaxy A11': false,
    'Samsung Galaxy': false,
    'IQOO': false,
    'Realme 12 Pro plus': false,
  };

  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<Category> categories = [];

  bool isLoading = true;
  bool hasError = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    fetchFeaturedProducts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://sgitjobs.com/MaseryShoppingNew/public/api/homescreen'),
      );
      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body)['data']['categoryBasedProducts'] as List;
        setState(() {
          categories = data
              .map((categoryJson) => Category.fromJson(categoryJson))
              .toList();
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
        title: Text('Category',
        style: GoogleFonts.montserrat(),),
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
      ),
      body: isLoading
          ? Center(
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
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                '52,082+',
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
                              child: GestureDetector(
                                onTap: () => _showBrandDialog(context),
                                child: SizedBox(
                                  height: 30.0,
                                  width: 85.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Brands',
                                      style: GoogleFonts.montserrat(),),
                                      SizedBox(width: 8.0),
                                      Icon(Icons.filter_list,
                                          color: Colors.black),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Card(
                            //   color: Colors.white,
                            //   elevation: 4,
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(10.0),
                            //   ),
                            //   child: SizedBox(
                            //     height: 30.0,
                            //     width: 85.0,
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Text('Filter'),
                            //         SizedBox(width: 8.0),
                            //         Icon(Icons.filter_alt, color: Colors.black),
                            //       ],
                            //     ),
                            //   ),
                            // ),

                            GestureDetector(
                              onTap: () => _showFilterDialog(context),
                              child: Card(
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
                                      Icon(Icons.filter_alt,
                                          color: Colors.black),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15)
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: categories.expand((category) {
                                return category.products
                                    .map((product) => Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: ResponsiveCardRow(
                                            screenWidth: screenWidth,
                                            screenHeight: screenHeight,
                                            imagePath1:
                                                product.imageList.isNotEmpty
                                                    ? product.imageList[0]
                                                    : '',
                                            brand1: product.name,
                                            description1: product.description,
                                            price1: '\$${product.minPrice}',
                                            imagePath2:
                                                product.imageList.length > 1
                                                    ? product.imageList[1]
                                                    : '',
                                            brand2: product.name,
                                            description2: product.description,
                                            price2: '\$${product.maxPrice}',
                                          ),
                                        ))
                                    .toList();
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Category Option',
          style: GoogleFonts.montserrat(),),
          content: Container(
            width: double.minPositive,
            child: ListView(
              shrinkWrap: true,
              children: _filterOptions.keys.map((String key) {
                return _buildCheckboxListTile(key);
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
              style: GoogleFonts.montserrat(),),
            ),
            TextButton(
              onPressed: () {
                // Handle filter logic
                Navigator.of(context).pop();
              },
              child: Text('Apply',
              style: GoogleFonts.montserrat(),),
            ),
          ],
        );
      },
    );
  }

  void _showBrandDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Category Option'),
          content: Container(
            width: double.minPositive,
            child: ListView(
              shrinkWrap: true,
              children: _filterOptions.keys.map((String key) {
                return _buildCheckboxListTile(key);
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
              style: GoogleFonts.montserrat(),),
            ),
            TextButton(
              onPressed: () {
                // Handle filter logic
                Navigator.of(context).pop();
              },
              child: Text('Apply',
              style: GoogleFonts.montserrat(),),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckboxListTile(String title) {
    return CheckboxListTile(
      value: _filterOptions[title], // Set initial value
      onChanged: (bool? value) {
        setState(() {
          _filterOptions[title] = value!;
        });
      },
      title: Text(title,style: GoogleFonts.montserrat(),),
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
  bool descriptionExpanded1 = false;
  bool descriptionExpanded2 = false;

  void _toggleDescription1() {
    setState(() {
      descriptionExpanded1 = !descriptionExpanded1;
    });
  }

  void _toggleDescription2() {
    setState(() {
      descriptionExpanded2 = !descriptionExpanded2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildProductCard(
          widget.imagePath1,
          widget.brand1,
          widget.description1,
          widget.price1,
          descriptionExpanded1,
          _toggleDescription1,
        ),
        buildProductCard(
          widget.imagePath2,
          widget.brand2,
          widget.description2,
          widget.price2,
          descriptionExpanded2,
          _toggleDescription2,
        ),
      ],
    );
  }

  Widget buildProductCard(
    String imagePath,
    String brand,
    String description,
    String price,
    bool isExpanded,
    VoidCallback onReadMore,
  ) {
    return Card(
      elevation: 4,
      child: Container(
        width: widget.screenWidth * 0.45,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imagePath.isNotEmpty
                ? _buildImage(imagePath)
                : Container(
                    height: widget.screenHeight * 0.2,
                    width: widget.screenWidth * 0.4,
                    color: Colors.grey),
            SizedBox(height: 8.0),
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
            ),
            Text(price,
                style: TextStyle(
                    fontSize: widget.screenWidth * 0.04,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        height: widget.screenHeight * 0.2,
        width: widget.screenWidth * 0.4,
        errorBuilder: (context, error, stackTrace) {
          // Log the error or print it for debugging
          print('Failed to load image: $error');
          return Container(
            height: widget.screenHeight * 0.2,
            width: widget.screenWidth * 0.4,
            color: Colors.grey,
            child: Center(child: Icon(Icons.error, color: Colors.red)),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        height: widget.screenHeight * 0.2,
        width: widget.screenWidth * 0.4,
        errorBuilder: (context, error, stackTrace) {
          // Log the error or print it for debugging
          print('Failed to load image: $error');
          return Container(
            height: widget.screenHeight * 0.2,
            width: widget.screenWidth * 0.4,
            color: Colors.grey,
            child: Center(child: Icon(Icons.error, color: Colors.red)),
          );
        },
      );
    }
  }


}
