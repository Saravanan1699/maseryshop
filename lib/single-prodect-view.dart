import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'Home-pages/recent_product.dart';
import 'home.dart';

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetail({required this.product});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late PageController _pageController;
  double _currentPage = 0;
  bool isFavorite = false;
  bool _isExpanded = false;
  List<dynamic> about = [];
  List<dynamic> recentProducts = [];
  int totalItems = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchData();
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
        'https://sgitjobs.com/MaseryShoppingNew/public/api/homescreen'));

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
          'https://sgitjobs.com/MaseryShoppingNew/public/api/totalitems'));
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
  Widget build(BuildContext context) {
    final product = widget.product;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          product['title'],
          style: GoogleFonts.montserrat(),
        ),
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //       // Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage(cart: [],)));
        //     },
        //     child: Stack(
        //       children: [
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: CircleAvatar(
        //             child: Icon(
        //               Icons.shopping_bag,
        //               size: 18.0,
        //               color: Colors.white,
        //             ),
        //             backgroundColor: Colors.blue,
        //           ),
        //         ),
        //         if (totalItems > 0)
        //           Positioned(
        //             right: 4,
        //             top: 20,
        //             child: CircleAvatar(
        //               radius: 8,
        //               backgroundColor: Colors.red,
        //               child: Text(
        //                 '$totalItems',
        //                 style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white),
        //               ),
        //             ),
        //           ),
        //       ],
        //     ),
        //   ),
        // ],
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
      body: product == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      product['title'],
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      '${(product['sku'])}  In Stock',
                      style: GoogleFonts.inter(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0FBC00),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          height: 350,
                          width: screenWidth,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: product['product']['image'].length,
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
                                              'https://sgitjobs.com/MaseryShoppingNew/public/${product['product']['image'][index]['path']}'),
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
                      dotsCount: product['product']['image'].length,
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
                  SizedBox(height: screenHeight * 0.02),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '\$${(product['sale_price'] != null) ? double.parse(product['sale_price']).toStringAsFixed(2) : ''}',
                          style: GoogleFonts.montserrat(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF6B7280),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '\$${(product['offer_price'] != null) ? double.parse(product['offer_price']).toStringAsFixed(2) : ''}',
                          style: GoogleFonts.montserrat(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B2B2B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      _isExpanded
                          ? product['description']
                          : '${product['description'].substring(0, product['description'].length > 100 ? 100 : product['description'].length)}...',
                      style: GoogleFonts.montserrat(
                        color: Color(0xff707B81),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (product['description'].length > 100)
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
                  SizedBox(height: screenHeight * 0.01),
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
                                final productSlug = widget.product['slug'];
                                final url = Uri.parse(
                                    'https://sgitjobs.com/MaseryShoppingNew/public/api/addToCart/$productSlug');

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
                  SizedBox(height: screenHeight * 0.02),
                  Divider(
                    height: 2.0,
                    thickness: 1.0,
                  ),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: about.length,
                      itemBuilder: (context, index) {
                        final category = about[index];
                        final imageUrl =
                            'https://sgitjobs.com/MaseryShoppingNew/public/${category['path']}';
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15.0),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    category['title'] ??
                                        '', // Display category title
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Center(
                                    child: Text(
                                      category['description'] ??
                                          '', // Display category description
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(
                    height: 2.0,
                    thickness: 1.0,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                 Padding(
                   padding: const EdgeInsets.only(left: 8.0),
                   child: Column(
                     children: [
                       Row(
                         children: [
                           Text(
                             'Recent Products',
                             style: GoogleFonts.montserrat(
                               fontSize: 20,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           Spacer(),
                           Text(
                             'See All',
                             style: GoogleFonts.montserrat(
                                 fontSize: 17, fontWeight: FontWeight.bold),
                           ),
                           SizedBox(
                             width: 10,
                           ),
                           Container(
                               height: 35,
                               decoration: const BoxDecoration(
                                 color: Colors.blue,
                                 shape: BoxShape.circle,
                               ),
                               child: IconButton(
                                 onPressed: () {
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                         builder: (context) => GraphicsCard1()),
                                   );
                                 },
                                 icon: Icon(
                                   Icons.arrow_forward,
                                   size: 20,
                                   color: Colors.white,
                                 ),
                               ))
                         ],
                       ),
                       SizedBox(height: 16),
                       Container(
                         height: 260,
                         child: ListView.builder(
                           scrollDirection: Axis.horizontal,
                           itemCount: recentProducts.length,
                           itemBuilder: (context, index) {
                             final product = recentProducts[index];
                             final imagePath =
                             product['product']?['image']?[0]?['path'];
                             final imageUrl = imagePath != null
                                 ? 'https://sgitjobs.com/MaseryShoppingNew/public/$imagePath'
                                 : 'https://example.com/placeholder.png'; // Placeholder image URL

                             final offerStartStr = product['offer_start'];
                             final offerEndStr = product['offer_end'];
                             final salePriceStr = product['sale_price'];
                             final offerPriceStr = product['offer_price'];

                             if (offerStartStr == null ||
                                 offerEndStr == null ||
                                 salePriceStr == null ||
                                 offerPriceStr == null) {
                               // Skip this item if critical data is missing
                               return SizedBox.shrink();
                             }

                             final offerStart = DateTime.parse(offerStartStr);
                             final offerEnd = DateTime.parse(offerEndStr);
                             final currentDate = DateTime.now();

                             final bool isOfferPeriod =
                                 currentDate.isAfter(offerStart) &&
                                     currentDate.isBefore(offerEnd);
                             final salePrice = double.parse(salePriceStr);
                             final offerPrice = double.parse(offerPriceStr);

                             String formattedSalePrice = salePrice.toStringAsFixed(2);
                             String formattedOfferPrice = offerPrice.toStringAsFixed(2);


                             final double discountPercentage =
                                 ((salePrice - offerPrice) / salePrice) * 100;
                             final int discountPercentageRounded =
                             discountPercentage.ceil();

                             return GestureDetector(
                               onTap: () {
                                 Navigator.push(
                                   context,
                                   MaterialPageRoute(
                                     builder: (context) =>
                                         ProductDetail(product: product),
                                   ),
                                 );
                               },
                               child: Padding(
                                 padding: const EdgeInsets.all(8.0),
                                 child: Container(
                                   width: 200,
                                   child: Stack(
                                     children: [
                                       Card(
                                         color: Colors.white,
                                         elevation: 4,
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(15.0),
                                         ),
                                         child: Column(
                                           crossAxisAlignment:
                                           CrossAxisAlignment.start,
                                           children: [
                                             Padding(
                                               padding: const EdgeInsets.all(8.0),
                                               child: Container(
                                                 height: 150,
                                                 decoration: BoxDecoration(
                                                   borderRadius:
                                                   const BorderRadius.vertical(
                                                     top: Radius.circular(15.0),
                                                   ),
                                                   image: DecorationImage(
                                                     image: NetworkImage(imageUrl),
                                                     fit: BoxFit.contain,
                                                   ),
                                                 ),
                                               ),
                                             ),
                                             Padding(
                                                 padding:
                                                 const EdgeInsets.all(8.0),
                                                 child: Text(
                                                   product['title'] ?? 'No title',
                                                   style: GoogleFonts.montserrat(
                                                     fontSize: 11,
                                                     fontWeight: FontWeight.normal,
                                                   ),
                                                   maxLines: 1,
                                                   overflow: TextOverflow.ellipsis,
                                                 )

                                             ),
                                             Padding(
                                               padding:
                                               const EdgeInsets.symmetric(
                                                   horizontal: 8.0),
                                               child: Column(
                                                 crossAxisAlignment:
                                                 CrossAxisAlignment.start,
                                                 children: [
                                                   if (isOfferPeriod) ...[
                                                     Row(
                                                       children: [
                                                         Text(
                                                           '\$$formattedSalePrice',
                                                           style:
                                                           GoogleFonts.montserrat(
                                                             fontSize: 15,
                                                             fontWeight:
                                                             FontWeight
                                                                 .normal,
                                                             decoration:
                                                             TextDecoration
                                                                 .lineThrough,
                                                           ),
                                                         ),
                                                         SizedBox(
                                                           width: 10,
                                                         ),
                                                         Text(
                                                           '\$$formattedOfferPrice',
                                                           style:
                                                           GoogleFonts.montserrat(
                                                             fontSize: 15,
                                                             fontWeight:
                                                             FontWeight.bold,
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                   ] else ...[
                                                     Text(
                                                       '\$$formattedSalePrice',
                                                       style:  GoogleFonts.montserrat(
                                                         fontSize: 15,
                                                         fontWeight:
                                                         FontWeight.bold,
                                                       ),
                                                     ),
                                                   ],
                                                 ],
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                       if (isOfferPeriod)
                                         Positioned(
                                           top: 0,
                                           left: 0,
                                           child: Container(
                                             height: 40,
                                             width: 40,
                                             decoration: BoxDecoration(
                                               color: Colors.orangeAccent,
                                               borderRadius:
                                               BorderRadius.circular(30.0),
                                             ),
                                             padding:
                                             const EdgeInsets.all(4.0),
                                             child: Column(
                                               mainAxisAlignment:
                                               MainAxisAlignment.center,
                                               children: [
                                                 Text(
                                                   '$discountPercentageRounded%',
                                                   style:  GoogleFonts.montserrat(
                                                     fontSize: 12,
                                                     fontWeight:
                                                     FontWeight.bold,
                                                     color: Colors.white,
                                                   ),
                                                 ),
                                                 Text(
                                                   'OFF',
                                                   style:  GoogleFonts.montserrat(
                                                     fontSize: 9,
                                                     fontWeight:
                                                     FontWeight.bold,
                                                     color: Colors.white,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         ),
                                     ],
                                   ),
                                 ),
                               ),
                             );
                           },
                         ),
                       )
                     ],
                   ),
                 )
                ],
              ),
            ),
    );
  }
}
