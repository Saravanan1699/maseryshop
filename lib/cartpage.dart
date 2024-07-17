import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'Authentication/Sing-in.dart';
import 'Multiple_stepform/step_form.dart';
import 'home.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> carts = [];
  bool isLoading = true;

  Future<void> fetchData() async {
    try {
      final response = await http.get(
          Uri.parse('https://sgitjobs.com/MaseryShoppingNew/public/api/carts'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          if (data.isNotEmpty) {
            setState(() {
              carts = data.map((cart) {
                cart['inventories'] = cart['inventories'].map((inventory) {
                  inventory['quantity'] = inventory['quantity'] ?? 1;
                  return inventory;
                }).toList();
                return cart;
              }).toList();
            });
          }
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateCartItemQuantity(
      BuildContext context, int cartId, int itemId, int newQuantity) async {
    final String url =
        'https://sgitjobs.com/MaseryShoppingNew/public/api/cart/$cartId/update?item=$itemId&quantity=$newQuantity';

    try {
      final response = await http.put(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          carts.forEach((cart) {
            var inventory = cart['inventories']
                .firstWhere((inv) => inv['id'] == itemId, orElse: () => null);
            if (inventory != null) {
              inventory['quantity'] = newQuantity;
            }
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item quantity updated successfully',
            style: GoogleFonts.montserrat(),),
          ),
        );
      } else {
        print('Failed to update item quantity: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to update item quantity: ${response.statusCode}',
                style: GoogleFonts.montserrat(),),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $e',
          style: GoogleFonts.montserrat(),),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> removeItemFromCart(int cartId, int itemId) async {
    final String url =
        'https://sgitjobs.com/MaseryShoppingNew/public/api/cart/removeItem?cart=$cartId&item=$itemId';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Item removed successfully');
        await fetchData();
        setState(() {
          carts.forEach((cart) {
            cart['inventories']
                .removeWhere((inventory) => inventory['id'] == itemId);
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item removed successfully',
            style: GoogleFonts.montserrat(),),
          ),
        );
      } else {
        print('Failed to remove item: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove item: ${response.statusCode}',
              style: GoogleFonts.montserrat(),),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $e',
            style: GoogleFonts.montserrat(),),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null;
  }

  Future<void> loginUser() async {
    // Perform login logic (validate credentials, etc.)
    // Assuming login is successful, set isLoggedIn to true
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  Future<void> logoutUser() async {
    // Perform logout logic (clear sessions, etc.)
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('isLoggedIn');
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text('My Cart',
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
      body: Stack(
        children: [
          isLoading
              ? Center(
                  child: Container(
                    child: LoadingAnimationWidget.halfTriangleDot(
                      size: 50.0,
                      color: Colors.redAccent,
                    ),
                  ),
                )
              : carts.isEmpty
                  ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Column(
                    children: [
                      Image(image: AssetImage('assets/emptycart-masery.png',
                      ),height: 250,
                        width: 250,),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Your cart is empty',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w400
                      ),),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                      },
                        child: Text('Start shopping',
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff0D6EFD),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      )

                    ],
                  ),
                ],
              ))
                  : ListView.builder(
                      itemCount: carts.length,
                      itemBuilder: (BuildContext context, int index) {
                        final cart = carts[index];
                        final List<dynamic> inventories = cart['inventories'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: inventories.map((inventory) {
                            String imageUrl = inventory['product']['images']
                                    .isNotEmpty
                                ? 'https://sgitjobs.com/MaseryShoppingNew/public/${inventory['product']['images'][0]['path']}'
                                : 'assets/products/images/default_image.png';
                            double minPrice = double.tryParse(
                                    inventory['product']['min_price']) ??
                                0.0;
                            double unitPrice = double.tryParse(
                                    inventory['pivot']['unit_price']) ??
                                0.0;
                            int quantity = inventory['quantity'] ?? 1;
                            double totalPrice = unitPrice * quantity.toDouble();

                            return Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                color: Colors.white,
                                child: Container(
                                  width: 300,
                                  margin: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(15.0)),
                                            image: DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              inventory['product']['name'] ??
                                                  '',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 70,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () async {
                                                        if (quantity > 1) {
                                                          await updateCartItemQuantity(
                                                            context,
                                                            int.parse(inventory[
                                                                        'pivot']
                                                                    ['cart_id']
                                                                .toString()),
                                                            inventory['id'],
                                                            quantity - 1,
                                                          );
                                                          setState(() {
                                                            inventory[
                                                                    'quantity'] =
                                                                quantity - 1;
                                                          });
                                                        }
                                                      },
                                                      icon: Icon(Icons.remove,
                                                          color: Colors
                                                              .orangeAccent),
                                                    ),
                                                    Text(
                                                        inventory['quantity']
                                                            .toString(),
                                                        style: GoogleFonts.montserrat(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    IconButton(
                                                      onPressed: () async {
                                                        await updateCartItemQuantity(
                                                          context,
                                                          int.parse(inventory[
                                                                      'pivot']
                                                                  ['cart_id']
                                                              .toString()),
                                                          inventory['id'],
                                                          quantity + 1,
                                                        );
                                                        setState(() {
                                                          inventory[
                                                                  'quantity'] =
                                                              quantity + 1;
                                                        });
                                                      },
                                                      icon: Icon(Icons.add,
                                                          color: Colors
                                                              .orangeAccent),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(

                                            '\$${totalPrice.toStringAsFixed(2)}',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              print(
                                                  'Cart ID: ${inventory['pivot']['cart_id']}');
                                              print(
                                                  'Inventory ID: ${inventory['pivot']['inventory_id']}');
                                              int cartId = int.tryParse(
                                                      inventory['pivot']
                                                              ['cart_id']
                                                          .toString()) ??
                                                  0;
                                              int itemId = int.tryParse(
                                                      inventory['pivot']
                                                              ['inventory_id']
                                                          .toString()) ??
                                                  0;
                                              if (cartId > 0 && itemId > 0) {
                                                removeItemFromCart(
                                                    cartId, itemId);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Invalid cart or item ID',
                                                    style: GoogleFonts.montserrat(),),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                            icon: Icon(Icons.delete,
                                                color: Colors.orangeAccent),
                                          ),
                                          SizedBox(
                                            width: 30,
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),

                        );
                      },
                    ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white70,
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grand Total:',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${calculateGrandTotal().toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: carts.isEmpty
                        ? null // Disable button if no carts
                        : () async {
                            bool isLoggedIn = await _checkLoginStatus();
                            if (isLoggedIn) {
                              // If user is logged in, navigate to MultistepForm
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MultistepForm(product: {})),
                              );
                            } else {
                              // If user is not logged in, navigate to login screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Signin()),
                              );
                            }
                          },
                    child: Text(
                      'Checkout',
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 17),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          carts.isEmpty ? Colors.grey : Color(0xff0D6EFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double calculateGrandTotal() {
    double grandTotal = 0.0;
    for (var cart in carts) {
      for (var inventory in cart['inventories']) {
        int quantity = inventory['quantity'] ?? 1;
        grandTotal +=
            (double.tryParse(inventory['pivot']['unit_price']) ?? 0.0) *
                quantity;
      }
    }
    return grandTotal;
  }
}
