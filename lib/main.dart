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
  int energyLevel = 50; 
  String moodIndicator = "Neutral";
  IconData moodIcon = Icons.sentiment_satisfied_alt;
  bool isNameSet = false;
  bool gameOver = false;
  bool gameWon = false;
  final TextEditingController _nameController = TextEditingController();
  late Timer _hungerTimer;
  Timer? _winTimer;
  String selectedActivity = 'Play'; 

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

  
  Color get petColor {
    if (happinessLevel > 70) {
      return Colors.green; 
    } else if (happinessLevel >= 30) {
      return Colors.yellow; 
    } else {
      return Colors.red; 
    }
  }

  
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

  
  void _performActivity() {
    switch (selectedActivity) {
      case 'Play':
        setState(() {
          happinessLevel = (happinessLevel + 10).clamp(0, 100);
          energyLevel = (energyLevel - 20).clamp(0, 100);
        });
        break;
      case 'Feed':
        setState(() {
          hungerLevel = (hungerLevel - 10).clamp(0, 100);
          happinessLevel = (happinessLevel + 10).clamp(0, 100);
          energyLevel = (energyLevel + 5).clamp(0, 100);
        });
        break;
      case 'Rest':
        setState(() {
          energyLevel = (energyLevel + 20).clamp(0, 100);
        });
        break;
    }
    _updateMood();
  }

  
  void _setPetName() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        petName = _nameController.text.trim();
        isNameSet = true;
      });
    }
  }

  
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

  void _startWinTimer() {
    _winTimer ??= Timer(const Duration(seconds: 10), () {
      if (happinessLevel > 80) {
        setState(() {
          gameWon = true;
        });
      }
    });
  }

  void _cancelWinTimer() {
    _winTimer?.cancel();
    _winTimer = null;
  }

  void _checkLossCondition() {
    if (hungerLevel == 100 && happinessLevel <= 10) {
      setState(() {
        gameOver = true;
      });
    }
  }

  void _resetGame() {
    setState(() {
      happinessLevel = 50;
      hungerLevel = 50;
      energyLevel = 50;
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
            : _buildNameInputScreen(), 
      ),
    );
  }

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
        Text('Energy Level: $energyLevel', style: const TextStyle(fontSize: 20.0)), 
        const SizedBox(height: 16.0),

        LinearProgressIndicator(
          value: energyLevel / 100, 
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),

        const SizedBox(height: 32.0),

        DropdownButton<String>(
          value: selectedActivity,
          items: <String>['Play', 'Feed', 'Rest']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedActivity = newValue!;
            });
          },
        ),

        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _performActivity,
          child: const Text('Perform Activity'),
        ),
      ],
    );
  }

  Widget _buildGameOverScreen() {
    return _buildEndScreen("Game Over!", Colors.red);
  }

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
