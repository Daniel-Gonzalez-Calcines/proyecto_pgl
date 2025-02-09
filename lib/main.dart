import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:proyecto_pgl/allLaps.dart';
import 'package:proyecto_pgl/result.dart';
import 'laps.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade900),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ASSETTO CORSA RESULT FILE READER'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Players {
  final String nombre;
  final String coche;
  final String skin;

  Players(this.nombre, this.coche, this.skin);
}

class _MyHomePageState extends State<MyHomePage> {
  List<Players> _players = [];
  List<dynamic> _sessions = [];
  int numbersessions = 0;

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final data = await loadJsonFromAssets('assets/Carrera1.json');
    setState(() {
      _players = (data['players'] as List)
          .map((player) => Players(
                player['name'],
                player['car'],
                player['skin'],
              ))
          .toList();
      _sessions = data['sessions'];
      numbersessions = _sessions.length;
    });
  }

  Future<Map<String, dynamic>> loadJsonFromAssets(String filePath) async {
    String jsonString = await rootBundle.loadString(filePath);
    return jsonDecode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _players.isEmpty
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        ...List.generate(numbersessions, (index) {
                          if (_sessions[index]['raceResult'] != null &&
                              _sessions[index]['raceResult'].isNotEmpty) {
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LapsScreen(currentsession: index),
                                  ),
                                );
                              },
                              child: Text(
                                  'Mejores Vueltas de ${_sessions[index]['name']}'),
                            );
                          } else {
                            return Container();
                          }
                        }),
                        ...List.generate(numbersessions, (index) {
                          return ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AllLaps(currentsession: index),
                                ),
                              );
                            },
                            child: Text(
                                'Todas las vueltas de ${_sessions[index]['name']}'),
                          );
                        }),
                        ...List.generate(numbersessions, (index) {
                          if (_sessions[index]['raceResult'] != null &&
                              _sessions[index]['raceResult'].isNotEmpty) {
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Result(currentsession: index),
                                  ),
                                );
                              },
                              child: Text(
                                  'Resultado de ${_sessions[index]['name']}'),
                            );
                          } else {
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LapsScreen(currentsession: index),
                                  ),
                                );
                              },
                              child: Text(
                                  'Resultado de ${_sessions[index]['name']}'),
                            );
                          }
                        }),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis
                          .horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Coche')),
                          DataColumn(label: Text('Skin')),
                        ],
                        rows: _players.asMap().entries.map((entry) {
                          int index = entry.key;
                          var player = entry.value;
                          return DataRow(
                            color: index.isEven
                                ? WidgetStateProperty.all(Colors.red.shade100)
                                : WidgetStateProperty.all(Colors.white),
                            cells: [
                              DataCell(Text(player.nombre)),
                              DataCell(Text(player.coche)),
                              DataCell(Text(player.skin)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
