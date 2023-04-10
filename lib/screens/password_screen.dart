import 'dart:convert';

import 'package:flutter_dialogflow/screens/home_screen.dart';
import 'package:flutter_dialogflow/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../reusable_widgets/reusable_widget.dart';

class PasswordScreen extends StatefulWidget {
  final String email;

  const PasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController = TextEditingController();
  bool _isPasswordValid = false;
  bool _isLoading = false;
  bool _doPasswordsMatch = false;

  void _onPasswordChanged() {
    setState(() {
      _isPasswordValid = _passwordTextController.text.isNotEmpty;
    });
  }
  void _onConfirmPasswordChanged() {
    setState(() {
      _doPasswordsMatch = _confirmPasswordTextController.text == _passwordTextController.text;
    });
  }
  Future<void> _savePassword() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/auth/password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email, 'password': _passwordTextController.text}),
    );

    print(response.body);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password saved successfully.')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(email: widget.email)),
    );
      } else {
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
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FBFC),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: _confirmPasswordTextController,
                    onChanged: (_) => _onConfirmPasswordChanged(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Confirmer',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity, // Set the width to infinity
                  child: ElevatedButton(
                    onPressed: _isPasswordValid && _doPasswordsMatch && !_isLoading ? _savePassword : null,
                    child: _isLoading ? CircularProgressIndicator() : Text('Save Password'),
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
