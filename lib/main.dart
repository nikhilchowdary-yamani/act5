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
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;

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

  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
    });
  }

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    setState(() {
      happinessLevel = (hungerLevel < 30)
          ? (happinessLevel - 20).clamp(0, 100)
          : (happinessLevel + 10).clamp(0, 100);
    });
  }

  // Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    setState(() {
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      if (hungerLevel > 100) {
        hungerLevel = 100;
        happinessLevel = (happinessLevel - 20).clamp(0, 100);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet')),
      body: Center(
        child: Column(
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
        ),
      ),
    );
  }
}
