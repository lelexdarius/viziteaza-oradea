import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'evenimente_detalii_page.dart';
import 'widgets/custom_footer.dart';

import 'package:viziteaza_oradea/home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:viziteaza_oradea/utils/app_theme.dart';
import 'package:viziteaza_oradea/utils/schedule_parser.dart';
import 'package:viziteaza_oradea/services/app_state.dart';

class EvenimentePage extends StatefulWidget {
  const EvenimentePage({super.key});

  @override
  State<EvenimentePage> createState() => _EvenimentePageState();
}

class _EvenimentePageState extends State<EvenimentePage> {
  static const Color kBrand = Color(0xFF004E64);
  static const Color _cellDark = Color(0xFF37474F);  // dark mode unselected
  static const Color _cellLight = Color(0xFF1B7A96); // light mode unselected

  DateTime? _selectedDate; // null = toate

  static const List<String> _dayNames = ['LU', 'MA', 'MI', 'JO', 'VI', 'SÂ', 'DU'];

  String _dayAbbr(DateTime d) => _dayNames[d.weekday - 1];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Urmtoarele 9 zile începând de azi (se schimbă automat în fiecare zi).
  List<DateTime> _next9Days() {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    return List.generate(9, (i) => base.add(Duration(days: i)));
  }

  // ----------------------------------------------------------------
  // Navigation
  // ----------------------------------------------------------------
  void _goHomeNoAnim(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushReplacement(
      PageRouteBuilder(
        opaque: true,
        barrierDismissible: false,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => HomePage(),
        settings: const RouteSettings(name: CustomFooter.routeHome),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Pill header helpers
  // ----------------------------------------------------------------
  Widget _pillIconButton({required IconData icon, required VoidCallback onTap}) {
    final isDark = AppState.instance.isDarkMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: isDark ? Colors.black : Colors.white.withOpacity(0.55),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDark ? Colors.white : Colors.white.withOpacity(0.60),
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
              child: Icon(icon, color: isDark ? Colors.white : kBrand, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titlePill(String text) {
    final isDark = AppState.instance.isDarkMode;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: isDark ? Colors.white : Colors.white.withOpacity(0.55),
                width: 1),
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
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : kBrand,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _floatingPillsHeader(BuildContext context) {
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
                    icon: Icons.arrow_back,
                    onTap: () => _goHomeNoAnim(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Center(child: _titlePill("Evenimente Oradea")),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(width: 42, height: 42),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Date picker card — built from real event dates
  // ----------------------------------------------------------------
  Widget _datePickerCard(List<DateTime> dates) {
    final accent = AppTheme.accentGlobal;
    final isAll = _selectedDate == null;

    // Build rows of 3
    final rows = <Widget>[];
    for (int i = 0; i < dates.length; i += 3) {
      final rowDates = dates.skip(i).take(3).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int j = 0; j < 3; j++)
                j < rowDates.length
                    ? Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: j > 0 ? 8 : 0),
                          child: _dayCell(rowDates[j], accent),
                        ),
                      )
                    : Expanded(child: Padding(padding: EdgeInsets.only(left: 8), child: const SizedBox())),
            ],
          ),
        ),
      );
      if (i + 3 < dates.length) rows.add(const SizedBox(height: 8));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.isDarkGlobal
            ? const Color(0xFF1C1C1E)
            : Colors.white.withOpacity(0.92),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // "Toate" button
          GestureDetector(
            onTap: () => setState(() => _selectedDate = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: isAll ? accent : (AppTheme.isDarkGlobal ? _cellDark : _cellLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Toate evenimentele",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          if (dates.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "Nu există date disponibile.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            )
          else ...[
            const SizedBox(height: 8),
            ...rows,
          ],
        ],
      ),
    );
  }

  Widget _dayCell(DateTime day, Color accent) {
    final isSelected = _selectedDate != null && _isSameDay(_selectedDate!, day);
    final dateStr =
        '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => setState(() {
        _selectedDate = isSelected ? null : day;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accent : (AppTheme.isDarkGlobal ? _cellDark : _cellLight),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _dayAbbr(day),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              dateStr,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Event card
  // ----------------------------------------------------------------
  Widget _buildEventCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final String title = data["title"] ?? "Eveniment";
    final String description = data["description"] ?? "";
    final String locatie = data["address"] ?? "Locație necunoscută";
    final String dataText = data["schedule"] ?? "";
    final String pret = data["price"]?.toString() ?? "Nespecificat";
    final String banner = data["image"] ?? "";
    final String linkBilete = data["mapLink"] ?? "";

    final ts = data["data_timp"];
    final DateTime? eventDate = (ts is Timestamp) ? ts.toDate() : null;
    final bool esteViitor =
        eventDate == null ? true : eventDate.isAfter(DateTime.now());
    final Color statusColor = esteViitor ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: banner.isNotEmpty && banner.startsWith("http")
                      ? CachedNetworkImage(
                          imageUrl: banner,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/images/evenimente.jpg.webp",
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(left: 6, right: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_month,
                              color: AppTheme.accentGlobal, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dataText,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary(context)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: AppTheme.accentGlobal, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              locatie,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary(context)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Descriere scurtată
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Preț: $pret lei",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 63, 147, 21),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailsPage(
                          title: title,
                          description: description,
                          imagePath: banner,
                          data: dataText,
                          ora: "",
                          locatie: locatie,
                          pret: pret,
                          organizator: "",
                          linkBilete: linkBilete,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.event, color: AppTheme.accentGlobal),
                  label: Text(
                    "Detalii",
                    style: TextStyle(
                      color: AppTheme.accentGlobal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Build
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 10;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerSpace = 90 + bottomInset + 12;

    return FooterBackInterceptor(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: _floatingPillsHeader(context),
        body: Stack(
          children: [
            Positioned.fill(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('evenimente')
                    .orderBy('order')
                    .snapshots(),
                builder: (context, snapshot) {
                  final allDocs = snapshot.hasData
                      ? snapshot.data!.docs
                      : <QueryDocumentSnapshot>[];

                  // Apply date filter using schedule text
                  final filtered = _selectedDate == null
                      ? allDocs
                      : allDocs.where((doc) {
                          final d = doc.data() as Map<String, dynamic>;
                          final schedule = (d['schedule'] as String?) ?? '';
                          final ts = d['data_timp'];
                          final DateTime? endDate = ts is Timestamp
                              ? ts.toDate().toLocal()
                              : null;
                          return ScheduleParser.occursOn(
                            schedule: schedule,
                            endDate: endDate,
                            date: _selectedDate!,
                          );
                        }).toList();

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: topPadding,
                      left: 16,
                      right: 16,
                      bottom: footerSpace,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Date picker card with real event dates
                        if (snapshot.connectionState ==
                            ConnectionState.waiting)
                          const Center(child: CircularProgressIndicator())
                        else
                          _datePickerCard(_next9Days()),

                        const SizedBox(height: 18),

                        // Event list
                        if (snapshot.connectionState ==
                            ConnectionState.waiting)
                          const SizedBox.shrink()
                        else if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Center(
                              child: Text(
                                _selectedDate != null
                                    ? "Nu există evenimente pentru această dată."
                                    : "Momentan nu există evenimente disponibile.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppTheme.textSecondary(context),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ...filtered.map(
                              (doc) => _buildEventCard(context, doc)),

                        const SizedBox(height: 34),
                        Center(
                          child: Text(
                            "— Tour Oradea © 2025 —",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppTheme.textSecondary(context),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  );
                },
              ),
            ),

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
