import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/latest_activity_row.dart';
import '../../common_widget/today_target_cell.dart';
import '../../services/daily_target_firestore_service.dart';

class ActivityTrackerView extends StatefulWidget {
  const ActivityTrackerView({super.key});

  @override
  State<ActivityTrackerView> createState() => _ActivityTrackerViewState();
}

class _ActivityTrackerViewState extends State<ActivityTrackerView> {
  int touchedIndex = -1;

  // Instantiate the DailyTargetFirestoreService
  final DailyTargetFirestoreService _targetService = DailyTargetFirestoreService();

  // State variables to hold the current day's targets with initial default values
  // These will be updated once data is loaded from Firestore
  int _waterTarget = 8000; // Default in ml
  int _stepsTarget = 2400; // Default steps

  // Variables to hold input from the dialog using TextEditingControllers
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  List latestArr = [
    {
      "image": "assets/img/pic_4.png",
      "title": "Drinking 300ml Water",
      "time": "About 1 minutes ago"
    },
    {
      "image": "assets/img/pic_5.png",
      "title": "Eat Snack (Fitbar)",
      "time": "About 3 hours ago"
    },
    // Add more dummy data or replace with real data later
  ];

  @override
  void initState() {
    super.initState();
    // Load today's targets from Firestore when the screen initializes
    _loadDailyTargets();
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _waterController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  // --- Loading Function (calls the service) ---
  void _loadDailyTargets() async {
    try {
      final targets = await _targetService.loadDailyTargets();
      if (targets != null) {
        // Update state if targets were loaded successfully from Firestore
        setState(() {
          // Use loaded values, falling back to defaults if Firestore values are null
          _waterTarget = targets['waterTarget'] ?? 8000;
          _stepsTarget = targets['stepsTarget'] ?? 2400;
          // Note: We are only loading targets here.
          // Achieved amounts might be loaded separately or from a stream later if needed here.
        });
      }
      // If targets is null, it means no data was found in Firestore for today or user not logged in.
      // In this case, state remains at the initial default values (8000ml, 2400 steps).
      print("Load Daily Targets completed. Current state: Water: $_waterTarget ml, Steps: $_stepsTarget");
    } catch (e) {
      print("Failed to load daily targets in ActivityTrackerView UI: $e");
      // Optionally show a snackbar or other error indicator to the user
      if (mounted) { // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load daily targets: ${e.toString()}'))
        );
      }
    }
  }

  // --- Dialog Function to show input form ---
  void _showSetTargetDialog() {
    // Pre-fill controllers with current targets for convenience when the dialog opens
    _waterController.text = _waterTarget.toString();
    _stepsController.text = _stepsTarget.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Today's Target"),
          content: SingleChildScrollView( // Use SingleChildScrollView for smaller screens/keyboards
            child: Column(
              mainAxisSize: MainAxisSize.min, // Make the column only take necessary space
              children: <Widget>[
                TextField(
                  controller: _waterController,
                  keyboardType: TextInputType.number, // Only numeric keyboard
                  decoration: const InputDecoration(labelText: 'Water Target (ml)'),
                  // Optional: Add input formatters or validators
                ),
                TextField(
                  controller: _stepsController,
                  keyboardType: TextInputType.number, // Only numeric keyboard
                  decoration: const InputDecoration(labelText: 'Steps Target'),
                  // Optional: Add input formatters or validators
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                // Optionally clear controllers or reset their text to state values here
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                // Call the saving function and dismiss the dialog
                _saveAndDismissDialog();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Saving Function (parses input, calls the service, and updates UI state) ---
  void _saveAndDismissDialog() async {
    // Parse input values from controllers
    int? waterInput = int.tryParse(_waterController.text);
    int? stepsInput = int.tryParse(_stepsController.text);

    // Basic validation: Check if parsing was successful and values are non-negative
    if (waterInput == null || stepsInput == null || waterInput < 0 || stepsInput < 0) {
      print("Invalid input detected: water=$waterInput, steps=$stepsInput");
      // Show an error message to the user (e.g., using a SnackBar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid positive numbers for targets.'))
        );
        // Don't dismiss the dialog on invalid input
      }
      return; // Stop here if input is invalid
    }

    // Update the state variables immediately with the *new* valid targets
    // This makes the UI feel more responsive even before the save to Firestore completes
    setState(() {
      _waterTarget = waterInput;
      _stepsTarget = stepsInput;
    });

    // Dismiss the dialog now that we have valid input and updated the UI state
    if (mounted) {
      Navigator.of(context).pop();
      // Optionally clear controllers after pop
      // _waterController.clear();
      // _stepsController.clear();
    }


    try {
      // Call the service to save the data to Firestore
      await _targetService.saveDailyTargets(
        waterTarget: waterInput,
        stepsTarget: stepsInput,
      );
      // If save is successful, the UI was already updated via setState above.
      print("Targets saved successfully via service.");

    } catch (e) {
      print("Failed to save daily targets in ActivityTrackerView UI: $e");
      // Show an error message to the user if saving failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save targets to cloud: ${e.toString()}'))
        );
        // You *might* want to revert the state change here if the save failure
        // should mean the targets weren't actually set. Depends on UX preference.
        // E.g., call _loadDailyTargets() again to revert to the last known good state.
      }
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
          "Activity Tracker",
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    TColor.primaryColor2.withOpacity(0.3),
                    TColor.primaryColor1.withOpacity(0.3)
                  ]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today Target",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        // --- Updated "Add" Button ---
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.primaryG,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MaterialButton(
                                onPressed: () {
                                  // Call the function to show the target setting dialog
                                  _showSetTargetDialog();
                                },
                                padding: EdgeInsets.zero,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                textColor: TColor.primaryColor1,
                                minWidth: double.maxFinite,
                                elevation: 0,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 15,
                                )),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // --- Updated TodayTargetCell widgets to use state variables ---
                    Row(
                      children: [
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/water.png",
                            // Display the water target from the state variable.
                            // Convert from ml to Liters for display and format.
                            value: "${(_waterTarget / 1000.0).toStringAsFixed(1)}L", // Example: 8000ml -> 8.0L
                            title: "Water Intake Target", // Changed title slightly for clarity
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/foot.png",
                            // Display the steps target from the state variable
                            value: "$_stepsTarget",
                            title: "Foot Steps Target", // Changed title slightly for clarity
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Activity  Progress",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.primaryG),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: ["Weekly", "Monthly"]
                              .map((name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                          color: TColor.gray, fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {},
                          icon: Icon(Icons.expand_more, color: TColor.white),
                          hint: Text(
                            "Weekly",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: TColor.white, fontSize: 12),
                          ),
                        ),
                      )),
                ],
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Container(
                height: media.width * 0.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 3)
                    ]),
                child: BarChart(BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey,
                      tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                      tooltipMargin: 10,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String weekDay;
                        switch (group.x) {
                          case 0:
                            weekDay = 'Monday';
                            break;
                          case 1:
                            weekDay = 'Tuesday';
                            break;
                          case 2:
                            weekDay = 'Wednesday';
                            break;
                          case 3:
                            weekDay = 'Thursday';
                            break;
                          case 4:
                            weekDay = 'Friday';
                            break;
                          case 5:
                            weekDay = 'Saturday';
                            break;
                          case 6:
                            weekDay = 'Sunday';
                            break;
                          default:
                            throw Error();
                        }
                        return BarTooltipItem(
                          '$weekDay\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (rod.toY - 1).toString(),
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            barTouchResponse == null ||
                            barTouchResponse.spot == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            barTouchResponse.spot!.touchedBarGroupIndex;
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: getTitles,
                        reservedSize: 38,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: showingGroups(),
                  gridData: FlGridData(show: false),
                )),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Latest Workout",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "See More",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: latestArr.length,
                  itemBuilder: (context, index) {
                    var wObj = latestArr[index] as Map? ?? {};
                    return LatestActivityRow(wObj: wObj);
                  }),
              SizedBox(
                height: media.width * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.gray,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text('Sun', style: style);
        break;
      case 1:
        text = Text('Mon', style: style);
        break;
      case 2:
        text = Text('Tue', style: style);
        break;
      case 3:
        text = Text('Wed', style: style);
        break;
      case 4:
        text = Text('Thu', style: style);
        break;
      case 5:
        text = Text('Fri', style: style);
        break;
      case 6:
        text = Text('Sat', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, TColor.primaryG,
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 10.5, TColor.secondaryG,
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, TColor.primaryG,
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 7.5, TColor.secondaryG,
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 15, TColor.primaryG,
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 5.5, TColor.secondaryG,
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 8.5, TColor.primaryG,
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartGroupData makeGroupData(
    int x,
    double y,
    List<Color> barColor, {
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          gradient: LinearGradient(
              colors: barColor,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.green)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: TColor.lightGray,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
