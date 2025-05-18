import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String? id; // Will be null for new meals, populated when fetched from Firestore
  final String mealType;
  final DateTime dateTime;
  final List<FoodItem> foodItems;
  final int totalCalories;

  Meal({
    this.id,
    required this.mealType,
    required this.dateTime,
    required this.foodItems,
    required this.totalCalories,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'mealType': mealType,
      'dateTime': dateTime,
      'foodItems': foodItems.map((item) => item.toMap()).toList(),
      'totalCalories': totalCalories,
    };
  }

  // Create from Firestore document
  factory Meal.fromMap(Map<String, dynamic> map, {String? id}) {
    return Meal(
      id: id,
      mealType: map['mealType'] as String,
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      foodItems: (map['foodItems'] as List)
          .map((item) => FoodItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalCalories: map['totalCalories'] as int,
    );
  }
}

class FoodItem {
  final String name;
  final int calories;
  final int quantity;

  FoodItem({
    required this.name,
    required this.calories,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'quantity': quantity,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] as String,
      calories: map['calories'] as int,
      quantity: map['quantity'] as int,
    );
  }
}