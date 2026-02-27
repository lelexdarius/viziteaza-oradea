import 'package:flutter/material.dart';
import 'dart:ui'; // pentru efect de blur
import 'widgets/custom_footer.dart';

class BaileFelixPage extends StatelessWidget {
  const BaileFelixPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFE8F1F4), // același ca în celelalte pagini
      extendBodyBehindAppBar: true,

      // 🔹 AppBar cu efect Apple Glass
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.2),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Băile Felix",
                style: TextStyle(
                  color: Color(0xFF004E64),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF004E64)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),

      // 🔹 Conținut principal
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Această secțiune este momentan în dezvoltare.\n\n"
                  "Curând vei putea descoperi informații despre stațiunea Băile Felix — cazări, activități, locuri de vizitat și experiențe termale unice. 💧🏞️",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
         const CustomFooter(isHome: true),
        ],
      ),
    );
  }
  }