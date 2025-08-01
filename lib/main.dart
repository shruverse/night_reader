import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This makes the app go full screen under status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NightReaderScreen(),
    );
  }
}

class NightReaderScreen extends StatefulWidget {
  const NightReaderScreen({super.key});

  @override
  State<NightReaderScreen> createState() => _NightReaderScreenState();
}

class _NightReaderScreenState extends State<NightReaderScreen> {
  bool isNeon = true;
  Color currentColor = Colors.orangeAccent;
  List<String> favoriteLabels = ["Fav 1", "Fav 2", "Fav 3"];
  String? selectedFavorite;

  // These will later be separated for neon/pastel
  final List<Color> baseColors = [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentColor,
      body: Stack(
        children: [
          // Fullscreen content (blank for now, just color)
          Positioned.fill(child: Container(color: currentColor)),

          // Bottom controls
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Feature icons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        isNeon ? Icons.wb_sunny : Icons.nightlight_round,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          isNeon = !isNeon;
                          // Later: update shades based on this
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.mail, // Envelope
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        _showFavoriteDropdown();
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        // Later: Save current setting as favorite
                        print("Favorite saved!");
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Color buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: baseColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentColor = color;
                        });
                      },
                      child: CircleAvatar(backgroundColor: color, radius: 20),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFavoriteDropdown() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: favoriteLabels.map((label) {
            return ListTile(
              title: Text(label, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedFavorite = label;
                  // Later: Load saved setting
                  print("Loaded favorite: $label");
                });
              },
            );
          }).toList(),
        );
      },
    );
  }
}
