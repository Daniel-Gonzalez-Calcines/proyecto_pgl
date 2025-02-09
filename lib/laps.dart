// ignore_for_file: file_names, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'dart:convert'; // For jsonDecode

class Players {
  final String nombre;
  final String coche;
  final String skin;

  Players(this.nombre, this.coche, this.skin);
}

class BestLaps {
  final int nombre;
  final int tiempo;
  final int vuelta;

  BestLaps(this.nombre, this.tiempo, this.vuelta);
}

class Laps {
  final int lap;
  final int car;
  final List<int> sectors;
  final int time;

  Laps(this.car, this.lap, this.sectors, this.time);
}

class LapsScreen extends StatefulWidget {
  final int currentsession;

  const LapsScreen({super.key, required this.currentsession});

  @override
  // ignore: library_private_types_in_public_api
  _LapsScreenState createState() => _LapsScreenState();
}

class _LapsScreenState extends State<LapsScreen> {
  List<Players> _players = [];
  List<BestLaps> _bestLaps = [];
  List<dynamic> _sessions = [];
  List<Laps> _laps = [];

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
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
      _bestLaps = (_sessions[widget.currentsession]['bestLaps'] as List)
          .map((bestlap) => BestLaps(
                bestlap['car'],
                bestlap['time'],
                bestlap['lap'],
              ))
          .toList();
      _laps = (_sessions[widget.currentsession]['laps'] as List)
          .map((lap) => Laps(
                lap['car'],
                lap['lap'],
                (lap['sectors'] as List)
                    .map((sector) => sector as int)
                    .toList(),
                lap['time'],
              ))
          .toList();
      _bestLaps.sort((a, b) => a.tiempo.compareTo(b.tiempo));
    });
  }

  Future<Map<String, dynamic>> loadJsonFromAssets(String filePath) async {
    String jsonString = await rootBundle.loadString(filePath);
    return jsonDecode(jsonString);
  }

  Widget finddriver(int numero) {
    String nombre = _players[numero].nombre;

    return Text(nombre);
  }

  Widget formattime(int milliseconds) {
    Duration duration = Duration(milliseconds: milliseconds);

    String formattedTime;
    if (duration.inHours > 0) {
      formattedTime =
          '${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}.${(duration.inMilliseconds.remainder(1000)).floor().toString().padLeft(3, '0')}';
    } else if (duration.inMinutes > 0) {
      formattedTime =
          '${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}.${(duration.inMilliseconds.remainder(1000)).floor().toString().padLeft(3, '0')}';
    } else {
      formattedTime =
          '${duration.inSeconds}.${(duration.inMilliseconds.remainder(1000)).floor().toString().padLeft(3, '0')}';
    }

    return Text(formattedTime);
  }

  Widget findSectorTime(int time, int sector, int nombre) {
    if (_laps.isNotEmpty) {
      try {
        final lap = _laps.firstWhere(
          (lap) => lap.time == time && lap.car == nombre,
        );

        if (sector < 0 || sector >= lap.sectors.length) {
          return Text("Invalid sector index");
        }

        return formattime(lap.sectors[sector]);
      } catch (e) {
        return Text("Lap not found");
      }
    }

    return Text("No data");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
            "Mejores vueltas de ${_sessions[widget.currentsession]['name']}"),
      ),
      body: Center(
        child: _players.isEmpty
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Atrás'),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection:
                            Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Posición')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Sector 1')),
                            DataColumn(label: Text('Sector 2')),
                            DataColumn(label: Text('Sector 3')),
                            DataColumn(label: Text('Tiempo')),
                            DataColumn(label: Text('Vuelta')),
                          ],
                          rows: _bestLaps.asMap().entries.map((entry) {
                            int index = entry.key;
                            var bestlap = entry.value;
                            return DataRow(
                              color: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  return index.isEven
                                      ? Colors.red.shade100
                                      : Colors.white;
                                },
                              ),
                              cells: [
                                DataCell(Text((index + 1).toString())),
                                DataCell(finddriver(bestlap.nombre)),
                                DataCell(findSectorTime(
                                    bestlap.tiempo, 0, bestlap.nombre)),
                                DataCell(findSectorTime(
                                    bestlap.tiempo, 1, bestlap.nombre)),
                                DataCell(findSectorTime(
                                    bestlap.tiempo, 2, bestlap.nombre)),
                                DataCell(formattime(bestlap.tiempo)),
                                DataCell(Text((bestlap.vuelta + 1).toString())),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
