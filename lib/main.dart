import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  bool isLocked = false;

  List<String> favoriteLabels = ["Fav 1", "Fav 2", "Fav 3"];
  final List<String> defaultFavoriteLabels = ["Fav 1", "Fav 2", "Fav 3"];

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
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load basic state
      final loadedIsNeon = prefs.getBool('isNeon') ?? true;
      final loadedBrightness = prefs.getDouble('brightness') ?? 1.0;
      final loadedSelectedColorIndex = prefs.getInt('selectedColorIndex') ?? 2;
      final loadedSelectedFavorite = prefs.getString('selectedFavorite');
      final loadedIsLocked = prefs.getBool('isLocked') ?? false;

      // Load favorite labels
      List<String>? savedLabels = prefs.getStringList('favoriteLabels');
      final loadedFavoriteLabels = savedLabels ?? ["Fav 1", "Fav 2", "Fav 3"];

      // Load saved favorites
      Map<String, Map<String, dynamic>> loadedSavedFavorites = {
        "Fav 1": {},
        "Fav 2": {},
        "Fav 3": {},
      };

      String? favoritesJson = prefs.getString('savedFavorites');
      if (favoritesJson != null) {
        try {
          Map<String, dynamic> decoded = jsonDecode(favoritesJson);
          loadedSavedFavorites = decoded.map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
          );
        } catch (e) {
          // If JSON parsing fails, use default values
          debugPrint('Error parsing saved favorites: $e');
        }
      }

      // Update state safely
      if (mounted) {
        setState(() {
          isNeon = loadedIsNeon;
          brightness = loadedBrightness;
          selectedColorIndex = loadedSelectedColorIndex;
          selectedFavorite = loadedSelectedFavorite;
          isLocked = loadedIsLocked;
          favoriteLabels = loadedFavoriteLabels;
          savedFavorites = loadedSavedFavorites;

          // Set current color based on loaded state
          currentColor = currentColorSet[selectedColorIndex];
        });
      }
    } catch (e) {
      debugPrint('Error loading state: $e');
      // Continue with default values if loading fails
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save basic state
      await prefs.setBool('isNeon', isNeon);
      await prefs.setDouble('brightness', brightness);
      await prefs.setInt('selectedColorIndex', selectedColorIndex);
      await prefs.setBool('isLocked', isLocked);
      if (selectedFavorite != null) {
        await prefs.setString('selectedFavorite', selectedFavorite!);
      } else {
        await prefs.remove('selectedFavorite');
      }

      // Save favorite labels
      await prefs.setStringList('favoriteLabels', favoriteLabels);

      // Save favorites as JSON
      String favoritesJson = jsonEncode(savedFavorites);
      await prefs.setString('savedFavorites', favoritesJson);
    } catch (e) {
      debugPrint('Error saving state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentColor.withValues(alpha: brightness),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: currentColor.withValues(alpha: brightness)),
          ),

          // Lock/Unlock button in top-right corner
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(
                isLocked ? Icons.lock : Icons.lock_open,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  isLocked = !isLocked;
                });
                _saveState();
              },
            ),
          ),

          // Circular brightness slider (only show when not locked)
          if (!isLocked)
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
                      trackColor: Colors.white.withValues(alpha: 0.3),
                      dotColor: Colors.white,
                    ),
                    infoProperties: InfoProperties(
                      topLabelText: 'Brightness',
                      topLabelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      modifier: (double value) => '${value.round()}%',
                      mainLabelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onChange: (value) {
                    setState(() {
                      brightness = value / 100;
                    });
                    _saveState();
                  },
                ),
              ),
            ),

          // Bottom controls (only show when not locked)
          if (!isLocked)
            Positioned(
              bottom: 60,
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
                          _saveState();
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
                          _saveState();
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
                  _saveState();
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
            return GestureDetector(
              onLongPress: isEmpty
                  ? null
                  : () {
                      Navigator.pop(context); // Close dropdown first
                      _renameFavorite(label);
                    },
              child: ListTile(
                title: Text(label, style: const TextStyle(color: Colors.white)),
                subtitle: isEmpty
                    ? const Text(
                        "Empty",
                        style: TextStyle(color: Colors.redAccent),
                      )
                    : const Text(
                        "Tap to load • Long press to rename",
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
              ),
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
      _saveState();
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
                  // Find the index of the current label
                  int index = favoriteLabels.indexOf(label);

                  // Clear the favorite data
                  savedFavorites[label] = {};

                  // Reset the label to default name
                  if (index != -1 && index < defaultFavoriteLabels.length) {
                    String defaultLabel = defaultFavoriteLabels[index];

                    // Update the label in the list
                    favoriteLabels[index] = defaultLabel;

                    // Move the empty data to the new default key
                    savedFavorites[defaultLabel] = {};

                    // Remove the old custom name key if it's different
                    if (label != defaultLabel) {
                      savedFavorites.remove(label);
                    }

                    // Update selectedFavorite if it matches
                    if (selectedFavorite == label) {
                      selectedFavorite = null;
                    }
                  }
                });
                _saveState();
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

  void _renameFavorite(String oldLabel) {
    TextEditingController controller = TextEditingController(text: oldLabel);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rename Favorite"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Favorite Name",
              border: OutlineInputBorder(),
            ),
            maxLength: 50,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String newLabel = controller.text.trim();
                if (newLabel.isNotEmpty && newLabel != oldLabel) {
                  setState(() {
                    // Update the label in the list
                    int index = favoriteLabels.indexOf(oldLabel);
                    if (index != -1) {
                      favoriteLabels[index] = newLabel;
                    }

                    // Move the saved data to the new key
                    savedFavorites[newLabel] = savedFavorites[oldLabel]!;
                    savedFavorites.remove(oldLabel);

                    // Update selectedFavorite if it matches
                    if (selectedFavorite == oldLabel) {
                      selectedFavorite = newLabel;
                    }
                  });
                  _saveState();

                  Navigator.pop(context);

                  // Show confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Renamed to '$newLabel'"),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text("Rename"),
            ),
          ],
        );
      },
    );
  }
}
