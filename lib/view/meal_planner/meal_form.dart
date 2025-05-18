import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/meal_models.dart';
import '../../services/meal_service.dart';

void main() {
  runApp(const MealTrackerApp());
}

class MealTrackerApp extends StatelessWidget {
  const MealTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MealTrackerForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}



class MealTrackerForm extends StatefulWidget {
  const MealTrackerForm({Key? key}) : super(key: key);

  @override
  _MealTrackerFormState createState() => _MealTrackerFormState();
}

class _MealTrackerFormState extends State<MealTrackerForm> {
  final _formKey = GlobalKey<FormState>();
  final MealService _mealService = MealService(); // Add MealService instance


  // Form field controllers
  final _dishNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _quantityController = TextEditingController();

  // Dropdown and selection values
  String _selectedMealType = 'Breakfast';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

  // Date and time
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // List of food items
  List<FoodItem> _foodItems = [];

  // Focus node to manage keyboard
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _dishNameController.dispose();
    _caloriesController.dispose();
    _quantityController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addFoodItem() {
    if (_dishNameController.text.isEmpty ||
        _caloriesController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _foodItems.add(
        FoodItem(
          name: _dishNameController.text,
          calories: int.parse(_caloriesController.text),
          quantity: int.parse(_quantityController.text),
        ),
      );

      // Clear the fields after adding
      _dishNameController.clear();
      _caloriesController.clear();
      _quantityController.clear();

      // Return focus to dish name field
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _removeFoodItem(int index) {
    setState(() {
      _foodItems.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMeal() async {
    if (_foodItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one food item')),
      );
      return;
    }

    // Combine date and time
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    int totalCalories = _foodItems.fold(0, (sum, item) => sum + item.calories * item.quantity);

    try {
      final meal = Meal(
        mealType: _selectedMealType,
        dateTime: combinedDateTime,
        foodItems: _foodItems,
        totalCalories: totalCalories,
      );

      await _mealService.addMeal(meal);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meal saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _foodItems = [];
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving meal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Meal Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedMealType,
                items: _mealTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMealType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date and Time pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Food Items Section
              const Text(
                'Add Food Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Dish Name Input
              TextFormField(
                controller: _dishNameController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  labelText: 'Dish Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dish name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Calories and Quantity inputs in a row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Calories',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter calories';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add Food Item Button
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Food Item'),
                  onPressed: _addFoodItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // List of added food items
              if (_foodItems.isNotEmpty) ...[
                const Text(
                  'Added Food Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _foodItems.length,
                  itemBuilder: (context, index) {
                    final item = _foodItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.calories} cal × ${item.quantity}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFoodItem(index),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Total calories
                Center(
                  child: Text(
                    'Total Calories: ${_foodItems.fold(0, (sum, item) => sum + item.calories * item.quantity)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Save Button
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Meal'),
                  onPressed: _saveMeal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}