// Add this import
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:strideup_fitness_app/view/water_intake/water_ui.dart';

// Enum to switch between view modes
enum GraphViewMode { week, month }

class WaterGraphScreen extends StatefulWidget {
  final List<WaterIntake> waterIntakeHistory;

  WaterGraphScreen({required this.waterIntakeHistory});

  @override
  _WaterGraphScreenState createState() => _WaterGraphScreenState();
}

class _WaterGraphScreenState extends State<WaterGraphScreen> {
  GraphViewMode _viewMode = GraphViewMode.week;

  List<FlSpot> _getGraphData() {
    if (_viewMode == GraphViewMode.week) {
      // last 7 days
      return List.generate(7, (index) {
        final day = DateTime.now().subtract(Duration(days: 6 - index));
        final total = widget.waterIntakeHistory
            .where((entry) => entry.time.day == day.day && entry.time.month == day.month)
            .fold<double>(0.0, (sum, entry) => sum + entry.amount);
        return FlSpot(index.toDouble(), total);
      });
    } else {
      // last 30 days
      return List.generate(30, (index) {
        final day = DateTime.now().subtract(Duration(days: 29 - index));
        final total = widget.waterIntakeHistory
            .where((entry) => entry.time.day == day.day && entry.time.month == day.month)
            .fold<double>(0.0, (sum, entry) => sum + entry.amount);
        return FlSpot(index.toDouble(), total);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Hydration Stats"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [_viewMode == GraphViewMode.week, _viewMode == GraphViewMode.month],
              onPressed: (index) {
                setState(() {
                  _viewMode = index == 0 ? GraphViewMode.week : GraphViewMode.month;
                });
              },
              children: [
                Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('WEEK')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('MONTH')),
              ],
            ),
            SizedBox(height: 16),
            Text("Hydrate %",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: true),
                      titlesData: FlTitlesData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getGraphData(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
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
