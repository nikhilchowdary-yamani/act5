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
  bool gameOver = false;
  bool gameWon = false;
  final TextEditingController _nameController = TextEditingController();
  late Timer _hungerTimer;
  Timer? _winTimer;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer.cancel();
    _winTimer?.cancel();
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
      if (happinessLevel > 80) {
        _startWinTimer();
      } else {
        _cancelWinTimer();
      }

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

      _checkLossCondition();
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
    if (hungerLevel >= 100) {
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

  // Start a Timer that increases hunger every 5 seconds
  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!gameOver && !gameWon) {
        setState(() {
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
          if (hungerLevel > 100) {
            hungerLevel = 100;
            happinessLevel = (happinessLevel - 20).clamp(0, 100);
          }
          _updateMood();
        });
      }
    });
  }

  // Win Condition: Happiness remains above 80 for 10 seconds
  void _startWinTimer() {
    _winTimer ??= Timer(const Duration(seconds: 10), () {
      if (happinessLevel > 80) {
        setState(() {
          gameWon = true;
        });
      }
    });
  }

  // Cancel win timer if happiness drops below 80
  void _cancelWinTimer() {
    _winTimer?.cancel();
    _winTimer = null;
  }

  // Loss Condition: Hunger = 100 and Happiness = 10
  void _checkLossCondition() {
    if (hungerLevel == 100 && happinessLevel <= 10) {
      setState(() {
        gameOver = true;
      });
    }
  }

  // Reset game after win/loss
  void _resetGame() {
    setState(() {
      happinessLevel = 50;
      hungerLevel = 50;
      gameOver = false;
      gameWon = false;
      _cancelWinTimer();
      _startHungerTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Pet')),
      body: Center(
        child: isNameSet
            ? _buildGameUI()
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
            decoration: const InputDecoration(
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

  // Main Game UI
  Widget _buildGameUI() {
    if (gameOver) {
      return _buildGameOverScreen();
    } else if (gameWon) {
      return _buildWinScreen();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Name: $petName', style: const TextStyle(fontSize: 20.0)),
        const SizedBox(height: 16.0),

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
        Text('$moodIndicator', style: TextStyle(fontSize: 30, color: petColor)),
        Icon(moodIcon, color: petColor, size: 30),

        const SizedBox(height: 16.0),
        Text('Happiness Level: $happinessLevel', style: const TextStyle(fontSize: 20.0)),
        Text('Hunger Level: $hungerLevel', style: const TextStyle(fontSize: 20.0)),
        const SizedBox(height: 32.0),

        ElevatedButton(onPressed: _playWithPet, child: const Text('Play with Your Pet')),
        const SizedBox(height: 16.0),
        ElevatedButton(onPressed: _feedPet, child: const Text('Feed Your Pet')),
      ],
    );
  }

  // Game Over Screen
  Widget _buildGameOverScreen() {
    return _buildEndScreen("Game Over!", Colors.red);
  }

  // Win Screen
  Widget _buildWinScreen() {
    return _buildEndScreen("You Win!", Colors.green);
  }

  Widget _buildEndScreen(String message, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message, style: TextStyle(fontSize: 30, color: color)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _resetGame, child: const Text("Restart")),
      ],
    );
  }
}
