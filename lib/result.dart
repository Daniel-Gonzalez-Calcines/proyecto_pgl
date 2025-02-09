// ignore_for_file: file_names, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

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

class Result extends StatefulWidget {
  final int currentsession;

  const Result({super.key, required this.currentsession});

  @override
  // ignore: library_private_types_in_public_api
  _Result createState() => _Result();
}

class _Result extends State<Result> {
  List<Players> _players = [];
  List<dynamic> _sessions = [];
  List<BestLaps> _bestLaps = [];
  List<Laps> _laps = [];
  List<dynamic> _result = [];

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
      _result =
          (_sessions[widget.currentsession]['raceResult'] as List<dynamic>)
              .map((result) => result)
              .toList();
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

  Widget gettotaltime(int player) {
    int totalTime = 0;
    for (var lap in _laps) {
      if (lap.car == player) {
        totalTime += lap.time;
      }
    }
    return formattime(totalTime);
  }

  Widget gettotallaps(int player) {
    int totallaps = 0;
    for (var lap in _laps) {
      if (lap.car == player) {
        totallaps++;
      }
    }
    return Text('$totallaps');
  }

  Widget findbestlap(int player) {
    if (_bestLaps.isNotEmpty) {
      try {
        final lap = _bestLaps.firstWhere(
          (lap) => lap.nombre == player,
        );

        return formattime(lap.tiempo);
      } catch (e) {
        return Text("Lap not found");
      }
    }

    return Text("No data");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Resultado de ${_sessions[widget.currentsession]['name']}"),
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
                            DataColumn(label: Text('Mejor Vuelta')),
                            DataColumn(label: Text('Tiempo Total')),
                            DataColumn(label: Text('Vueltas')),
                          ],
                          rows: _result.asMap().entries.map((entry) {
                            int index = entry.key;
                            var player = entry.value;
                            return DataRow(
                              color: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  return index.isEven
                                      ? Colors.red.shade100
                                      : Colors.white;
                                },
                              ),
                              cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(finddriver(player)),
                                DataCell(findbestlap(player)),
                                DataCell(gettotaltime(player)),
                                DataCell(gettotallaps(player)),
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
