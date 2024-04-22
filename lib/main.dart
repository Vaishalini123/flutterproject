import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/Secondscreen.dart';
import 'package:test2/NextScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'api/firebase_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDPv76Sr0WS8Y_cU9V36o_uTkFCBW8CbmE",
        appId: "1:152245086125:android:d87ad87acd4d273693e324",
        messagingSenderId: "152245086125",
        projectId: "test2-5f5d8"),
  );
  // Register the background message handler
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  await FirebaseApi().initNotification();
  runApp(const MyApp());
}

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Handle the background message here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // home: const Secondscreen(),
      routes: {
        '/': (context) {
          return FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final prefs = snapshot.data!;
                final getempId = prefs.getString('empId');
                final getpass = prefs.getString('password');

                if (getempId != null && getpass != null) {
                  return const NextScreen();
                } else {
                  return const Secondscreen();
                }
              } else {
                // Return a loading indicator or placeholder widget while waiting for SharedPreferences
                return const CircularProgressIndicator();
              }
            },
          );
        },
        '/next_screen': (context) => const NextScreen(), // Next screen route
        '/secondScreen': (context) => const Secondscreen(),
      },
    );
  }
}
//*************************************************************************
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
//*************************************************************************
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const secondscreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
