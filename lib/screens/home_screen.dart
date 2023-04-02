import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dialogflow/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/screens/Messages.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:http/http.dart' as http;


class HomeScreen extends StatefulWidget {
  final String name;

  const HomeScreen({Key? key, required this.name}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
    getDataFromApi();
    super.initState();
  }

  Future<void> getDataFromApi() async {
  try {
    final response = await http.get(Uri.parse('$apiBaseUrl/auth/parcours/${widget.name}'));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final origin = responseData['origin'];
      final destination = responseData['destination'];
      print('Origin: $origin, Destination: $destination');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (error) {
    print('Error occurred: $error.');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tchatbot'),
      ),
      body: Column(
        children: [
          Expanded(child: MessagesScreen(messages: messages)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.deepPurple,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
          ElevatedButton(
            child: Text("Logout"),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  sendMessage(String text) async {
    if (text.isEmpty) {
      print('Message is empty');
    } else {
      setState(() {
        addMessage(Message(text: DialogText(text: [text])), true);
      });

      DetectIntentResponse response =
          await dialogFlowtter.detectIntent(queryInput: QueryInput(text: TextInput(text: text)));
      if (response.message == null) return;
      setState(() {
        addMessage(response.message!);
      });
    }
  }

  addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({'message': message, 'isUserMessage': isUserMessage});
  }
}
