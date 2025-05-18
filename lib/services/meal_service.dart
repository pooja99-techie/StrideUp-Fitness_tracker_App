import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal_models.dart';

class MealService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addMeal(Meal meal) async {
    // Get the current user
    User? user = _auth.currentUser ;

    if (user == null) {
      throw Exception('User  not logged in');
    }

    // Create a new meal document in Firestore
    await _firestore.collection('users').doc(user.uid).collection('meals').add({
      'mealType': meal.mealType,
      'dateTime': meal.dateTime,
      'foodItems': meal.foodItems.map((item) => {
        'name': item.name,
        'calories': item.calories,
        'quantity': item.quantity,
      }).toList(),
      'totalCalories': meal.totalCalories,
    });
  }
}