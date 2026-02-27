import 'package:flutter/material.dart';

class LocationDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const LocationDetailsPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundal alb
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.5), // 50% transparent
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagine full-width
            Image.asset(imagePath, width: double.infinity, fit: BoxFit.cover),

            // Titlu muzeu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Descriere muzeu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
            ),

            SizedBox(height: 20), // Spațiu gol pentru design aerisit
          ],
        ),
      ),
    );
  }
}
