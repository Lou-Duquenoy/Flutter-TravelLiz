import 'dart:convert';

import 'package:flutter_dialogflow/screens/home_screen.dart';
import 'package:flutter_dialogflow/screens/password_screen.dart';
import 'package:flutter_dialogflow/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../reusable_widgets/reusable_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _nameTextController = TextEditingController();
  

  bool _isNameValid = false;
  bool _isLoading = false;

  void _onNameChanged() {
    setState(() {
      _isNameValid = _nameTextController.text.isNotEmpty;
    });
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': _nameTextController.text}),
    );

    print(response.body);
    if (response.statusCode == 200) {
  try {
    final responseData = jsonDecode(response.body);
    if (responseData['status'] == 'success') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PasswordScreen(name: _nameTextController.text)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid name, please try again.')),
      );
    }
  } catch (e) {
    print('Error parsing JSON response: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error occurred, please try again.')),
    );
  }
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error occurred, please try again.')),
  );
}


    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [hexStringToColor("CB2B93"), hexStringToColor("9546C4"), hexStringToColor("5E61F4")],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 30),
                reusableTextField(
                  "Enter Name",
                  Icons.person_outline,
                  false,
                  _nameTextController,
                  onChanged: (_) => _onNameChanged(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isNameValid && !_isLoading ? _signIn : null,
                  child: _isLoading ? CircularProgressIndicator() : Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
