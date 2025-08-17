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
  int selectedColorIndex = 2;
  String? selectedFavorite;

  final List<String> favoriteLabels = ["Fav 1", "Fav 2", "Fav 3"];

  final List<Color> neonColors = [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.pink,
  ];

  final List<Color> pastelColors = [
    const Color(0xFFADD8E6),
    const Color(0xFFFFC1CC),
    const Color(0xFFFFE5B4),
    const Color(0xFFB2F2BB),
    const Color(0xFFF8C8DC),
  ];

  List<Color> get currentColorSet => isNeon ? neonColors : pastelColors;

  // Map to store favorites
  Map<String, Map<String, dynamic>> savedFavorites = {
    "Fav 1": {},
    "Fav 2": {},
    "Fav 3": {},
  };

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
                  angleRange: 270,
                  startAngle: 135,
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
                          currentColor = currentColorSet[selectedColorIndex];
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
                        _saveToFavoriteDialog();
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

  void _saveToFavoriteDialog() {
    // Only show empty favorite slots
    List<String> emptySlots = favoriteLabels
        .where((label) => savedFavorites[label]?['colorIndex'] == null)
        .toList();

    if (emptySlots.isEmpty) {
      // Show message if no empty slots
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("No Empty Slots"),
            content: const Text(
              "All favorite slots are occupied. Please delete a favorite first to save a new one.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Save to Favorite"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: emptySlots.map((label) {
              return ListTile(
                title: Text(label),
                subtitle: const Text(
                  "Empty slot",
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  setState(() {
                    savedFavorites[label] = {
                      'isNeon': isNeon,
                      'colorIndex': selectedColorIndex,
                      'brightness': brightness,
                    };
                    selectedFavorite = label;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
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
            bool isEmpty = savedFavorites[label]?['colorIndex'] == null;
            return ListTile(
              title: Text(label, style: const TextStyle(color: Colors.white)),
              subtitle: isEmpty
                  ? const Text(
                      "Empty",
                      style: TextStyle(color: Colors.redAccent),
                    )
                  : const Text(
                      "Tap to load",
                      style: TextStyle(color: Colors.grey),
                    ),
              trailing: isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context); // Close dropdown first
                        _deleteFavorite(label);
                      },
                    ),
              onTap: isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      _loadFavorite(label);
                    },
            );
          }).toList(),
        );
      },
    );
  }

  void _loadFavorite(String label) {
    var fav = savedFavorites[label];
    if (fav != null && fav['colorIndex'] != null) {
      setState(() {
        isNeon = fav['isNeon'];
        selectedColorIndex = fav['colorIndex'];
        brightness = fav['brightness'];
        currentColor = isNeon
            ? neonColors[selectedColorIndex]
            : pastelColors[selectedColorIndex];
      });
    }
  }

  void _deleteFavorite(String label) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Favorite"),
          content: Text("Are you sure you want to delete $label?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  savedFavorites[label] = {};
                  if (selectedFavorite == label) {
                    selectedFavorite = null;
                  }
                });
                Navigator.pop(context);

                // Show confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$label deleted"),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
