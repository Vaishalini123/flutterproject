import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:test2/DatabaseHelper.dart';
import 'package:test2/Item.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/StaffIdCardModel.dart';

import 'package:dio/dio.dart';

import 'package:test2/StaffIdCard.dart';

import 'IDcardErrorMessage.dart';
import 'TempStaffIdCard.dart';

class NextScreen extends StatefulWidget {
  const NextScreen({Key? key}) : super(key: key);

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  late DatabaseHelper dbHelper;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late List<Item> itemList = [];
  late List<Item> filteredItems = [];
  final Set<int> _selectedItemIndices = {};


  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();


    // Configure Firebase messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Handle message when app is in foreground
      // Extract notification data and store in database
      final title = message.notification?.title;
      final body = message.notification?.body;
      print("title $title");
      print("body $body");
      final timestamp = DateTime.now().toString();
      await DatabaseHelper.insertNotification(title ?? "", body ?? "", timestamp);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('A notification message was clicked or tapped while the app was in the foreground or background!');
      // You can handle the notification data here and navigate to the appropriate screen
      navigateToScreen(message);
    });

    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    loadDataFromDatabase();
  }

  // FirebaseMessaging.onBackgroundMessage should be defined at the top-level of the class
  void backgroundMessageHandler(RemoteMessage message) {
    print('Handling a background message: ${message.messageId}');
    // Handle the background message here
  }

  void navigateToScreen(RemoteMessage message) {
    // Extract notification data and navigate to appropriate screen
    final notificationData = message.data;

    print("notidata: $notificationData");
    // Navigate to the desired screen based on the notification data
    // For example, you can use named routes to navigate to a specific screen
    if (notificationData.containsKey('screen')) {
      String screenName = notificationData['screen'];
      // Navigate to the screen using named routes
      Navigator.pushNamed(context, screenName);
    } else {
      // Navigate to a default screen if no specific screen is provided in the notification data
      Navigator.pushNamed(context, '/defaultScreen');
    }
  }

  Future<void> loadDataFromDatabase() async {
    List<Item> items = await dbHelper.getItems();
    setState(() {
      itemList = items;
      filteredItems = items;
    });
  }

  Future<void> deleteItems() async {
    List<int> selectedIndices = _selectedItemIndices.toList();
    selectedIndices.sort((a, b) => b.compareTo(a)); // Sort indices in descending order to avoid index out of bounds error

    for (int index in selectedIndices) {
      await DatabaseHelper.deleteItemFromDatabase(itemList[index].id);
      setState(() {
        itemList.removeAt(index);
      });
    }

    setState(() {
      _selectedItemIndices.clear(); // Clear selected indices after deletion
    });
  }


  String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        final minutes = difference.inMinutes;
        if (minutes == 0) {
          return 'Just now';
        } else {
          return '$minutes min${minutes != 1 ? 's' : ''} ago';
        }
      } else {
        return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
      }
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('dd-MMM').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFCBA4),
        title: Row(
          children: [
            Image.asset(
              'images/logo.png',
              width: 25,
              height: 25,
            ),
            const SizedBox(width: 4),
            const Text(
              'CeGov',
              style: TextStyle(
                color: Color(0xFF930303),
                fontSize: 21,
              ),
            ),
          ],
        ),
        // actions: [
        actions: [
          // Add your new IconButton here
          IconButton(
            icon:  Image.asset(
              'images/idcard.png',
              width: 28,
              height: 28,
            ),// Replace 'new_icon' with the icon you want to add
            onPressed: () async {

              final prefs = await SharedPreferences.getInstance();

              // Save an String value to 'name' key.
              String? empid=await prefs.getString('empId');
              // String? password=await prefs.getString('password');

              print("pass $empid");
              // Add the onPressed functionality here

              Dio dio = Dio();
              var formData = FormData.fromMap({
                'EM_EMPLOYEE_ID': empid,

              });

              var response = await dio.post(
                'https://14.139.161.124/Notification/StaffIdCard.php',
                data: formData,
              );
              Map<String, dynamic> jsonMap = json.decode(response.data);

              StaffIdCardModel? staffIdModel;
              staffIdModel = StaffIdCardModel.fromJson(jsonMap);

              print("EM_TYPE_FLAG: ${staffIdModel.EM_TYPE_FLAG}");
              if (staffIdModel.EM_TYPE_FLAG == 'T' || staffIdModel.EM_TYPE_FLAG == 'N') {
                if (staffIdModel.EM_DOR != null && staffIdModel.EM_DIGITAL_IDCARD_STATUS == "1") {

                  DateTime now=DateTime.now();
                  DateTime dt1 = now;
                  DateTime? dt2 = staffIdModel.EM_DOR;
                  String? emDorString = dt2?.toString();
                  DateTime parsedDateTime = DateTime.parse(emDorString!);


                  if(dt1.compareTo(parsedDateTime) < 0){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffIdCard()));
                  }else{
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const IDCardErrorMessage()));

                  }

                }
              }else if(staffIdModel.EM_TYPE_FLAG == 'P' || staffIdModel.EM_TYPE_FLAG == 'F') {

                if(staffIdModel.ATS_TDATE != null && staffIdModel.EM_DIGITAL_IDCARD_STATUS == "1"){

                  DateTime now=DateTime.now();
                  DateTime dt1 = now;
                  DateTime? dt2 = staffIdModel.ATS_TDATE;
                  String? emDorString = dt2?.toString();
                  DateTime parsedDateTime = DateTime.parse(emDorString!);
                  print(now);
                  print(parsedDateTime);

                  if(dt1.compareTo(parsedDateTime) < 0){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TempStaffIdCard()));
                  }else{
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const IDCardErrorMessage()));

                  }
                }
              }

            },//onpressed ends
          ),
          if (_selectedItemIndices.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete,color: Color(0xFF930303),),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Items'),
                      content: const Text('Are you sure you want to delete these items?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteItems();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF930303)),
              onPressed: () async {
                final selected = await showSearch<Item?>(
                  context: context,
                  delegate: ItemSearchDelegate(itemList),
                );

                if (selected != null) {
                  // Handle the selected item
                }
              },
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear(); // Clear shared preferences data

                            // Check if data is cleared
                            final isEmpty = (await prefs.getKeys()).isEmpty;

                            if (isEmpty) {
                              Navigator.pushReplacementNamed(context, '/secondScreen');
                            } else {
                              // Show an error message or handle the case where data is not cleared
                            }
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),

        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => loadDataFromDatabase(),
        child: ListView.builder(
          itemCount: itemList.length,
          itemBuilder: (context, index) {
            final item = itemList[index];
            return Card(
              child: ListTile(
                title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    itemList[index].title,
                    style: const TextStyle(
                      color: Color(0xFF930303),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    formatTime(DateTime.parse(item.time)),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF930303),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),

              subtitle: Text(itemList[index].message),
                onTap: () {
                  setState(() {
                    if (_selectedItemIndices.contains(index)) {
                      _selectedItemIndices.remove(index);
                    } else {
                      _selectedItemIndices.add(index);
                    }
                  });
                },
                tileColor: _selectedItemIndices.contains(index) ? Colors.blue.withOpacity(0.2) : null, // Highlight the selected item
              ),
            );
          },
        ),

      ),
    );
  }
}

class ItemSearchDelegate extends SearchDelegate<Item?> {
  final List<Item> itemList;

  ItemSearchDelegate(this.itemList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredList = itemList.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.message),
          onTap: () {
            close(context, item);
          },
        );
      },
    );
  }
}
