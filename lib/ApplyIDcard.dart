import 'package:flutter/material.dart';

class ApplyIDcard extends StatefulWidget {
  @override
  _ApplyIDCardState createState() => _ApplyIDCardState();
}

class _ApplyIDCardState extends State<ApplyIDcard> {

  @override
  void initState() {
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('ID Card Error Message'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Color(0xFF930303)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
      body: Center(child:Container(
        width: 350,
        height: 200,
        color: Color(0xFF930303),
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(Icons.ac_unit, color: Color(0xFFF7D5AA), size: 36),
            SizedBox(height: 16),
            Text(
              'Apply for the ID Card through Academica.',
              style: TextStyle(
                color: Color(0xFFF7D5AA),
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
