import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../ProductDetailsPage.dart';
import '../bottombar.dart';
import '../category-productview.dart';
import '../home.dart';

class CategotyProduct {
  final int id;
  final String title;
  final String description;
  final double salePrice;
  final double offerPrice;
  final double minPrice;
  final double maxPrice;
  final List<String> imagePaths;
  final String slug;

  CategotyProduct({
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

  factory CategotyProduct.fromJson(Map<String, dynamic> json) {
    var images = json['product']?['image'] as List? ?? [];
    List<String> imageList = images
        .map(
            (i) => 'https://sgitjobs.com/MaseryShoppingNew/public/${i['path']}')
        .toList();
    return CategotyProduct(
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
  List<dynamic> allProducts = [];
  List<CategotyProduct> filteredProducts = [];

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
      final response = await http.get(
        Uri.parse(
            'https://sgitjobs.com/MaseryShoppingNew/public/api/homescreen'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data']['allProducts'] as List;
        List<CategotyProduct> products =
            data.map((productJson) => CategotyProduct.fromJson(productJson)).toList();

        setState(() {
          allProducts = products;
          filteredProducts = products;
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
        List<CategotyProduct> products =
            data.map((productJson) => CategotyProduct.fromJson(productJson)).toList();

        setState(() {
          allProducts = products;
          filteredProducts = products;
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
          backgroundColor: Colors.white,
          title: Text('Select Brands'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBrandFilterItem(
                          brandId: 5,
                          brandName: 'Acer',
                          isSelected: selectedBrands.contains(5),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(5)) {
                                selectedBrands.remove(5);
                              } else {
                                selectedBrands.add(5);
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        _buildBrandFilterItem(
                          brandId: 7,
                          brandName: 'Samsung',
                          isSelected: selectedBrands.contains(7),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(7)) {
                                selectedBrands.remove(7);
                              } else {
                                selectedBrands.add(7);
                              }
                            });
                          },
                        ),
                        // Repeat for other brands
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBrandFilterItem(
                          brandId: 12,
                          brandName: 'Asus Vivobook',
                          isSelected: selectedBrands.contains(12),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(12)) {
                                selectedBrands.remove(12);
                              } else {
                                selectedBrands.add(12);
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        _buildBrandFilterItem(
                          brandId: 6,
                          brandName: 'Hp',
                          isSelected: selectedBrands.contains(6),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(6)) {
                                selectedBrands.remove(6);
                              } else {
                                selectedBrands.add(6);
                              }
                            });
                          },
                        ),

                        // Repeat for other brands
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBrandFilterItem(
                          brandId: 11,
                          brandName: 'Xiaomi',
                          isSelected: selectedBrands.contains(11),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(11)) {
                                selectedBrands.remove(11);
                              } else {
                                selectedBrands.add(11);
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        _buildBrandFilterItem(
                          brandId: 17,
                          brandName: 'Samsung Galaxy',
                          isSelected: selectedBrands.contains(17),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(17)) {
                                selectedBrands.remove(17);
                              } else {
                                selectedBrands.add(17);
                              }
                            });
                          },
                        ),

                        // Repeat for other brands
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBrandFilterItem(
                          brandId: 15,
                          brandName: 'Samsung Galaxy A11',
                          isSelected: selectedBrands.contains(15),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(15)) {
                                selectedBrands.remove(15);
                              } else {
                                selectedBrands.add(15);
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        _buildBrandFilterItem(
                          brandId: 18,
                          brandName: 'IQOO',
                          isSelected: selectedBrands.contains(18),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(18)) {
                                selectedBrands.remove(18);
                              } else {
                                selectedBrands.add(7);
                              }
                            });
                          },
                        ),

                        // Repeat for other brands
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildBrandFilterItem(
                          brandId: 21,
                          brandName: 'OnePlus',
                          isSelected: selectedBrands.contains(21),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(21)) {
                                selectedBrands.remove(21);
                              } else {
                                selectedBrands.add(21);
                              }
                            });
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        _buildBrandFilterItem(
                          brandId: 2,
                          brandName: 'Asus',
                          isSelected: selectedBrands.contains(2),
                          onTap: () {
                            setState(() {
                              if (selectedBrands.contains(2)) {
                                selectedBrands.remove(2);
                              } else {
                                selectedBrands.add(2);
                              }
                            });
                          },
                        ),
                        // Repeat for other brands
                      ],
                    ),
                  ],
                );
              },
            ),
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

  Widget _buildBrandFilterItem({
    required int brandId,
    required String brandName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.greenAccent : Colors.white,
          border: Border.all(color: isSelected ? Colors.green : Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          brandName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterprice() async {
    List<int> selectedBrands = [];
    double minPrice = 0;
    double maxPrice = 10000;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Select Price Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RangeSlider(
                    values: RangeValues(minPrice, maxPrice),
                    min: 0,
                    max: 10000,
                    divisions: 100, // Adjust divisions as needed
                    onChanged: (RangeValues values) {
                      setState(() {
                        minPrice = values.start;
                        maxPrice = values.end;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Min: \$${minPrice.toStringAsFixed(2)}'),
                      Text('Max: \$${maxPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
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
      },
    );
  }

  void _searchProducts(String query) {
    setState(() {
      allProducts = allProducts
          .where((product) =>
              product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.slug.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  });
                },
              ),
            );
          },
        ),
        //     actions: [
        //   IconButton(
        //   icon: Icon(Icons.filter_list),
        //   onPressed: () {
        //     _showFilterDialog();
        //   },
        // ),
        //     ],
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
                            onChanged: _searchProducts,
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
                                    SizedBox(
                                      height: 40,
                                      width: 120,
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Brands',
                                                style: GoogleFonts.montserrat(),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.filter_list,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  _showFilterDialog();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40,
                                      width: 105,
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Price',
                                                style: GoogleFonts.montserrat(),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.price_change_outlined,
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  _showFilterprice();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                for (var i = 0; i < allProducts.length; i += 2)
                                  ResponsiveCardRow(
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                    product1: allProducts[i],
                                    product2: (i + 1 < allProducts.length)
                                        ? allProducts[i + 1]
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
  final CategotyProduct product1;
  final CategotyProduct? product2;

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
  final CategotyProduct product;

  ProductCard({
    required this.screenWidth,
    required this.screenHeight,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ProductDetailsPage(product: CategotyProduct,),
        //   ),
        // );
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
          ],
        ),
      ),
    );
  }
}
