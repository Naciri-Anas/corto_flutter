import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailDetailPage extends StatelessWidget {
  final dynamic email;
  final String subject;
  final String from;

  EmailDetailPage(
      {required this.email, required this.subject, required this.from});

  @override
  Widget build(BuildContext context) {
    var headers = email['payload']['headers'];
    var body = email['snippet']; // This is just a simplified body content

    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: Text(
          'Email Details',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.blue[900], // Dark blue AppBar
        elevation: 4,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8, // Shadow effect
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender information
                Text(
                  'From: $from',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue[900], // Dark blue text
                  ),
                ),
                SizedBox(height: 12),
                // Subject
                Text(
                  'Subject: $subject',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blue[900], // Dark blue text
                  ),
                ),
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                  height: 32,
                ),
                SizedBox(height: 10),
                // Body content (snippet for now)
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      body,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
