// // File: lib/widgets/meal_form_screen.dart
// // This file will contain the widget for adding/editing a meal.
//
// import 'package:flutter/material.dart';
// import '../../models/meal_models.dart';
// import '../../services/meal_service.dart';
//
//
// // You could use this function signature for showing a form dialog
// Future<void> showMealFormDialog({
//   required BuildContext context,
//   Meal? mealToEdit, // Pass null for adding, pass Meal object for editing
//   required MealService mealService, // Pass your service instance
// }) async {
//   // TODO: Implement the actual form UI here (e.g., using AlertDialog or showModalBottomSheet)
//
//   // Inside the form:
//   // - Dropdown for Meal Type (Breakfast, Lunch, Snacks, Dinner)
//   // - Date and Time pickers
//   // - A list or section to add Food Items (Name, Calories, Quantity)
//   // - Buttons to add/remove food items from the list
//   // - A Save button
//
//   // Example form data (replace with actual form field values)
//   String selectedMealType = mealToEdit?.type ?? 'Breakfast'; // Default or existing type
//   DateTime selectedDateTime = mealToEdit?.dateTime ?? DateTime.now(); // Default or existing date/time
//   List<FoodItem> foodItemsList = mealToEdit?.foodItems ?? []; // Default or existing items
//
//   // When the user clicks 'Save':
//   // Create a new Meal object or update the existing one
//   Meal mealToSave = Meal(
//     id: mealToEdit?.id, // Keep ID if editing
//     type: selectedMealType,
//     dateTime: selectedDateTime,
//     foodItems: foodItemsList, // Get items from your form's state
//   );
//
//   // Call the appropriate service method
//   try {
//     if (mealToEdit == null) {
//       // Add new meal
//       await mealService.addMeal(mealToSave);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meal added!')));
//     } else {
//       // Update existing meal
//       await mealService.updateMeal(mealToSave); // Ensure mealToSave has the ID
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meal updated!')));
//     }
//     Navigator.of(context).pop(); // Close the dialog/screen on success
//   } catch (e) {
//     print('Error saving meal: $e');
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save meal: $e')));
//     // Optionally, don't pop if there's an error, let the user fix it
//   }
//
//   // This is just a conceptual outline. You will need to build the actual form widget.
//   // For a simple start, you could use a few TextFormField and hardcode one food item field.
//   // For adding multiple food items dynamically, you'd need a more complex stateful form.
// }
//
// // You might also define a full StatefulWidget class here for the form if using navigation
// /*
// class MealFormScreen extends StatefulWidget {
//   final Meal? mealToEdit; // Null for add, Meal object for edit
//   final MealService mealService; // Pass the service
//
//   const MealFormScreen({Key? key, this.mealToEdit, required this.mealService}) : super(key: key);
//
//   @override
//   _MealFormScreenState createState() => _MealFormScreenState();
// }
//
// class _MealFormScreenState extends State<MealFormScreen> {
//   // Form state variables and controllers
//   // ... build the form UI ...
//   // On save button press, call widget.mealService.addMeal or updateMeal
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.mealToEdit == null ? 'Add Meal' : 'Edit Meal'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           // Your form widgets here
//           // e.g., DropdownButton for type, DateTime pickers, list of FoodItem forms
//           child: Column(
//             children: [
//               // ... form fields ...
//               ElevatedButton(
//                 onPressed: _saveMeal, // Implement this method
//                 child: Text('Save Meal'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Method to handle saving the meal
//   void _saveMeal() async {
//      // Get data from form fields
//      // Build Meal object
//      // Call widget.mealService.addMeal or updateMeal
//      // Handle success/failure (e.g., show SnackBar, pop screen)
//   }
// }
// */
