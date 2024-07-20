import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dots_indicator/dots_indicator.dart'; // Add this dependency to your pubspec.yaml
import 'package:maseryshop/bottombar.dart';
import 'Base_Url/BaseUrl.dart';
import 'Home-pages/Featured-list-view.dart';
import 'home.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  ProductDetailsPage({required this.product});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late PageController _pageController;
  double _currentPage = 0.0;
  bool _isExpanded = false;
  bool isFavorite = false;
  List<dynamic> about = [];
  List<dynamic> recentProducts = [];
  int totalItems = 0;


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void addToCart(Map<String, String> productMap) {
    // Add to cart logic
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        '${ApiConfig.baseUrl}homescreen'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        about = jsonResponse['data']['about'];
        recentProducts = jsonResponse['data']['recent_products'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchTotalItems() async {
    try {
      final response = await http.get(Uri.parse(
          '${ApiConfig.baseUrl}totalitems'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          totalItems = int.parse(responseData['total_items'] ?? '0');
        });
      } else {
        throw Exception('Failed to load total items');
      }
    } catch (e) {
      print('Error fetching total items: $e');
      setState(() {
        totalItems = 0;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.product.title,
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2B2B),
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SizedBox(
                    height: 350.0,
                    width: screenWidth,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.product.imagePaths.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page.toDouble();
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        widget.product.imagePaths[index]),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              ],
            ),
            Center(
              child: DotsIndicator(
                dotsCount: widget.product.imagePaths.length,
                position: _currentPage,
                decorator: DotsDecorator(
                  color: Color(0xff0D6EFD),
                  activeColor: Color(0xffF87265),
                  size: Size.square(9.0),
                  activeSize: Size(18.0, 9.0),
                  spacing: EdgeInsets.symmetric(horizontal: 5.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              widget.product.title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              _isExpanded
                  ?  widget.product.description
                  : '${ widget.product.description.substring(0,  widget.product.description.length > 100 ? 100 :  widget.product.description.length)}...',
              style: GoogleFonts.montserrat(
                color: Color(0xff707B81),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if ( widget.product.description.length > 100)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded ? 'Read Less' : 'Read More',
                    style: GoogleFonts.montserrat(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    ' \$${widget.product.salePrice.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF6B7280),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    ' \$${widget.product.offerPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Map<String, String> productMap = {
                        'quantity': '1',
                        'shipTo': '1',
                        'shippingZoneId': '1',
                        'handling': '1'
                      };

                      Future<void> addToCart(
                          Map<String, String> product) async {
                        try {
                          final productSlug = widget.product.slug;
                          final url = Uri.parse(
                              '${ApiConfig.baseUrl}addToCart/$productSlug');

                          final response = await http.post(
                            url,
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(product),
                          );

                          // Log the status code and response body for debugging
                          print('Status Code: ${response.statusCode}');
                          print('Response Body: ${response.body}');

                          final responseBody = jsonDecode(response.body);

                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                  Text('Added $productSlug to cart')),
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
                                  content: Text(
                                      'Failed to add product to cart')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('An error occurred: $e')),
                          );
                        }
                      }

                      // Call the addToCart function once
                      await addToCart(productMap);
                    },
                    child: Text(
                      'Add to Cart',
                      style: GoogleFonts.montserrat(
                        color: Color(0xff0D6EFD),
                        fontSize: 17,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color(0xff0D6EFD)),
                      ),
                      minimumSize: Size(150, 50),
                    ),
                  ),
                  SizedBox(width: 15),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Navigator.push(
                  //     //   context,
                  //     //   MaterialPageRoute(
                  //     //     builder: (context) => MultistepForm(),
                  //     //   ),
                  //     // );
                  //   },
                  //   child: Text(
                  //     'Buy Now',
                  //     style: GoogleFonts.montserrat(color: Colors.white, fontSize: 17),
                  //   ),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Color(0xff0D6EFD),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     minimumSize: Size(150, 50),
                  //   ),
                  // ),
                ],
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {
        },
      ),

    );
  }
}
