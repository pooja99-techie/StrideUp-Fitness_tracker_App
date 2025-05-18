// // File: lib/widgets/meal_list_item.dart
//
// import 'package:flutter/material.dart';
// import '../../models/meal_models.dart';
// // You might need to import a helper for formatting dates if you want something nicer
// import 'package:intl/intl.dart'; // Add intl dependency to pubspec.yaml if needed
//
// class MealListItem extends StatelessWidget {
//   final Meal meal;
//   final VoidCallback onEdit; // Callback for when edit is pressed
//   final VoidCallback onDelete; // Callback for when delete is pressed
//
//   const MealListItem({
//     Key? key,
//     required this.meal,
//     required this.onEdit,
//     required this.onDelete,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Using Card for a nice visual separation
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//       elevation: 2.0, // Subtle shadow
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Meal Type and Actions
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded( // Use Expanded so the text doesn't overflow
//                   child: Text(
//                     meal.type,
//                     style: TextStyle(
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).primaryColor, // Use theme color
//                     ),
//                     overflow: TextOverflow.ellipsis, // Prevent overflow
//                   ),
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.min, // Don't take up extra space
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.edit, size: 20),
//                       color: Colors.blueGrey, // A neutral color
//                       onPressed: onEdit,
//                       tooltip: 'Edit Meal',
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete, size: 20),
//                       color: Colors.redAccent, // Indicate destructive action
//                       onPressed: onDelete,
//                       tooltip: 'Delete Meal',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4.0), // Small vertical space
//
//             // Date and Time
//             Text(
//               DateFormat('yyyy-MM-dd HH:mm').format(meal.dateTime), // Format the date nicely
//               style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 8.0),
//
//             // Calories Summary
//             Text(
//               '${meal.totalCalories.toStringAsFixed(0)} Calories', // Show total calories, no decimals
//               style: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.green[700], // A color often associated with health/energy
//               ),
//             ),
//             const SizedBox(height: 8.0),
//
//             // Food Items List (Optional: Display individual items)
//             // You could add a ListView.builder here if you want to show all food items within the list item.
//             // For simplicity in this example, we'll just show the total calories.
//             // If you add it, make sure to use physics: NeverScrollableScrollPhysics() and shrinkWrap: true
//             // to prevent scrolling conflicts within the main list.
//             // Example:
//             // if (meal.foodItems.isNotEmpty) {
//             //   Column(
//             //     crossAxisAlignment: CrossAxisAlignment.start,
//             //     children: [
//             //       Text("Items:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//             //       ...meal.foodItems.map((item) => Text("- ${item.name} (${item.calories.toStringAsFixed(0)} kcal)")).toList(),
//             //     ],
//             //   ),
//             // }
//           ],
//         ),
//       ),
//     );
//   }
// }
