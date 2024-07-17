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
  final double minPrice;
  final double maxPrice;
  final List<String> imagePaths;
  final String slug;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.salePrice,
    required this.offerPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.imagePaths,
    required this.slug,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var images = json['product']?['image'] as List? ?? [];
    List<String> imageList = images
        .map((i) => 'https://sgitjobs.com/MaseryShoppingNew/public/${i['path']}')
        .toList();
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      salePrice: double.parse(json['sale_price'] ?? '0'),
      offerPrice: double.parse(json['offer_price'] ?? '0'),
      imagePaths: imageList,
      minPrice: double.tryParse(json['min_price']?.toString() ?? '0.0') ?? 0.0,
      maxPrice: double.tryParse(json['max_price']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class CategoryDescription extends StatefulWidget {
  @override
  _CategoryDescriptionState createState() => _CategoryDescriptionState();
}

class _CategoryDescriptionState extends State<CategoryDescription> {
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<dynamic> recentProducts = [];
  List<Product> filteredProducts = [];

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
  }

  Future<void> fetchFeaturedProducts() async {
    try {
      final response = await http.get(Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/homescreen'));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        print("Response body: $responseBody"); // Debugging line
        final data = jsonDecode(response.body)['data']['allProducts'] as List;
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

  Future<void> fetchFilteredProducts({
    required List<int> brandIds,
    required double minPrice,
    required double maxPrice,
  }) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final brandQueries = brandIds.map((id) => 'brand=$id').join('&');
      final url =
          'https://sgitjobs.com/MaseryShoppingNew/public/api/search?$brandQueries&min_price=$minPrice&max_price=$maxPrice';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        List<Product> product =
        data.map((productJson) => Product.fromJson(productJson)).toList();

        setState(() {
          recentProducts = product;
          filteredProducts = product;
          totalItems = product.length;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load filtered products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }


  Future<void> _showFilterDialog() async {
    List<int> selectedBrands = [];
    double minPrice = 0;
    double maxPrice = 10000;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Brands and Price Range'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CheckboxListTile(
                    title: Text('Nord'),
                    value: selectedBrands.contains(1),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedBrands.add(1);
                        } else {
                          selectedBrands.remove(1);
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Asus Vivobook'),
                    value: selectedBrands.contains(2),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedBrands.add(2);
                        } else {
                          selectedBrands.remove(2);
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Lenovo'),
                    value: selectedBrands.contains(3),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedBrands.add(3);
                        } else {
                          selectedBrands.remove(3);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Price Range: \$'),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Min',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            minPrice = double.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('to \$'),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Max',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            maxPrice = double.tryParse(value) ?? 2000;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Filter'),
              onPressed: () {
                Navigator.of(context).pop();
                fetchFilteredProducts(
                  brandIds: selectedBrands,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                );
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Category',
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
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
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
        ],
      ),
    );
  }
}
