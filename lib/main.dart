// Nikhil Chowdary Yamani
// Bharath Kumar Ashapu
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  const DigitalPetApp({super.key});

  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "";
  int happinessLevel = 50;
  int hungerLevel = 50;
  String moodIndicator = "Neutral";
  IconData moodIcon = Icons.sentiment_satisfied_alt;
  bool isNameSet = false;
  final TextEditingController _nameController = TextEditingController();
  late Timer _hungerTimer;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer.cancel();
    super.dispose();
  }

  // Determine pet color based on happiness level
  Color get petColor {
    if (happinessLevel > 70) {
      return Colors.green; // Happy
    } else if (happinessLevel >= 30) {
      return Colors.yellow; // Neutral
    } else {
      return Colors.red; // Unhappy
    }
  }

  // Update mood indicator and icon
  void _updateMood() {
    setState(() {
      if (happinessLevel > 70) {
        moodIndicator = "Happy";
        moodIcon = Icons.sentiment_satisfied_alt;
      } else if (happinessLevel >= 30) {
        moodIndicator = "Neutral";
        moodIcon = Icons.sentiment_satisfied;
      } else {
        moodIndicator = "Unhappy";
        moodIcon = Icons.sentiment_very_dissatisfied;
      }
    });
  }

  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      _updateMood();
    });
  }

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      _updateMood();
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    happinessLevel = (hungerLevel < 30)
        ? (happinessLevel - 20).clamp(0, 100)
        : (happinessLevel + 10).clamp(0, 100);
  }

  // Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  // Set the pet name and proceed to the main UI
  void _setPetName() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        petName = _nameController.text.trim();
        isNameSet = true;
      });
    }
  }

  // Start a Timer that increases hunger every 30 seconds
  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        if (hungerLevel > 100) {
          hungerLevel = 100;
          happinessLevel = (happinessLevel - 20).clamp(0, 100);
        }
        _updateMood();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet')),
      body: Center(
        child: isNameSet
            ? _buildPetUI()
            : _buildNameInputScreen(), // Show name input first
      ),
    );
  }

  // UI for setting the pet's name
  Widget _buildNameInputScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Enter your pet's name:",
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Pet's Name",
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _setPetName,
          child: const Text("Set Name"),
        ),
      ],
    );
  }

  // Main Pet UI
  Widget _buildPetUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Name: $petName', style: const TextStyle(fontSize: 20.0)),
        const SizedBox(height: 16.0),

        // Pet Representation as a Circle with Dynamic Color
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: petColor,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              moodIndicator,
              style: TextStyle(
                fontSize: 30,
                color: petColor,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              moodIcon,
              color: petColor,
              size: 30,
            ),
          ],
        ),

        const SizedBox(height: 16.0),
        Text('Happiness Level: $happinessLevel',
            style: const TextStyle(fontSize: 20.0)),
        const SizedBox(height: 16.0),
        Text('Hunger Level: $hungerLevel',
            style: const TextStyle(fontSize: 20.0)),
        const SizedBox(height: 32.0),

        // Play and Feed Buttons
        ElevatedButton(
          onPressed: _playWithPet,
          child: const Text('Play with Your Pet'),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _feedPet,
          child: const Text('Feed Your Pet'),
        ),
      ],
    );
  }
}
