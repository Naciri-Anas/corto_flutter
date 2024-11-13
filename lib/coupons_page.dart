import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CouponPage extends StatelessWidget {
  final List<Map<String, dynamic>> coupons;

  CouponPage({required this.coupons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Available Coupons', style: GoogleFonts.roboto(fontSize: 22)),
        backgroundColor: Colors.blue[900],
      ),
      body: ListView.builder(
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                coupon['code'],
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    coupon['description'],
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Discount: ${coupon['discount']}',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
