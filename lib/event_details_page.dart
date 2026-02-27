import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final List<String> monthlySchedule; // Programul pentru fiecare lună

  EventDetailsPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.monthlySchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(description, style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Programul lunii:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            ...monthlySchedule.map((event) => ListTile(
                  leading: Icon(Icons.event, color: Colors.blueAccent),
                  title: Text(event, style: TextStyle(fontSize: 16)),
                )),
          ],
        ),
      ),
    );
  }
}
