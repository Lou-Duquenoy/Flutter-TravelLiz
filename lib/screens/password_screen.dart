import 'dart:convert';

import 'package:flutter_dialogflow/screens/home_screen.dart';
import 'package:flutter_dialogflow/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../reusable_widgets/reusable_widget.dart';

class PasswordScreen extends StatefulWidget {
  final String name;

  const PasswordScreen({Key? key, required this.name}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordTextController = TextEditingController();

  bool _isPasswordValid = false;
  bool _isLoading = false;

  void _onPasswordChanged() {
    setState(() {
      _isPasswordValid = _passwordTextController.text.isNotEmpty;
    });
  }

  Future<void> _savePassword() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': widget.name, 'password': _passwordTextController.text}),
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
          MaterialPageRoute(builder: (context) => HomeScreen(name: widget.name)),
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
                Text('Welcome, ${widget.name}'),
                const SizedBox(height: 20),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                  onChanged: (_) => _onPasswordChanged(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isPasswordValid && !_isLoading ? _savePassword : null,
                  child: _isLoading ? CircularProgressIndicator() : Text('Save Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
