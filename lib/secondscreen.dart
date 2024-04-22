import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test2/LoginModel.dart';
import 'api/firebase_api.dart';

class Secondscreen extends StatelessWidget {
  const Secondscreen({Key? key});

  @override
  Widget build(BuildContext context) {
    TextEditingController empIdController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    Future<void> login(String empId, String password, String notificationId) async {
      try {
        Dio dio = Dio();
        var formData = FormData.fromMap({
          'AL_EMPID': empId,
          'AL_PWD': password,
          'AL_NOTIFICATION_ID': notificationId,
        });
        var response = await dio.post(
          'https://14.139.161.124/Notification/UDUCELogin.php',
          data: formData,
        );

        if (response.statusCode == 200) {
          // Check if response data is a string
          if (response.data is String) {
            // Handle string response

            LoginModel loginModel = LoginModel.decode(response.data);
            if (loginModel.status) {
              // Login successful
              Navigator.pushReplacementNamed(context, '/next_screen');
            } else {
              // Login failed
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Login Failed'),
                    content: Text(loginModel.remarks),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          }
        } else {
          // Handle non-200 status code
          print('Failed to login: ${response.statusCode}');
          // Show an appropriate error message or take other actions as needed
        }
      } catch (e) {
        // Handle Dio errors and other exceptions
        print('Exception occurred: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred while processing your request.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFCBA4),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            const SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Color(0xFFFFCBA4),
              primary: false,
              // Add any other properties you need for your app bar
            ),
          ];
        },
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Image.asset(
                    'images/logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Academica',
                    style: TextStyle(
                      fontFamily: 'amazonbt',
                      color: Color(0xFF930303),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF930303),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: empIdController, // Assign controller
                    decoration: InputDecoration(
                      hintText: 'Employee ID',
                      hintStyle: const TextStyle(color: Color(0xFF508A8C92)),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(right: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF508A8C92),
                          borderRadius: BorderRadius.circular(0), // Adjust border radius as needed
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF5930303)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none, // Set the border to none
                    ),
                    keyboardType: TextInputType.number,
                    autofocus: false,
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController, // Assign controller
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Color(0xFF508A8C92)),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(right: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF508A8C92),
                          borderRadius: BorderRadius.circular(0), // Adjust border radius as needed
                        ),
                        child: const Icon(Icons.key, color: Color(0xFF5930303)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none, // Set the border to none
                    ),
                    obscureText: true,
                    autofocus: false,
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String empId = empIdController.text.trim();
                      String password = passwordController.text.trim();
                      final prefs = await SharedPreferences.getInstance();
                      if (empId.isEmpty || password.isEmpty) {
                        // Show error message if either field is empty
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Please fill in all fields.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        return; // Exit the function if fields are empty
                      }
                      // Save an String value to 'name' key.
                      await prefs.setString('empId', empId);
                      await prefs.setString('password', password);

                      String? fcmToken = await FirebaseApi().initNotification();
                      print("fcmtoken $fcmToken");
                      await prefs.setString('token', fcmToken ?? '');

                      if (fcmToken != null) {
                        login(empId, password, fcmToken); // Pass FCM token to login function
                      } else {
                        // Handle case where FCM token is null
                        print('Failed to get FCM token');
                      }
                      // login(empId, password, "cxK8CbpZTVi7jFlwcNwM4H:APA91bFvxB3RE-zEHqxOJCd5_CvKyiPQNGrmvzU8W8DyJ8TeUshNXxZNkuAhlN9LgIFF7H7vBYRkvg7uMIthhXXwJOCBIONdtIr5vTYdt199cuD5uC9J31U_jyL22v_5t--iuEAqjx8f"); // Pass retrieved values to login function
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(620, 34),
                      backgroundColor: const Color(0xFF930303),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login, // Replace Icons.login with the appropriate icon
                          color: Colors.white,
                        ),
                        SizedBox(width: 10), // Adjust the width as needed
                        Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
