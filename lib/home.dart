  import 'dart:async';
  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:lottie/lottie.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:http/http.dart' as http;
  import 'package:speech_to_text/speech_to_text.dart' as stt;
  import 'package:permission_handler/permission_handler.dart';
  import 'package:url_launcher/url_launcher.dart';
  import 'inbox_page.dart';
  import 'coupons_page.dart';
  import 'available_coupons.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:flutter_tts/flutter_tts.dart';






  class Message {
    final String text;
    final bool isUser;
    final DateTime timestamp;
    final String? link;


    Message({required this.text, required this.isUser, required this.timestamp,this.link});
  }



  class HomePage extends StatefulWidget {

    @override

    _HomePageState createState() => _HomePageState();

  }

  class _HomePageState extends State<HomePage> {


    FlutterTts _flutterTts = FlutterTts();


    final TextEditingController _messageController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    final List<Message> _messages = [];
    late stt.SpeechToText _speech;
    bool _isListening = false;
    String _recognizedText = "";
    bool _isSendingEmailLogs = false;

    @override
    void initState() {
      super.initState();
      _flutterTts = FlutterTts();
      _speech = stt.SpeechToText();
      _requestMicrophonePermission();
      _sendEmailLogs();
      _addInitialMessage();
      _loadChatHistory();
      _speech = stt.SpeechToText();
    }
    void _speak(String text) async {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);  // Set pitch if needed
      await _flutterTts.speak(text);
    }


    void _addInitialMessage() {
      setState(() {
        _messages.add(Message(
          text: "Hello! I'm Corto. You can:\n\n"
              "1. Search for coupons and deals\n"
              "2. Use voice commands\n\n"
              "How can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }

    @override
    void dispose() {
      _messageController.dispose();
      _scrollController.dispose();
      _speech.stop();
      _flutterTts.stop();
      super.dispose();
    }

    Future<void> _requestMicrophonePermission() async {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('Microphone permission denied');
      }
    }

    Future<void> _sendEmailLogs() async {
      try {
        setState(() {
          _isSendingEmailLogs = true;
        });

        // Simulate fetching email logs (replace this with actual data if needed)
        List<Map<String, String>> emailLogs = [
          {
            "email": "example@example.com",
            "subject": "Sample Subject",
            "text": "Sample email content",
          }
        ];

        // Send the email logs to the API
        final apiResponse = await http.post(
          Uri.parse('http://34.229.20.191:8007/extract_coupons/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(emailLogs),
        );

        if (apiResponse.statusCode == 200) {
          print('Email logs sent successfully.');
        } else {
          print('Failed to send email logs: ${apiResponse.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch coupons. Please try again.')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isSendingEmailLogs = false;
        });
      }
    }

    void _listen(BuildContext context) async {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) {
            print('onStatus: $val');
            if (val == 'done') {
              _stopListening();
            }
          },
          onError: (val) {
            print('onError: $val');
            _stopListening();
          },
        );

        if (available) {
          setState(() {
            _isListening = true;
            _recognizedText = "Listening...";
          });

          _speech.listen(
            onResult: (val) async {
              setState(() {
                _recognizedText = val.recognizedWords;
              });

              if (val.finalResult) {
                setState(() {
                  _messages.add(Message(
                    text: val.recognizedWords,
                    isUser: true,
                    timestamp: DateTime.now(),
                  ));
                });
                _scrollToBottom();

                String response = await _processUserMessage(val.recognizedWords);
                setState(() {
                  _messages.add(Message(
                    text: response,
                    isUser: false,
                    timestamp: DateTime.now(),
                  ));
                });
                _scrollToBottom();

                String voiceInput = val.recognizedWords.toLowerCase();
                if (voiceInput.contains('coupon') ||
                    voiceInput.contains('deal')) {
                  await _sendEmailLogs();
                }

                for (String keyword in _getKeywords()) {
                  if (voiceInput.contains(keyword.toLowerCase())) {
                    _handleKeywordMatch(keyword);
                    break;
                  }
                }
              }
            },
            listenFor: Duration(seconds: 30),
            pauseFor: Duration(seconds: 3),
            partialResults: true,
            listenMode: stt.ListenMode.confirmation,
          );
        } else {
          print("Speech recognition unavailable");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition is not available on this device.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    List<String> _getKeywords() {
      return [
        "food", "car", "bike", "soup", "watch", "bike", "restaurant", "travel",
        "music", "movie", "shopping", "coffee", "hotel", "flight", "weather"
        // Add more keywords as needed
      ];
    }

    void _handleKeywordMatch(String keyword) async {
      setState(() {
        _messages.add(Message(
          text: "Searching for deals related to $keyword...",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();

      try {
        final response = await http.post(
          Uri.parse('http://34.229.20.191:8007/scrape_slickdeals_only_key_word')
              .replace(queryParameters: {
            'url': keyword,
            'save_to_file': 'false',
          }),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode("string"),
        );

        if (response.statusCode == 200) {
          final dealsData = json.decode(response.body)['data'];

          // Display each deal in the chat
          for (var deal in dealsData) {
            setState(() {
              _messages.add(Message(
                text: "Title: ${deal['Deal Title']}\n"
                    "Current Price: ${deal['Price']}\n"
                    "Original Price: ${deal['Old Price']}\n",


                isUser: false,
                timestamp: DateTime.now(),
                link: deal['Deal URL'],
              ));
            });
            _scrollToBottom();


          }
        } else {
          _showErrorMessage('Failed to fetch deals. Please try again.');
        }
      } catch (e) {
        _showErrorMessage('An error occurred. Please try again.');
      }
    }

    void _showErrorMessage(String message) {
      setState(() {
        _messages.add(Message(
          text: message,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }

    void _stopListening() {
      _speech.stop();
      setState(() {
        _isListening = false;
        _recognizedText = "";
      });
    }

    void _sendMessage() async {
      if (_messageController.text.trim().isEmpty) return;

      final userMessage = _messageController.text;
      setState(() {
        _messages.add(Message(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ));
        _messageController.clear();
      });
      _scrollToBottom();
      _saveChatHistory();

      String response = await _processUserMessage(userMessage);
      setState(() {
        _messages.add(Message(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
      _speak(response);
      _saveChatHistory();


      String textInput = userMessage.toLowerCase();
      if (textInput.contains('coupon') || textInput.contains('deal')) {
        await _sendEmailLogs();
      }

      for (String keyword in _getKeywords()) {
        if (textInput.contains(keyword.toLowerCase())) {
          _handleKeywordMatch(keyword);
          break;
        }
      }
    }

    Future<String> _processUserMessage(String message) async {
      message = message.toLowerCase();
      if (message.contains('coupon') || message.contains('deal')) {
        return "I'll search for available coupons and deals for you.";
      } else {
        for (String keyword in _getKeywords()) {
          if (message.contains(keyword.toLowerCase())) {
            return "Searching for deals related to $keyword...";
          }
        }
        return "I can help you search for coupons and deals. What would you like to do?";
      }
    }

    void _scrollToBottom() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Corto',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.blue[900],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.mic,
                        color: _isListening ? Colors.red : Colors.grey),
                    onPressed: () => _listen(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue[900]),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
            if (_isListening)
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _recognizedText.isEmpty
                            ? 'Listening...'
                            : _recognizedText,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: _stopListening,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    Widget _buildMessageBubble(Message message) {
      return Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: message.isUser ? Colors.blue[900] : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                ),
              ),
              if (message.link != null) ...[
                SizedBox(height: 8),
                InkWell(
                  onTap: () => _launchURL(message.link!),
                  child: Text(
                    "Visit Deal",
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }


    void _saveChatHistory() async {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = _messages.map((message) {
        return jsonEncode({
          'text': message.text,
          'isUser': message.isUser,
          'timestamp': message.timestamp.toIso8601String(),
          'link': message.link,
        });
      }).toList();
      await prefs.setStringList('chatHistory', history);
    }




    void _loadChatHistory() async {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('chatHistory') ?? [];
      setState(() {
        _messages.addAll(history.map((messageString) {
          final messageData = jsonDecode(messageString);
          return Message(
            text: messageData['text'],
            isUser: messageData['isUser'],
            timestamp: DateTime.parse(messageData['timestamp']),
            link: messageData['link'],
          );
        }).toList());
      });
    }

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


  }