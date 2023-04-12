import 'dart:convert';

import 'package:flutter_dialogflow/screens/home_screen.dart';
import 'package:flutter_dialogflow/screens/password_screen.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SignInScreen extends StatefulWidget {
  final String email;
  const SignInScreen({Key? key,required this.email}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  
  
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isLoading = false;

 void _onEmailChanged() {
    setState(() {
      _isEmailValid = _emailTextController.text.isNotEmpty;
    });
  }

  void _onPasswordChanged() {
    setState(() {
      _isPasswordValid = _passwordTextController.text.isNotEmpty;
    });
  }

 

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/auth/authenticate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': _emailTextController.text,
        'password' : _passwordTextController.text
      }),
    );

    print(response.body);
    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(email: widget.email)),
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
                  'Se connecter',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                SizedBox(height: 20), // Ajoute un espace vertical de 20 pixels
                Text(
                  'à votre compte',
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
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FBFC),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _passwordTextController,
                    onChanged: (_) => _onPasswordChanged(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Mot de passe',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
               
                Container(
                  width: double.infinity, // Set the width to infinity
                  child: ElevatedButton(
                    onPressed: _isEmailValid && _isPasswordValid && !_isLoading ? _signIn : null,
                    child: Text("Se connecter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00CDBD), // Set the background color of the button
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
