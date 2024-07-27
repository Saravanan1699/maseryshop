import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../bottombar/bottombar.dart';
import 'order-details.dart';

class Order {
  final String orderId;
  final String orderNumber;
  final String quantity;
  final String total;
  final String itemcount;
  final String billingAddress;
  final String shippingAddress;
  final String paymentMethodId;
  final List<dynamic> inventories;

  Order({
    required this.orderId,
    required this.orderNumber,
    required this.quantity,
    required this.total,
    required this.itemcount,
    required this.billingAddress,
    required this.shippingAddress,
    required this.paymentMethodId,
    required this.inventories,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['id'].toString(),
      orderNumber: json['order_number'],
      quantity: json['quantity'] ?? '0',
      total: json['total'] ?? '0.00',
      itemcount: json['item_count'] ?? '0.00',
      billingAddress: json['billing_address'] ?? '',
      shippingAddress: json['shipping_address'] ?? '',
      paymentMethodId: json['payment_method_id'] ?? '',
      inventories: json['inventories'] ?? [],
    );
  }
}

class Orderlist extends StatefulWidget {
  const Orderlist({super.key});

  @override
  State<Orderlist> createState() => _OrderlistState();
}

class _OrderlistState extends State<Orderlist> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();
  }

  Future<String?> _getIdFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    return id;
  }

  Future<String?> _getTokenFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Order>> fetchOrders() async {
    final id = await _getIdFromLocalStorage();
    if (id == null) {
      throw Exception('User ID not found in local storage');
    }

    final token = await _getTokenFromLocalStorage();
    final response = await http.get(
      Uri.parse(
          'https://sgitjobs.com/MaseryShoppingNew/public/api/orders/customer/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> ordersList = data['data'] ?? [];
      return ordersList.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Order History',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/logo.png'),
            backgroundColor: Color(0xffF2F2F2),
          ),
        ),
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Center(
              child: LoadingAnimationWidget.halfTriangleDot(
                size: 50.0,
                color: Colors.redAccent,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Orders Found'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetails(order: order),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Order Id -',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ), Text(
                                  ' ${order.orderNumber}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[400]
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Quantity: ${order.itemcount}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Total: \$${(double.tryParse(order.total ?? '0.00')?.toStringAsFixed(2) ?? '0.00')}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                              ),
                            ),

                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomBar(
        onTap: (index) {},
      ),
    );
  }
}
