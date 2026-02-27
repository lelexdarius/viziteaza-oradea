import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home.dart';
import 'widgets/custom_footer.dart';

class AjutorPage extends StatefulWidget {
  const AjutorPage({Key? key}) : super(key: key);

  @override
  State<AjutorPage> createState() => _AjutorPageState();
}

class _AjutorPageState extends State<AjutorPage> {
  // -------------------------------------------------------------
  // Theme (aliniat cu Home)
  // -------------------------------------------------------------
  static const Color kBrand = Color(0xFF004E64);
  static const Color kBg = Color(0xFFE8F1F4);

  final _formKey = GlobalKey<FormState>();
  final _numeController = TextEditingController();
  final _prenumeController = TextEditingController();
  final _emailController = TextEditingController();
  final _mesajController = TextEditingController();

  bool _sending = false;

  @override
  void dispose() {
    _numeController.dispose();
    _prenumeController.dispose();
    _emailController.dispose();
    _mesajController.dispose();
    super.dispose();
  }

  // ✅ route fără animație (ca în footer)
  PageRoute<T> _noAnimRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      opaque: true,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => page,
    );
  }

  void _goHomeRoot(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      _noAnimRoute(HomePage()),
      (route) => false,
    );
  }

  // -------------------------------------------------------------
  // Firestore helper (Varianta 1)
  // -------------------------------------------------------------
  Future<void> trimiteMesajFirestore() async {
    final String nume = _numeController.text.trim();
    final String prenume = _prenumeController.text.trim();
    final String email = _emailController.text.trim();
    final String mesaj = _mesajController.text.trim();

    await FirebaseFirestore.instance.collection('support_messages').add({
      "nume": nume,
      "prenume": prenume,
      "email": email,
      "mesaj": mesaj,
      "status": "new",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: 18, color: kBrand.withOpacity(0.85)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.92),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: kBrand.withOpacity(0.10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: kBrand.withOpacity(0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: kBrand.withOpacity(0.55), width: 1.6),
      ),
    );
  }

  // -------------------------------------------------------------
  // ✅ Floating Pills Header (Apple 2025)
  // -------------------------------------------------------------
  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.55),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(0.60),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor ?? kBrand, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titlePill(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: kBrand,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _floatingPillsHeader(BuildContext context, String title) {
    final safeTop = MediaQuery.of(context).padding.top;

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: SizedBox(
        height: kToolbarHeight + safeTop,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              top: safeTop,
              left: 10,
              right: 10,
              height: kToolbarHeight,
              child: Row(
                children: [
                  _pillIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => _goHomeRoot(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Center(child: _titlePill(title))),
                  const SizedBox(width: 10),
                  // ✅ simetrie (ca în celelalte pagini)
                  const SizedBox(width: 42, height: 42),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBrand.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kBrand,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.support_agent_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Suntem aici să te ajutăm",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withOpacity(0.86),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Completează formularul și îți răspundem de obicei în max. 24h.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.62),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.5,
          fontWeight: FontWeight.w900,
          color: Colors.black.withOpacity(0.82),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _sending
            ? null
            : () async {
                if (!_formKey.currentState!.validate()) return;

                setState(() => _sending = true);

                try {
                  await trimiteMesajFirestore();

                  _numeController.clear();
                  _prenumeController.clear();
                  _emailController.clear();
                  _mesajController.clear();

                  if (!mounted) return;
                  FocusScope.of(context).unfocus();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          "Mesaj trimis. Îți răspundem cât mai curând."),
                      backgroundColor: kBrand,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Eroare: nu s-a putut trimite mesajul."),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (mounted) setState(() => _sending = false);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: kBrand,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              _sending ? "Se trimite..." : "Trimite mesajul",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickContactRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBrand.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kBrand.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mail_rounded, color: kBrand, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Email: touroradea@gmail.com",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.75),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: kBrand.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              "Rapid",
              style: TextStyle(
                color: kBrand,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 14;

    // ✅ spațiu pentru footer (ca să nu acopere butonul / textul)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      extendBody: true, // ✅ elimină “banda albă” din spatele footerului

      // ✅ header floating pills
      appBar: _floatingPillsHeader(context, "Ajutor"),

      // ✅ Back -> Home (fără animație)
      body: FooterBackInterceptor(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: topPadding,
                  left: 16,
                  right: 16,
                  bottom: footerSpace,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _heroCard(),
                      const SizedBox(height: 12),
                      _quickContactRow(),

                      _sectionTitle("Datele tale"),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _numeController,
                              decoration: _inputDecoration(
                                label: "Nume",
                                hint: "Ex: Pop",
                                icon: Icons.badge_rounded,
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Introduceți numele"
                                      : null,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _prenumeController,
                              decoration: _inputDecoration(
                                label: "Prenume",
                                hint: "Ex: Andrei",
                                icon: Icons.person_rounded,
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? "Introduceți prenumele"
                                      : null,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration(
                          label: "Email *",
                          hint: "exemplu@email.com",
                          icon: Icons.alternate_email_rounded,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Emailul este obligatoriu";
                          }
                          final emailRegExp =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegExp.hasMatch(value)) {
                            return "Introduceți un email valid";
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),

                      _sectionTitle("Mesaj"),
                      TextFormField(
                        controller: _mesajController,
                        maxLines: 6,
                        maxLength: 500,
                        decoration: _inputDecoration(
                          label: "Mesajul tău",
                          hint: "Scrie aici ce ai nevoie…",
                          icon: Icons.chat_bubble_outline_rounded,
                        ).copyWith(alignLabelWithHint: true),
                        validator: (value) => value == null || value.isEmpty
                            ? "Scrie mesajul tău"
                            : null,
                        textInputAction: TextInputAction.newline,
                      ),

                      const SizedBox(height: 8),
                      _submitButton(),

                      const SizedBox(height: 22),
                      Center(
                        child: Text(
                          "— Tour Oradea © 2025 —",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ Footer floating
            const Align(
              alignment: Alignment.bottomCenter,
              child: CustomFooter(isHome: false),
            ),
          ],
        ),
      ),
    );
  }
}
