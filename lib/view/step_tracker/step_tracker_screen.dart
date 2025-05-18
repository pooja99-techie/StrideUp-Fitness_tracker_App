// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pedometer/pedometer.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'dart:async';
//
//
// import '../../models/step_data.dart';
//
// class StepTrackerScreen extends StatefulWidget {
//   const StepTrackerScreen({Key? key}) : super(key: key);
//
//   @override
//   State<StepTrackerScreen> createState() => _StepTrackerScreenState();
// }
//
// class _StepTrackerScreenState extends State<StepTrackerScreen> {
//   late Stream<StepCount> _stepCountStream;
//   late Stream<PedestrianStatus> _pedestrianStatusStream;
//   String _status = 'Unknown';
//   int _steps = 0;
//   int _targetSteps = 10000;
//   bool _isPermissionGranted = false;
//
//   // Store historical step data - we'll use a list of (hour, steps) pairs
//   final List<StepData> _stepData = [];
//
//   // Controllers for updating UI
//   final StreamController<int> _stepsController = StreamController<int>.broadcast();
//   final StreamController<List<StepData>> _stepDataController = StreamController<List<StepData>>.broadcast();
//
//   @override
//   void initState() {
//     super.initState();
//     _initPlatformState();
//     _loadTargetSteps();
//     _initStepData();
//   }
//
//   Future<void> _loadTargetSteps() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _targetSteps = prefs.getInt('targetSteps') ?? 10000;
//     });
//   }
//
//   Future<void> _saveTargetSteps(int steps) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('targetSteps', steps);
//     setState(() {
//       _targetSteps = steps;
//     });
//   }
//
//   void _initStepData() {
//     // For demonstration purposes, initialize with some sample data
//     // In a real app, this would be loaded from persistent storage
//     final now = DateTime.now();
//
//     // Generate step data for the last 7 hours
//     for (int i = 6; i >= 0; i--) {
//       final hour = now.hour - i;
//       if (hour >= 0) {
//         _stepData.add(StepData(hour, 500 + (1000 * (6-i))));
//       } else {
//         _stepData.add(StepData(24 + hour, 500 + (1000 * (6-i))));
//       }
//     }
//
//     // Notify listeners of the new data
//     _stepDataController.add(_stepData);
//   }
//
//   void _onStepCount(StepCount event) {
//     setState(() {
//       _steps = event.steps;
//       _stepsController.add(_steps);
//
//       // Update the step data for the current hour
//       final now = DateTime.now();
//       final currentHour = now.hour;
//
//       bool hourExists = false;
//       for (int i = 0; i < _stepData.length; i++) {
//         if (_stepData[i].hour == currentHour) {
//           _stepData[i] = StepData(currentHour, _steps);
//           hourExists = true;
//           break;
//         }
//       }
//
//       if (!hourExists) {
//         // Add new hour data and ensure we keep only the last 7 entries
//         _stepData.add(StepData(currentHour, _steps));
//         if (_stepData.length > 7) {
//           _stepData.removeAt(0);
//         }
//       }
//
//       // Notify listeners of the updated data
//       _stepDataController.add(_stepData);
//     });
//   }
//
//   void _onPedestrianStatusChanged(PedestrianStatus event) {
//     setState(() {
//       _status = event.status;
//     });
//   }
//
//   void _onPedestrianStatusError(error) {
//     setState(() {
//       _status = 'Pedestrian Status Error: $error';
//     });
//   }
//
//   void _onStepCountError(error) {
//     setState(() {
//       _steps = 0;
//       _stepsController.add(_steps);
//     });
//   }
//
//   Future<void> _initPlatformState() async {
//     // Request permissions
//     if (await _requestPermission()) {
//       _setupPedometer();
//     } else {
//       setState(() {
//         _status = 'Permission denied';
//       });
//     }
//   }
//
//   Future<bool> _requestPermission() async {
//     final status = await Permission.activityRecognition.request();
//     setState(() {
//       _isPermissionGranted = status.isGranted;
//     });
//     return status.isGranted;
//   }
//
//   void _setupPedometer() {
//     _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
//     _pedestrianStatusStream
//         .listen(_onPedestrianStatusChanged)
//         .onError(_onPedestrianStatusError);
//
//     _stepCountStream = Pedometer.stepCountStream;
//     _stepCountStream
//         .listen(_onStepCount)
//         .onError(_onStepCountError);
//   }
//
//   void _showTargetStepsDialog() {
//     int tempTargetSteps = _targetSteps;
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Set Target Steps'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('Enter your custom target steps (1,000-20,000):'),
//               const SizedBox(height: 16),
//               TextField(
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                 ],
//                 onChanged: (value) {
//                   if (value.isNotEmpty) {
//                     tempTargetSteps = int.parse(value);
//                   }
//                 },
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: 'Enter target steps',
//                 ),
//                 controller: TextEditingController(text: _targetSteps.toString()),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (tempTargetSteps >= 1000 && tempTargetSteps <= 20000) {
//                   _saveTargetSteps(tempTargetSteps);
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Please enter a value between 1,000 and 20,000'),
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Step Tracker'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: _showTargetStepsDialog,
//           ),
//         ],
//       ),
//       body: _isPermissionGranted
//           ? _buildStepTrackerContent()
//           : _buildPermissionRequest(),
//     );
//   }
//
//   Widget _buildPermissionRequest() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             'This app needs activity recognition permission to track steps.',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () async {
//               if (await _requestPermission()) {
//                 _setupPedometer();
//               }
//             },
//             child: const Text('Grant Permission'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStepTrackerContent() {
//     return StreamBuilder<int>(
//       stream: _stepsController.stream,
//       initialData: _steps,
//       builder: (context, snapshot) {
//         final steps = snapshot.data ?? 0;
//         final progress = steps / _targetSteps;
//
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Steps overview card
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       const Text(
//                         'Today',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         '$steps',
//                         style: const TextStyle(
//                           fontSize: 48,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Text(
//                         'steps',
//                         style: TextStyle(
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // Progress bar
//                       LinearProgressIndicator(
//                         value: progress.clamp(0.0, 1.0),
//                         backgroundColor: Colors.grey[300],
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           progress >= 1.0 ? Colors.green : Colors.blue,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Goal: $_targetSteps steps',
//                         style: const TextStyle(
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//               const Text(
//                 'History',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//
//               // Step count graph
//               Expanded(
//                 child: _buildStepCountGraph(),
//               ),
//
//               // Status indicator
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Text(
//                   'Status: $_status',
//                   style: TextStyle(
//                     color: _status == 'walking' ? Colors.green : Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildStepCountGraph() {
//     return StreamBuilder<List<StepData>>(
//       stream: _stepDataController.stream,
//       initialData: _stepData,
//       builder: (context, snapshot) {
//         final data = snapshot.data ?? [];
//         if (data.isEmpty) {
//           return const Center(child: Text('No step data available'));
//         }
//
//         // Find the maximum step count for scaling
//         final maxSteps = data.map((e) => e.steps).reduce((a, b) => a > b ? a : b);
//
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: BarChart(
//             BarChartData(
//               alignment: BarChartAlignment.spaceAround,
//               maxY: maxSteps * 1.2,
//               barTouchData: BarTouchData(
//                 enabled: true,
//                 touchTooltipData: BarTouchTooltipData(
//                   tooltipBgColor: Colors.blueAccent,
//                   getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                     return BarTooltipItem(
//                       '${data[groupIndex].steps} steps',
//                       const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               titlesData: FlTitlesData(
//                 show: true,
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       final hour = data[value.toInt()].hour;
//                       return Text(
//                         '${hour}:00',
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       );
//                     },
//                     reservedSize: 30,
//                   ),
//                 ),
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     getTitlesWidget: (value, meta) {
//                       if (value == 0) {
//                         return const Text('0');
//                       }
//
//                       if (value % (maxSteps / 5).round() == 0) {
//                         return Text(
//                           '${value.toInt()}',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         );
//                       }
//                       return const Text('');
//                     },
//                     reservedSize: 40,
//                   ),
//                 ),
//                 rightTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: false,
//                   ),
//                 ),
//                 topTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: false,
//                   ),
//                 ),
//               ),
//               gridData: FlGridData(
//                 show: true,
//                 horizontalInterval: maxSteps / 5,
//                 getDrawingHorizontalLine: (value) {
//                   return FlLine(
//                     color: Colors.grey.withOpacity(0.3),
//                     strokeWidth: 1,
//                   );
//                 },
//               ),
//               borderData: FlBorderData(
//                 show: false,
//               ),
//               barGroups: data.asMap().entries.map((entry) {
//                 final index = entry.key;
//                 final stepData = entry.value;
//
//                 return BarChartGroupData(
//                   x: index,
//                   barRods: [
//                     BarChartRodData(
//                       toY: stepData.steps.toDouble(),
//                       color: Colors.blue,
//                       width: 20,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(6),
//                         topRight: Radius.circular(6),
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _stepsController.close();
//     _stepDataController.close();
//     super.dispose();
//   }
// }