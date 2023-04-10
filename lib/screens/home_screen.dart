import 'dart:convert';
import 'package:flutter_dialogflow/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/screens/Messages.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({Key? key, required this.email}) : super(key: key);

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
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/auth/parcours/${widget.email}'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final gareDepart = responseData['gareDepart'];
        final dateDepart = DateTime.parse(responseData['dateDepart']);
        final latitude = responseData['latitude'];
        final longitude = responseData['longitude'];
        
        // Check if the current date is one day before the dateDepart
        final currentDate = DateTime.now();
        print(currentDate);
        final oneDayBeforeDateDepart = dateDepart.subtract(Duration(days: 1));
        print(oneDayBeforeDateDepart);
        if (currentDate.isBefore(oneDayBeforeDateDepart)) {
          print('Current date is not one day before dateDepart');
          return;
        }
        final helloMessage =
            "Hello, your departure will be from $gareDepart on $dateDepart. Please arrive at the terminal on time for baggage check-in.";

        // Send notification message to Dialogflow
        final detectIntentResponse = await dialogFlowtter.detectIntent(
          queryInput: QueryInput(
              event: EventInput(
                  name: 'notification',
                  parameters: {'date': oneDayBeforeDateDepart.toIso8601String().substring(0, 10)},
                  languageCode: 'en')),
          queryParams: QueryParams(
            sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
            languageCode: 'en',
            eventName: 'notification',
          ),
        );
         await getTouristicActivities(latitude, longitude);
        // Add the notification message to the chat
        setState(() {
          addMessage(Message(
            text: DialogText(text: [helloMessage]),
          ));
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (error) {
      print('Error occurred: $error.');
    }
  }
  Future<List<Map<String, dynamic>>> getTouristicActivities(double latitude, double longitude) async {
  final apiKey = 'AIzaSyAwPxt4Oi9wvbubOMcVmxpJY6DoNPMbvpo';
  final radius = 10000; // in meters, adjust as needed
  final type = 'tourist_attraction'; // filter by tourist attractions
  
  final url =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=$apiKey';
  
  final response = await http.get(Uri.parse(url));
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final results = data['results'];
    
    List<Map<String, dynamic>> activities = [];
    
    // Process the results as needed
    for (final result in results) {
      final name = result['name'];
      final vicinity = result['vicinity'];
      final distance = result['distance'];
      
      activities.add({
        'name': name,
        'vicinity': vicinity,
        'distance': distance,
      });
    }
    
    return activities;
  } else {
    print('Failed to get touristic activities: ${response.reasonPhrase}');
    return [];
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Travelbee',
          style: TextStyle(
            color: Colors.black, // Set the text color to black
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Divider(
            color: Colors.transparent, // Set the color of the divider to transparent to remove it
            height: 0,
            thickness: 0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: MessagesScreen(messages: messages)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Color(0xFFF5F5F5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Container(
                  width: 40, // Replace with the desired width of the container
                  height: 40, // Replace with the desired height of the container
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF01D6C5), // Replace with the desired background color
                  ),
                  child: IconButton(
                    onPressed: () {
                      sendMessage(_controller.text);
                      _controller.clear();
                    },
                    icon: SvgPicture.asset('assets/sendbutton.svg'),
                  ),
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

    DetectIntentResponse response = await dialogFlowtter.detectIntent(
        queryInput: QueryInput(text: TextInput(text: text)));
    if (response.message == null) return;

    // Check if the user's message contains the keyword "tourist"
    if (text.toLowerCase().contains('touristiques')) {
      final locationResponse = await http.get(Uri.parse(
          'http://10.0.2.2:8000/auth/parcours/${widget.email}'));
      if (locationResponse.statusCode == 200) {
        final locationData = jsonDecode(locationResponse.body);
        final latitude = locationData['latitude'];
        final longitude = locationData['longitude'];
        List<Map<String, dynamic>> activities = await getTouristicActivities(latitude, longitude);
         setState(() {
      addMessage(Message(
        text: DialogText(text: ['Here are some tourist activities near you:']),
      ));
      for (final activity in activities) {
        addMessage(Message(
          text: DialogText(text: [activity['name'] + ' (' + activity['vicinity'] + ') - ' + activity['distance'].toString() + ' meters away']),
        ));
      }
    });
      } else {
        print('Failed to get user location: ${locationResponse.reasonPhrase}');
      }
    }

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
