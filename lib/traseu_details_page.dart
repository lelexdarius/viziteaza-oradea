import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TraseuDayTimeline extends StatefulWidget {
  final int dayNumber;
  final int totalDays;
  final Map<String, dynamic> data;

  const TraseuDayTimeline({
    Key? key,
    required this.dayNumber,
    required this.totalDays,
    required this.data,
  }) : super(key: key);

  @override
  State<TraseuDayTimeline> createState() => _TraseuDayTimelineState();
}

class _TraseuDayTimelineState extends State<TraseuDayTimeline> {
  late List activities;
  late SharedPreferences prefs;
  Map<String, bool> checkedStatus = {};

  @override
  void initState() {
    super.initState();
    activities = widget.data["activities"];
    _loadChecks();
  }

  Future<void> _loadChecks() async {
    prefs = await SharedPreferences.getInstance();

    for (var item in activities) {
      checkedStatus[item["id"]] = prefs.getBool(item["id"]) ?? false;
    }
    setState(() {});
  }

  Future<void> _toggleCheck(String id) async {
    bool newValue = !(checkedStatus[id] ?? false);
    checkedStatus[id] = newValue;
    await prefs.setBool(id, newValue);
    setState(() {});
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "cafe":
        return Icons.local_cafe_rounded;
      case "museum":
        return Icons.account_balance_rounded;
      case "food":
        return Icons.restaurant_rounded;
      case "fun":
        return Icons.sports_esports_rounded;
      case "music":
        return Icons.music_note_rounded;
      case "theatre":
        return Icons.theater_comedy_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 50),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final item = activities[index];
        final isChecked = checkedStatus[item["id"]] ?? false;

        return Stack(
          children: [
            // Linie verticală
            Positioned(
              left: 24,
              top: 0,
              bottom: index == activities.length - 1 ? 30 : 0,
              child: Container(
                width: 2,
                color: Colors.grey.shade300,
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      item["hour"],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isChecked
                            ? Colors.green.shade600
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 24),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Deschidem: ${item["title"]}")),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 30),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isChecked
                              ? Colors.green.shade600
                              : Colors.grey.shade300,
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _getIcon(item["type"]),
                            color: Colors.black87,
                            size: 26,
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"],
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item["type"],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () => _toggleCheck(item["id"]),
                            child: Icon(
                              isChecked
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked,
                              color: isChecked
                                  ? Colors.green.shade600
                                  : Colors.grey.shade400,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
