// lib

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart'; // Asegúrate de que 'database_helper.dart' está correctamente configurado

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  late Future<Map<String, int>> _studentCountsByCourse;

  @override
  void initState() {
    super.initState();
    _studentCountsByCourse = _fetchStudentCountsByCourse();
  }

  Future<Map<String, int>> _fetchStudentCountsByCourse() async {
    final students = await DatabaseHelper().getAllStudents();
    final Map<String, int> counts = {};

    for (var student in students) {
      final course = student['course'] ?? 'Desconocido';
      if (counts.containsKey(course)) {
        counts[course] = counts[course]! + 1;
      } else {
        counts[course] = 1;
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Estudiantes'),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _studentCountsByCourse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay datos disponibles.'));
          } else {
            final data = snapshot.data!;
            final List<BarChartGroupData> barGroups = data.entries.map((entry) {
              final int index = data.keys.toList().indexOf(entry.key);
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.toDouble(),
                    color: Colors.blue,
                    width: 16,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              );
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int index = value.toInt();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(data.keys.elementAt(index)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

