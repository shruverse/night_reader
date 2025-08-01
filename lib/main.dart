import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Fullscreen, under status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
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
  double brightness = 1.0;
  Color currentColor = Colors.orangeAccent;
  List<String> favoriteLabels = ["Fav 1", "Fav 2", "Fav 3"];
  String? selectedFavorite;

  // Neon shades
  final List<Color> neonColors = [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.pink,
  ];

  // Pastel shades
  final List<Color> pastelColors = [
    const Color(0xFFADD8E6), // pastel blue
    const Color(0xFFFFC1CC), // pastel red/pink
    const Color(0xFFFFE5B4), // pastel orange
    const Color(0xFFB2F2BB), // pastel green
    const Color(0xFFF8C8DC), // pastel pink
  ];

  // Used to track index of selected color
  int selectedColorIndex = 2; // initially orange

  List<Color> get currentColorSet => isNeon ? neonColors : pastelColors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentColor.withOpacity(brightness),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: currentColor.withOpacity(brightness)),
          ),

          // Circular brightness slider
          Positioned(
            bottom: 170,
            left: 0,
            right: 0,
            child: Center(
              child: SleekCircularSlider(
                initialValue: brightness * 100,
                min: 0,
                max: 100,
                appearance: CircularSliderAppearance(
                  angleRange: 360,
                  size: 160,
                  customColors: CustomSliderColors(
                    progressBarColor: Colors.white,
                    trackColor: Colors.white.withOpacity(0.3),
                    dotColor: Colors.white,
                  ),
                  infoProperties: InfoProperties(
                    modifier: (double value) => 'Brightness',
                    mainLabelStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                onChange: (value) {
                  setState(() {
                    brightness = value / 100;
                  });
                },
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Feature icons
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

                          // switch currentColor to corresponding one in new set
                          currentColor = isNeon
                              ? neonColors[selectedColorIndex]
                              : pastelColors[selectedColorIndex];
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.mail,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _showFavoriteDropdown,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        print("Favorite saved!");
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Color circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: currentColorSet.asMap().entries.map((entry) {
                    int index = entry.key;
                    Color color = entry.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColorIndex = index;
                          currentColor = color;
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 20,
                        child: selectedColorIndex == index
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
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
