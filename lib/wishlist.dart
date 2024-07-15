import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';

import 'bottombar.dart';
import 'home.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({Key? key}) : super(key: key);

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  List<dynamic> favoriteProducts = []; // Initialize your list
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWishlistData();
  }

  Future<void> _fetchWishlistData() async {
    final url = Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/getwishlist');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          favoriteProducts = data['wishlist']['data'];
          isLoading = false; // Update loading state
        });
      } else {
        throw Exception('Failed to load wishlist');
      }
    } catch (e) {
      print('Error fetching wishlist: $e');
      // Handle error state if needed
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> _removeFromWishlist(int productId) async {
    print('Removing product with ID: $productId'); // Print ID to terminal

    final url = Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/removefromWishlist/$productId');
    final headers = {
      // Add headers if required (e.g., Authorization)
      // 'Authorization': 'Bearer your_access_token',
      'Content-Type': 'application/json', // Set the content type to JSON
    };
    final body = jsonEncode({'product_id': productId});

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          favoriteProducts.removeWhere((product) => product['id'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Item removed from wishlist'),
          duration: Duration(seconds: 2),
        ));
      }else if (response.statusCode == 404) {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseBody['error']),
          duration: Duration(seconds: 2),
        ));
      }  else {
        throw Exception('Failed to remove from wishlist: ${response.statusCode}');
      }
    } catch (e) {
      print('Error removing from wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to remove item from wishlist'),
        duration: Duration(seconds: 2),
      ));
      // Handle error if needed
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text('Favorite'),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.favorite_border_outlined),
            ),
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
          : favoriteProducts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/wishlist-empty.png',
              height: 150,
              width: 250,
            ),
            SizedBox(height: 5),
            Text(
              'Your Wishlist is empty!',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Seems like you don\'t have wishes here.',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
              ),
            ),Text(
              'Make a wish!',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Text(
                'Start shopping',
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0D6EFD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = favoriteProducts[index]['inventory'];
          final productId = favoriteProducts[index]['id'];

          // Check if product['image'] is valid
          final imageUrl = product['image'] ?? ''; // Default to empty string if null

          return Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Card(
              elevation: 4,
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: screenWidth * 0.3,
                            height: screenHeight * 0.15,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            'assets/no-data.png',
                            height: 200,
                            width: 150,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _removeFromWishlist(productId); // Assuming 'id' is the key for the product ID
                          },
                          icon: Icon(Icons.delete),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Column(
                    children: [
                      Text(
                        product['title'] ?? '',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${product['sale_price']}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {
          // Handle bottom bar tap if necessary
        },
        favoriteProducts: [],
      ),
    );
  }
}
