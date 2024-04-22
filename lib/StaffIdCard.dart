import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:test2/StaffIdCardModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

import 'package:url_launcher/url_launcher.dart';

import 'IDcardErrorMessage.dart';
import 'ApplyIDcard.dart';


class StaffIdCard extends StatefulWidget {
  const StaffIdCard({Key? key});

  @override
  _StaffIdCardState createState() => _StaffIdCardState();
}

class _StaffIdCardState extends State<StaffIdCard> {
  StaffIdCardModel? staffIdModel;
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _employeeDesignationController = TextEditingController();
  final TextEditingController _employeeCampusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    _employeeDesignationController.dispose();
    _employeeCampusController.dispose();
    super.dispose();
  }

  Future<void> checkEmpIdCard() async {
    final prefs = await SharedPreferences.getInstance();
    String? empid = prefs.getString('empId');

    try {
      Dio dio = Dio();
      var formData = FormData.fromMap({
        'EM_EMPLOYEE_ID': empid ?? '',
      });
      var response = await dio.post(
        'https://14.139.161.124/Notification/StaffIdCard.php',
        data: formData,
      );

      if (response.statusCode == 200) {
        if (response.data is String) {
          Map<String, dynamic> jsonMap = json.decode(response.data);

          setState(() {
            staffIdModel = StaffIdCardModel.fromJson(jsonMap);
          });

        if(staffIdModel!=null && staffIdModel?.EM_DOR!=null) {
          DateTime now = DateTime.now();
          DateTime? dt2 = staffIdModel?.EM_DOR;
          String? emDorString = dt2?.toString();
          DateTime parsedDateTime = DateTime.parse(emDorString!);

          if (parsedDateTime.compareTo(now) >= 0 &&
              staffIdModel?.EM_DIGITAL_IDCARD_STATUS == "1") {
            String? encryptedEmpId = base64Encode(utf8.encode(empid!));
            Uri qrCodeData = Uri.parse(
                "https://www.auegov.ac.in/QRStaffIdCard/?QR=$encryptedEmpId");
            print(qrCodeData);
            if (!await launchUrl(qrCodeData)) {
              throw 'Could not launch $qrCodeData';
            }
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const IDCardErrorMessage()));
          }
        }else{
          Navigator.push(context, MaterialPageRoute(builder: (context) => ApplyIDcard()));
        }

        }
      }
    } catch (e) {
      print(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
  return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final SharedPreferences prefs = snapshot.data!;
          final String? empid = prefs.getString('empId');
          String? encryptedEmpId = base64Encode(utf8.encode(empid!));
          var qrCodeData = "https://www.auegov.ac.in/QRStaffIdCard/?QR=$encryptedEmpId";



          return Scaffold(
            appBar: AppBar(
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
            ),
            body: SingleChildScrollView(
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                // height: MediaQuery
                //     .of(context)
                //     .size
                //     .height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/idbackground.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7, left: 25),
                          child: Text(
                            "To verify use",
                            style: TextStyle(
                              color: Color(0xFF930303),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 20),
                          child: Image.asset(
                            "images/hand.png",
                            width: 100,
                            height: 25,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {

                            checkEmpIdCard();
                            // Add your button onPressed logic here
                          },
                          child: Text('Verify'), // Add your button text here
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          "images/idcardheaderstaff.png",
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 75),
                              child: Image.memory(
                                base64Decode(staffIdModel!.ASP_PHOTO!),
                                width: 140,
                                height: 140,
                              ),
                            ),
                            // Align QR code to the top right corner
                            Align(
                              alignment: Alignment.topRight,
                              child: QrImageView(
                                data: qrCodeData,
                                errorCorrectionLevel: QrErrorCorrectLevel.H,
                                version: QrVersions.auto,
                                gapless: true,
                                backgroundColor: Colors.white,
                                eyeStyle: QrEyeStyle(color: Colors.black),
                                size: 125,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Container(
                          margin: const EdgeInsets.only(left: 55),

                        child:SizedBox(
                          width: 157, // Set your desired width here
                          height: 30, // Set your desired height here
                          child: SfBarcodeGenerator(
                            value: empid,
                          ),
                        ),

                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 105),
                          child:Text(
                          empid,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        //Text('Scan the QR code'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(

                      margin: const EdgeInsets.only(left: 15, bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _employeeNameController.text,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _employeeDesignationController.text,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _employeeCampusController.text,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Blood Group',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(width: 16),
                                  const Text(
                                    ":",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                   Text(
                                      staffIdModel?.EMBLOODGROUP ?? "",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Phone(M)',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 31.5), // Adjust the width as needed
                                  const Text(
                                    ":",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      staffIdModel?.EC_MOBILE_NO ?? "",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),

                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Address',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 41), // Adjust the width as needed
                                  const Text(
                                    ":",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      staffIdModel?.EMADDRESS ?? "",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Phone(O)',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 34), // Adjust the width as needed
                                  const Text(
                                    ":",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                     Text(
                                      staffIdModel?.EMOFFICENO ?? "",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),

                                ],
                              ),

                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20, right: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 0),
                                        child: Image.asset(
                                          "images/prakash.png",
                                          width: 100,
                                          height: 60,
                                        ),
                                      ),
                                      const SizedBox(height: 0), // Optional spacing between image and text
                                      Container(
                                        margin: const EdgeInsets.only(right: 19),
                                            child:  Text(
                                              'Registrar',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Row(
                                children: [
                                  Image.asset(
                                    'images/phone.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                  const Text(
                                    'Registrar ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    ":",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                    const Text(
                                      "044-22357004",
                                      textAlign: TextAlign.right, // Align text to the right
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),

                                ],
                              ),


                            ],

                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Handle loading state
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }//else
      },//builder
    );
}


  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    String? empid = prefs.getString('empId');

    try {
      Dio dio = Dio();
      var formData = FormData.fromMap({
        'EM_EMPLOYEE_ID': empid ?? '',
      });
      var response = await dio.post(
        'https://14.139.161.124/Notification/StaffIdCard.php',
        data: formData,
      );

      if (response.statusCode == 200) {
        if (response.data is String) {
          Map<String, dynamic> jsonMap = json.decode(response.data);
          setState(() {
            staffIdModel = StaffIdCardModel.fromJson(jsonMap);
            _employeeNameController.text = staffIdModel!.EMNAME ?? '';
            _employeeDesignationController.text = staffIdModel!.EMDESIGNAMTION ?? '';

            int? campCode = int.tryParse(staffIdModel?.EM_CAMP_CODE ?? '');

            if (campCode != null && campCode < 5) {
              _employeeCampusController.text = "UNIVERSITY DEPARTMENT";
            } else {
              _employeeCampusController.text = staffIdModel!.FC_CAMP_NAME ?? '';
            }

          });
          return;
        }
      } else {
        // Handle non-200 status code
      }
    } catch (e) {
      // Handle Dio errors and other exceptions
    }
  }
}
