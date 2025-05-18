import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:strideup_fitness_app/view/meal_planner/meal_form.dart';
import '../../common/colo_extension.dart';
import '../../models/meal_models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: TColor.secondaryColor2,
          primary: TColor.secondaryColor2,
        ),
        useMaterial3: true,
      ),
      home: const MealScheduleView(),
    );
  }
}

class MealScheduleView extends StatefulWidget {
  const MealScheduleView({super.key});

  @override
  State<MealScheduleView> createState() => _MealScheduleViewState();
}

class _MealScheduleViewState extends State<MealScheduleView> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;
  List<Meal> _meals = []; // List to hold meals for the selected date
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateWeekDates();
    _fetchMeals(); // Fetch meals when the view is initialized
  }

  void _generateWeekDates() {
    DateTime startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    _weekDates = List.generate(
      7,
          (index) => startOfWeek.add(Duration(days: index)),
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _fetchMeals(); // Fetch meals for the selected date
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      _generateWeekDates();
      _fetchMeals(); // Fetch meals for the new selected date
    });
  }

  void _previousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _generateWeekDates();
      _fetchMeals(); // Fetch meals for the new selected date
    });
  }

  Future<void> _fetchMeals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _meals = [];
        _loading = false;
      });
      return; // Ensure user is logged in
    }

    setState(() {
      _loading = true;
    });

    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('meals')
          .where('dateTime', isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay)
          .orderBy('dateTime')
          .get();

      setState(() {
        _meals = snapshot.docs.map((doc) {
          final data = doc.data();
          return Meal(
            mealType: data['mealType'],
            dateTime: (data['dateTime'] as Timestamp).toDate(),
            foodItems: (data['foodItems'] as List<dynamic>)
                .map((item) => FoodItem(
              name: item['name'],
              calories: item['calories'],
              quantity: item['quantity'],
            ))
                .toList(),
            totalCalories: data['totalCalories'],
          );
        }).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _meals = [];
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading meals: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Meal Schedule",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildDateSelector(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _meals.isEmpty
                  ? _buildEmptyState()
                  : _buildMealList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousWeek,
            icon: const Icon(Icons.chevron_left),
            color: Colors.grey[600],
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _weekDates.length,
              itemBuilder: (context, index) {
                final date = _weekDates[index];
                final isSelected = _selectedDate.day == date.day &&
                    _selectedDate.month == date.month &&
                    _selectedDate.year == date.year;

                return _buildDateItem(date, isSelected);
              },
            ),
          ),
          IconButton(
            onPressed: _nextWeek,
            icon: const Icon(Icons.chevron_right),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(DateTime date, bool isSelected) {
    final dayName = DateFormat('E').format(date).substring(0, 3);
    final dayNumber = date.day.toString();

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Container(
        width: 65,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? TColor.secondaryColor2
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dayNumber,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCalendarIcon(),
          const SizedBox(height: 30),
          Text(
            'There is nothing scheduled',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Try adding new meal plans',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Calendar icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: TColor.secondaryColor2,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: index == 5
                              ? TColor.secondaryColor2
                              : TColor.secondaryColor2.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Add button
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MealTrackerForm(),
          ),
        ).then((_) => _fetchMeals()); // Refresh meals when returned
      },
      backgroundColor: TColor.secondaryColor2,
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildMealList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _meals.length,
      itemBuilder: (context, index) {
        final meal = _meals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealType,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TColor.secondaryColor2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy-MM-dd – HH:mm').format(meal.dateTime),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ...meal.foodItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${item.name} — ${item.calories} cal × ${item.quantity}',
                    style: const TextStyle(fontSize: 16),
                  ),
                )),
                const SizedBox(height: 12),
                Text(
                  'Total Calories: ${meal.totalCalories}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
