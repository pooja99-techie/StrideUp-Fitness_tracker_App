import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:strideup_fitness_app/view/water_intake/water_graph_view.dart';
import '../../common/colo_extension.dart';

enum ReminderStatus { off, muted, on }


class WaterTrackingScreen extends StatefulWidget {
  const WaterTrackingScreen({Key? key}) : super(key: key);

  @override
  State<WaterTrackingScreen> createState() => _WaterTrackingScreenState();
}

class _WaterTrackingScreenState extends State<WaterTrackingScreen> {

  ReminderStatus _reminderStatus = ReminderStatus.off;


  int waterConsumed = 0;
  final int targetWaterIntake = 1604; // Target in ml
  bool notificationsEnabled = false;
  DateTime selectedDate = DateTime.now();
  bool showWaterOptions = false;

  // List to track water intake history with amount and timestamp
  List<WaterIntake> waterIntakeHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300], // Light blue background matching the image
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildWaterTracker(),
            Expanded(
              child: _buildMainContent(),
            ),
            if (showWaterOptions) _buildWaterOptions(),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WaterGraphScreen(waterIntakeHistory: waterIntakeHistory),
                ),
              );
            },
            child: Icon(
              Icons.bar_chart,
              color: TColor.white,
              size: 26,
            ),
          ),
          Center(
            child: waterConsumed > 0
                ? Icon(
              Icons.water_drop,
              color: TColor.white,
              size: 28,
            )
                : Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: TColor.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.more_horiz,
                color: TColor.white,
              ),
            ),
          ),
          Icon(
            Icons.settings,
            color: TColor.white,
            size: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker() {
    double progressPercent = waterConsumed / targetWaterIntake;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            // Progress indicator
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth * progressPercent,
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                );
              },
            ),
            // Text display
            Center(
              child: Text(
                "$waterConsumed /${targetWaterIntake}ml",
                style: TextStyle(
                  color: TColor.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            // Marker for current position
            Positioned(
              left: (MediaQuery.of(context).size.width - 40) * progressPercent,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Options button
            Positioned(
              right: 5,
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  // Handle options
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        children: [
          _buildDateSelector(),
          if (waterIntakeHistory.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  "After drinking a glass of water\nclick \"+\" button to record it",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: waterIntakeHistory.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildNotificationToggle();
                  } else {
                    final intake = waterIntakeHistory[index - 1];
                    return _buildWaterIntakeItem(intake);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildWaterIntakeItem(WaterIntake intake) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                intake.amount == 700 ? Icons.local_drink : Icons.water_drop,
                size: 36,
                color: Colors.blue[800],
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${intake.amount} ml",
                style: TextStyle(
                  color: TColor.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                DateFormat('hh:mm a').format(intake.time),
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    String dateText = _isToday(selectedDate) ? "Today" : DateFormat('MMM dd').format(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.blue[300],
              size: 30,
            ),
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.subtract(const Duration(days: 1));
                // Reset water data for different day
                _loadDataForSelectedDate();
              });
            },
          ),
          GestureDetector(
            onTap: () {
              _showDatePicker();
            },
            child: Row(
              children: [
                Text(
                  dateText,
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.blue[300],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: Colors.blue[300],
              size: 30,
            ),
            onPressed: () {
              setState(() {
                if (!_isToday(selectedDate)) {
                  selectedDate = selectedDate.add(const Duration(days: 1));
                  // Reset water data for different day
                  _loadDataForSelectedDate();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _loadDataForSelectedDate() {
    // This would normally load data from a database
    // For this example, we'll just clear data for non-today
    if (!_isToday(selectedDate)) {
      waterConsumed = 0;
      waterIntakeHistory = [];
    }
  }

  Widget _buildNotificationToggle() {
    return GestureDetector(
      onTap: () => _showNotificationDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _reminderStatus == ReminderStatus.on
                    ? Icons.notifications_active
                    : _reminderStatus == ReminderStatus.muted
                    ? Icons.notifications_off
                    : Icons.notifications_off_outlined,
                color: TColor.gray,
                size: 22,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              _reminderStatus.name, // displays "off", "muted", or "on"
              style: TextStyle(
                color: TColor.gray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.redAccent,
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Turn off reminders for today.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPopupIcon(Icons.pan_tool, "Stop", () {
                    setState(() {
                      _reminderStatus = ReminderStatus.off;
                      // TODO: Cancel all notifications
                    });
                    Navigator.pop(context);
                  }),
                  _buildPopupIcon(Icons.notifications_off, "Mute", () {
                    setState(() {
                      _reminderStatus = ReminderStatus.muted;
                      // TODO: Mute reminders (pause schedule or reduce frequency)
                    });
                    Navigator.pop(context);
                  }),
                  _buildPopupIcon(Icons.notifications_active, "On", () {
                    setState(() {
                      _reminderStatus = ReminderStatus.on;
                      // TODO: Resume/send notifications
                    });
                    Navigator.pop(context);
                  }),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to full settings page
                      Navigator.pop(context);
                      // Navigator.push(...);
                    },
                    child: Text("REMINDER SETTINGS", style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildPopupIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: Icon(icon, color: Colors.redAccent),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterOptions() {
    return Container(
      height: 90,
      color: Colors.yellow[300],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // _buildWaterOptionItem('Customize', Icons.dashboard_customize_outlined, 0),
          _buildWaterOptionItem('300 ml', null, 300, useGlassIcon: true),
          _buildWaterOptionItem('700 ml', null, 700, useBottleIcon: true),
        ],
      ),
    );
  }

  Widget _buildWaterOptionItem(
      String label, IconData? icon, int amount,
      {bool useGlassIcon = false, bool useBottleIcon = false}) {
    return GestureDetector(
      onTap: () {
        if (amount > 0) {
          _addWaterIntake(amount);
        } else {
          // Handle customize option
          // Would show dialog to enter custom amount
        }
        setState(() {
          showWaterOptions = false;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.blue,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue),
            )
          else if (useGlassIcon)
            SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.local_drink, color: Colors.blue[300], size: 32),
            )
          else if (useBottleIcon)
              SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                    Icons.water_drop,
                    color: Colors.blue[300],
                    size: 32),
              ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Diamond/premium button
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.amber[300],
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.diamond_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          // Add water button
          if (!showWaterOptions)
            GestureDetector(
              onTap: () {
                setState(() {
                  showWaterOptions = true;
                });
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.amber[300],
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addWaterIntake(int amount) {
    setState(() {
      waterConsumed = (waterConsumed + amount).clamp(0, targetWaterIntake);
      waterIntakeHistory.add(
        WaterIntake(
          amount: amount,
          time: DateTime.now(),
        ),
      );
    });
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[300]!, // Header background color
              onPrimary: TColor.white, // Header text color
              onSurface: TColor.black, // Calendar text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[300], // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _loadDataForSelectedDate();
      });
    }
  }
}

// Model class for water intake tracking
class WaterIntake {
  final int amount;
  final DateTime time;

  WaterIntake({
    required this.amount,
    required this.time,
  });
}


