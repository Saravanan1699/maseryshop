import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:maseryshop/Responsive/responsive.dart';
import '../Base_Url/BaseUrl.dart';
import '../Home-pages/wishlist.dart';
import '../Product-pages/recent_product.dart';
import '../bottombar/bottombar.dart';
import '../Home-pages/home.dart';

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
  bool _hasSearched = false;
  int totalWishItems = 0;
  bool isInWishlist = false; // Declare isInWishlist here

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchData();
    final wishlists = widget.product['wishlists'] as List? ?? [];
    isInWishlist = wishlists.isNotEmpty;
    fetchTotalItems();
    fetchTotalWishlistItems();
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}homescreen'));

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

  Future<int> fetchTotalWishlistItems() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}totalwishlistitems'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['total_items'] ?? 0;
      } else {
        throw Exception('Failed to load total items');
      }
    } catch (e) {
      print('Error fetching total items: $e');
      return 0;
    }
  }

  Future<void> fetchTotalItems() async {
    try {
      final response =
      await http.get(Uri.parse('${ApiConfig.baseUrl}totalitems'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData');
        int items = await fetchTotalWishlistItems();
        setState(() {
          totalWishItems = items;
          totalItems = responseData['total_items'] ?? 0;
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


  void toggleWishlist(
      String slug, int? productId, bool currentWishlistStatus) async {
    bool newWishlistStatus = !currentWishlistStatus;
    try {
      final apiUrl = newWishlistStatus
          ? '${ApiConfig.baseUrl}addToWishlist/$slug'
          : '${ApiConfig.baseUrl}removefromWishlist/${productId ?? ''}';
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        await fetchData(); // Ensure fetchData() is defined and implemented correctly
        int items = await fetchTotalWishlistItems();

        if (mounted) {
          setState(() {
            totalWishItems = items;
            isInWishlist = newWishlistStatus; // Update isInWishlist here
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newWishlistStatus
                ? 'Added to wishlist'
                : 'Removed from wishlist'),
          ),
        );
      } else {
        throw Exception(
            'Failed to ${newWishlistStatus ? 'add to' : 'remove from'} wishlist');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final product = widget.product;
    final screenWidth = MediaQuery.of(context).size.width;

    final offerStartStr = product['offer_start'];
    final offerEndStr = product['offer_end'];
    final salePriceStr = product['sale_price'];
    final offerPriceStr = product['offer_price'];

    if (offerStartStr == null ||
        offerEndStr == null ||
        salePriceStr == null ||
        offerPriceStr == null) {
      return SizedBox.shrink();
    }

    final offerStart = DateTime.parse(offerStartStr);
    final offerEnd = DateTime.parse(offerEndStr);
    final currentDate = DateTime.now();

    final salePrice = double.parse(salePriceStr);
    final offerPrice = double.parse(offerPriceStr);
    final double discountPercentage =
        ((salePrice - offerPrice) / salePrice) * 100;
    final int discountPercentageRounded = discountPercentage.ceil();

    final slug = product['slug'];
    final productId = (product['wishlists'] as List?)?.isNotEmpty == true
        ? (product['wishlists'] as List)[0]['id']
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          product['title'],
          style: GoogleFonts.montserrat(),
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
                  size: responsive.textSize(3),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Wishlist()),
              );
            },
            child: Stack(
              children: [
                Icon(Icons.favorite_border),
                if (totalWishItems > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Center(
                        child: Text(
                          '$totalWishItems',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.textSize(1.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: responsive.widthPercentage(2)),

        ],
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
                        fontSize: responsive.textSize(3.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: responsive.paddingPercentage(5, 0, 0, 0),
                    child: Row(
                      children: [
                        Text(
                          '${(product['sku'])}  In Stock',
                          style: GoogleFonts.inter(
                            fontSize: responsive.textSize(3),
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0FBC00),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          height: responsive.heightPercentage(40),
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
                                    padding: responsive.paddingPercentage(
                                        2, 2, 2, 2),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '${imageurl.baseUrl}${product['product']['image'][index]['path']}'),
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
                      Positioned(
                        top: 0,
                        right: 25,
                        child: GestureDetector(
                          onTap: () {
                            if (slug != null) {
                              toggleWishlist(slug, productId, isInWishlist);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Product ID is missing'),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: isInWishlist ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      )
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
                  SizedBox(height: responsive.heightPercentage(3)),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '\$${(product['sale_price'] != null) ? double.parse(product['sale_price']).toStringAsFixed(2) : ''}',
                          style: GoogleFonts.montserrat(
                            fontSize: responsive.textSize(3),
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF6B7280),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '\$${(product['offer_price'] != null) ? double.parse(product['offer_price']).toStringAsFixed(2) : ''}',
                          style: GoogleFonts.montserrat(
                            fontSize: responsive.textSize(3),
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B2B2B),
                          ),
                        ),
                        SizedBox(width: 10),
                        if (discountPercentageRounded >
                            0) // Show discount percentage if greater than 0
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${discountPercentageRounded}% OFF',
                              style: GoogleFonts.montserrat(
                                fontSize: responsive.textSize(1.5),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                        fontSize: responsive.textSize(2.5),
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
                  SizedBox(height: responsive.heightPercentage(1)),
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
                              fontSize: responsive.textSize(3),
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
                  // SizedBox(height: screenHeight * 0.02),
                  Divider(
                    height: 2.0,
                    thickness: 1.0,
                  ),
                  Container(
                    height: responsive.heightPercentage(28),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: about.length,
                      itemBuilder: (context, index) {
                        final category = about[index];
                        final imageUrl =
                            '${imageurl.baseUrl}${category['path']}';
                        return Padding(
                          padding: responsive.paddingPercentage(2, 2, 2, 2),
                          child: Container(
                            width: responsive.widthPercentage(50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: responsive.heightPercentage(1),
                                ),
                                Container(
                                  height: responsive.heightPercentage(7),
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
                                      fontSize: responsive.textSize(2.5),
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
                                        fontSize: responsive.textSize(2),
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
                    height: responsive.heightPercentage(1),
                    thickness: 1.0,
                  ),
                  SizedBox(height: responsive.heightPercentage(1)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Recent Products',
                              style: GoogleFonts.montserrat(
                                fontSize: responsive.textSize(3.5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'See All',
                              style: GoogleFonts.montserrat(
                                  fontSize: responsive.textSize(3),
                                  fontWeight: FontWeight.bold),
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
                                          builder: (context) =>
                                              RecentProducts()),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward,
                                    size: responsive.textSize(3),
                                    color: Colors.white,
                                  ),
                                ))
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: responsive.heightPercentage(35),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recentProducts.length,
                            itemBuilder: (context, index) {
                              final product = recentProducts[index];
                              final imagePath =
                                  product['product']?['image']?[0]?['path'];
                              final imageUrl = imagePath != null
                                  ? '${imageurl.baseUrl}$imagePath'
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

                              String formattedSalePrice =
                                  salePrice.toStringAsFixed(2);
                              String formattedOfferPrice =
                                  offerPrice.toStringAsFixed(2);

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
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  height: responsive
                                                      .heightPercentage(20),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .vertical(
                                                      top:
                                                          Radius.circular(15.0),
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          imageUrl),
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    product['title'] ??
                                                        'No title',
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: responsive
                                                          .textSize(2.5),
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
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
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              fontSize:
                                                                  responsive
                                                                      .textSize(
                                                                          2.5),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: responsive
                                                                .widthPercentage(
                                                                    2.5),
                                                          ),
                                                          Text(
                                                            '\$$formattedOfferPrice',
                                                            style: GoogleFonts
                                                                .montserrat(
                                                              fontSize:
                                                                  responsive
                                                                      .textSize(
                                                                          2.5),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ] else ...[
                                                      Text(
                                                        '\$$formattedSalePrice',
                                                        style: GoogleFonts
                                                            .montserrat(
                                                          fontSize: responsive
                                                              .textSize(2.5),
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
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    'OFF',
                                                    style:
                                                        GoogleFonts.montserrat(
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
      bottomNavigationBar: BottomBar(
        onTap: (index) {},
      ),
    );
  }
}
