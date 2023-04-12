import 'dart:convert';

import 'package:flutter_dialogflow/screens/home_screen.dart';
import 'package:flutter_dialogflow/screens/password_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/screens/signin_screen.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _lastnameTextController = TextEditingController();
  final TextEditingController _firstnameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  bool _isLastNameValid = false;
  bool _isFirstNameValid = false;
  bool _isEmailValid = false;
  bool _isLoading = false;

  void _onLastNameChanged() {
    setState(() {
      _isLastNameValid = _lastnameTextController.text.isNotEmpty;
    });
  }

  void _onFirstNameChanged() {
    setState(() {
      _isFirstNameValid = _firstnameTextController.text.isNotEmpty;
    });
  }

  void _onEmailChanged() {
    setState(() {
      _isEmailValid = _emailTextController.text.isNotEmpty;
    });
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': _emailTextController.text,
      }),
    );

    print(response.body);
    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PasswordScreen(email: _emailTextController.text)),
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 30),

                Text(
                  'Créer',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                SizedBox(height: 20), // Ajoute un espace vertical de 20 pixels
                Text(
                  'votre compte',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),

                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FBFC),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _lastnameTextController,
                    onChanged: (_) => _onLastNameChanged(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Nom',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FBFC),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _firstnameTextController,
                    onChanged: (_) => _onFirstNameChanged(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Prenom',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FBFC),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _emailTextController,
                    onChanged: (_) => _onEmailChanged(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Email',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity, // Set the width to infinity
                  child: ElevatedButton(
                    onPressed: _isFirstNameValid && _isEmailValid && _isLastNameValid && !_isLoading ? _signIn : null,
                    child: Text("S’identifier"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00CDBD), // Set the background color of the button
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous avez un compte déjà? ",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PasswordScreen(email: _emailTextController.text)),
                        );
                      },
                      child: Text(
                        "Se connecter",
                        style: TextStyle(
                          color: Color(0xFF048177),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
