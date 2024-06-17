import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double totalExp = 0.0;
  String percent = "0%";
  int currentPage = 0;
  int currentLevel = 1;
  static const int tasksPerPage = 3;
  late ConfettiController _confettiController;

  final List<Map<String, dynamic>> missions = [];
  final TextEditingController _newTaskController = TextEditingController();
  double _selectedExp = 0.1;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    // Initial missions
    List<String> initialMissions = [
      "Do the laundry",
      "Cook something new",
      "Study an hour",
      "Read a book",
      "Exercise",
      "Meditate"
    ];
    for (var title in initialMissions) {
      missions.add({"title": title, "exp": 0.3, "checked": false});
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _updateTotalExp(bool checked, double exp) {
    setState(() {
      if (checked) {
        totalExp += exp;
      } else {
        totalExp -= exp;
      }
      // Ensure totalExp stays within 0.0 to 1.0
      if (totalExp < 0.0) totalExp = 0.0;
      if (totalExp > 1.0) {
        totalExp = 0.0;
        _levelUp();
      }
      percent = (totalExp * 100).toStringAsFixed(1) + '%';
    });
  }

  void _levelUp() {
    _confettiController.play();
    currentLevel++;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Level Up!"),
          ),
          body: Stack(
            children: [
              Center(
                child: Text(
                  "Congrats! You reached level $currentLevel!!!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: -pi / 2, // upwards
                  maxBlastForce: 50,
                  minBlastForce: 25,
                  emissionFrequency: 0.05,
                  numberOfParticles: 40,
                  gravity: 0.1,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.check),
          ),
        ),
      ),
    );
  }

  void _addNewTask(String title, double exp) {
    setState(() {
      missions.add({"title": title, "exp": exp, "checked": false});
      _newTaskController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = currentPage * tasksPerPage;
    int endIndex = startIndex + tasksPerPage;
    List<Map<String, dynamic>> displayedMissions = missions.sublist(
      startIndex,
      endIndex > missions.length ? missions.length : endIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            animation: true,
            radius: 100,
            lineWidth: 20,
            percent: totalExp,
            progressColor: Colors.deepPurple,
            backgroundColor: Colors.deepPurple.shade100,
            circularStrokeCap: CircularStrokeCap.round,
            center: Text(percent, style: TextStyle(fontSize: 20)),
          ),
          Card(
            margin: EdgeInsets.all(50.0),
            child: Column(
              children: displayedMissions.map((mission) {
                return Card(
                  child: CheckboxListTile(
                    title: Text(mission["title"]),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: mission["checked"],
                    onChanged: (bool? value) {
                      setState(() {
                        mission["checked"] = value ?? false;
                        _updateTotalExp(mission["checked"], mission["exp"]);
                        if (mission["checked"]) {
                          missions.remove(mission);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: currentPage > 0
                    ? () {
                        setState(() {
                          currentPage--;
                        });
                      }
                    : null,
                child: const Text("Previous"),
              ),
              ElevatedButton(
                onPressed: endIndex < missions.length
                    ? () {
                        setState(() {
                          currentPage++;
                        });
                      }
                    : null,
                child: const Text("Next"),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add New Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _newTaskController,
                      decoration: InputDecoration(hintText: "Enter task title"),
                    ),
                    DropdownButton<double>(
                      value: _selectedExp,
                      items: [
                        DropdownMenuItem(
                          value: 0.1,
                          child: Text("Easy"),
                        ),
                        DropdownMenuItem(
                          value: 0.2,
                          child: Text("Medium"),
                        ),
                        DropdownMenuItem(
                          value: 0.3,
                          child: Text("Hard"),
                        ),
                      ],
                      onChanged: (double? value) {
                        setState(() {
                          _selectedExp = value!;
                        });
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text('Add'),
                    onPressed: () {
                      _addNewTask(_newTaskController.text, _selectedExp);
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
