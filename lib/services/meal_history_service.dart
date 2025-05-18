// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../models/meal_models.dart';
// import 'meal_service.dart';
//
// class MealHistoryScreen extends StatelessWidget {
//   const MealHistoryScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final mealService = MealService();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Meal History'),
//       ),
//       body: StreamBuilder<List<Meal>>(
//         stream: mealService.getMealsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final meals = snapshot.data ?? [];
//
//           if (meals.isEmpty) {
//             return const Center(child: Text('No meals recorded yet'));
//           }
//
//           return ListView.builder(
//             itemCount: meals.length,
//             itemBuilder: (context, index) {
//               final meal = meals[index];
//               return Card(
//                 margin: const EdgeInsets.all(8),
//                 child: ExpansionTile(
//                   title: Text(
//                     '${meal.mealType} - ${DateFormat('MMM dd, yyyy').format(meal.dateTime)}',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text('Total Calories: ${meal.totalCalories}'),
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Time: ${DateFormat('hh:mm a').format(meal.dateTime)}',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             'Food Items:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           ...meal.foodItems.map<Widget>((item) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 4.0),
//                               child: Text(
//                                 '- ${item.name} (${item.calories} cal × ${item.quantity})',
//                               ),
//                             );
//                           }).toList(),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () async {
//                                   if (meal.id != null) {
//                                     try {
//                                       await mealService.deleteMeal(meal.id!);
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         const SnackBar(
//                                           content: Text('Meal deleted'),
//                                           backgroundColor: Colors.red,
//                                         ),
//                                       );
//                                     } catch (e) {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text('Error deleting meal: $e'),
//                                           backgroundColor: Colors.red,
//                                         ),
//                                       );
//                                     }
//                                   }
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }