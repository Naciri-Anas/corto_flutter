import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart'; // Import login page
import 'email_detail_page.dart';

class InboxPage extends StatefulWidget {
  final String accessToken;

  InboxPage({required this.accessToken});

  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  List<dynamic> emails = [];
  bool isLoading = true;

  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Initialize GoogleSignIn

  @override
  void initState() {
    super.initState();
    fetchEmails();
  }

  Future<void> fetchEmails() async {
    try {
      final DateTime currentDate = DateTime.now();
      final DateTime fiveDaysAgo = currentDate.subtract(Duration(days: 15));
      final String formattedDate = DateFormat("yyyy/MM/dd").format(fiveDaysAgo);

      final response = await http.get(
        Uri.parse(
            'https://www.googleapis.com/gmail/v1/users/me/messages?q=after:$formattedDate'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List messages = data['messages'] ?? [];

        List<dynamic> fetchedEmails = [];
        for (var message in messages) {
          var emailResponse = await http.get(
            Uri.parse(
                'https://www.googleapis.com/gmail/v1/users/me/messages/${message['id']}'),
            headers: {
              'Authorization': 'Bearer ${widget.accessToken}',
            },
          );

          if (emailResponse.statusCode == 200) {
            var emailData = json.decode(emailResponse.body);
            fetchedEmails.add(emailData);
          }
        }

        setState(() {
          emails = fetchedEmails;
          isLoading = false;
        });
      } else {
        print('Failed to load emails: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Sign-out method
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      await _googleSignIn.signOut(); // Sign out from Google

      // After signing out, navigate back to the Login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Sign-out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: Text(
          'Inbox',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[900], // Deep blue AppBar
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut, // Call the sign-out method when pressed
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: emails.length,
              itemBuilder: (context, index) {
                var email = emails[index];
                var headers = email['payload']['headers'];
                var subject = headers.firstWhere(
                    (header) => header['name'] == 'Subject')['value'];
                var from = headers
                    .firstWhere((header) => header['name'] == 'From')['value'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailDetailPage(
                          email: email,
                          subject: subject,
                          from: from,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16), // Padding for content
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.blue[900], // Deep blue background for avatar
                        child: Text(
                          from[0]
                              .toUpperCase(), // Initial letter of sender's name
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        subject,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900], // Deep blue text
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        from,
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
