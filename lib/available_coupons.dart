import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AvailableDealsPage extends StatelessWidget {
  final List<dynamic> deals;

  AvailableDealsPage({required this.deals});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Optionally show a snackbar or alert dialog here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for a clean look
      appBar: AppBar(
        title: Text(
          'Available Deals',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue[900], // Dark blue AppBar background
        elevation: 4,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: deals.length,
        itemBuilder: (context, index) {
          final deal = deals[index];
          return Card(
            color: Colors.white,
            elevation: 8, // Shadow effect for the card
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Rounded corners
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deal title
                  Text(
                    deal['Deal Title'],
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900], // Dark blue text color
                    ),
                  ),
                  SizedBox(height: 12),
                  // Current price
                  Row(
                    children: [
                      Text(
                        'Current Price: ',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        deal['Price'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green, // Green for the current price
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Original price
                  Row(
                    children: [
                      Text(
                        'Original Price: ',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        deal['Old Price'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red, // Red for the original price
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Date posted
                  Text(
                    'Posted: ${deal['Date Posted']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600], // Grey color for date
                    ),
                  ),
                  SizedBox(height: 16),
                  // Visit Deal button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _launchURL(deal['Deal URL']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900], // Dark blue button
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Visit Deal',
                        style: GoogleFonts.poppins(
                          color: Colors.white, // White text on button
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
