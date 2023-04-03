import 'dart:convert';
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
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/auth/parcours/${widget.name}'));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final origin = responseData['origin'];
      final destination = responseData['destination'];
      print('Origin: $origin, Destination: $destination');
      
      // Call Google Maps API to get directions
      final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=AIzaSyAl4Roro-U8lYLJYUg5ai6bHbGDxkVgkzE';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        // Extract relevant information from API response
        final duration = data['routes'][0]['legs'][0]['duration']['text'];
        final distance = data['routes'][0]['legs'][0]['distance']['text'];
        final steps = data['routes'][0]['legs'][0]['steps'];

        // Build notification message
        var notificationMessage =
            'Here are the directions from $origin to $destination:\n\n'
            'Duration: $duration\n'
            'Distance: $distance\n\n'
            'Steps:\n';
        for (final step in steps) {
          notificationMessage += '- ${step['html_instructions'].replaceAll('<[^>]*>', '')}\n';
        }

        // Split notification message into chunks of 200 characters each
        final chunks = <String>[];
        for (var i = 0; i < notificationMessage.length; i += 200) {
          if (i + 200 > notificationMessage.length) {
            chunks.add(notificationMessage.substring(i));
          } else {
            chunks.add(notificationMessage.substring(i, i + 200));
          }
        }

        // Send notification message chunks to Dialogflow
        for (final chunk in chunks) {
          final response = await dialogFlowtter.detectIntent(
            queryInput: QueryInput(text: TextInput(text: chunk)),
            queryParams: QueryParams(
              sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
              languageCode: 'en',
              eventName: 'notification',
            ),
          );

          // Add the notification message to the chat
          setState(() {
            addMessage(Message(
              text: DialogText(text: [chunk]),
            ));
          });
        }
      } else {
        print('Failed to call Google Maps API with status code: ${res.statusCode}');
      }
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
  
  QueryParams({required String sessionId, required String languageCode, required String eventName}) {} 
}
