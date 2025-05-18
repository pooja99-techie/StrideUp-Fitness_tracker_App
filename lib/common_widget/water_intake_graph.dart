import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../common/colo_extension.dart'; // Assuming TColor is here
import '../services/water_intake_firestore_service.dart'; // Import the service

// Make sure you have the intl dependency in your pubspec.yaml

class WaterIntakeGraph extends StatefulWidget {
  final WaterIntakeFirestoreService waterIntakeService;
  final int numberOfDays; // How many days to show on the graph

  const WaterIntakeGraph({
    Key? key,
    required this.waterIntakeService,
    this.numberOfDays = 7, // Default to 7 days
  }) : super(key: key);

  @override
  State<WaterIntakeGraph> createState() => _WaterIntakeGraphState();
}

class _WaterIntakeGraphState extends State<WaterIntakeGraph> {
  // Future to hold the historical data fetch operation
  late Future<Map<String, int>> _historicalDataFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching data when the widget is initialized
    _historicalDataFuture = widget.waterIntakeService.getHistoricalDailyTotals(
        numberOfDays: widget.numberOfDays);
  }

  // Helper to get weekday abbreviation for the x-axis labels
  String _getWeekdayLabel(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      // Format as a 2-letter abbreviation (e.g., 'Mo', 'Tu')
      return DateFormat('EE').format(date).substring(0, 2);
    } catch (e) {
      print("Error formatting date string $dateString: $e");
      return ''; // Return empty string on error
    }
  }

  // Function to prepare graph spots from fetched data
  List<FlSpot> _getGraphSpots(Map<String, int> data) {
    List<FlSpot> spots = [];
    // Ensure dates are processed in order for the graph
    final sortedDates = data.keys.toList();
    // Sort dates descending (most recent first) then reverse to get oldest first for graph
    sortedDates.sort((a, b) => b.compareTo(a));
    final orderedDates = sortedDates.reversed.toList();

    for (int i = 0; i < orderedDates.length; i++) {
      final date = orderedDates[i];
      final totalMl = data[date] ?? 0; // Get total ml for the day, default to 0
      // Use index (0 to numberOfDays-1) for the x-axis
      spots.add(FlSpot(i.toDouble(), totalMl.toDouble())); // Use totalMl for y-axis
    }
    return spots;
  }

  // Function to generate bottom titles (weekdays)
  SideTitles get _bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: 20, // Space for the titles
    interval: 1, // Show title for every spot (day)
    getTitlesWidget: (value, meta) {
      // Map the x-axis value (index 0 to N-1) back to the date string
      // Need the dates that were fetched to map correctly
      // A more robust approach might pass the ordered dates list or map directly
      // For simplicity, let's recalculate the dates based on today and index
      final now = DateTime.now();
      final dateForSpot = now.subtract(Duration(days: widget.numberOfDays - 1 - value.toInt()));
      final dateStringForSpot = DateFormat('yyyy-MM-dd').format(dateForSpot);

      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 5,
        child: Text(
            _getWeekdayLabel(dateStringForSpot), // Use helper to get weekday
            style: TextStyle(color: TColor.gray, fontSize: 10)),
      );
    },
  );

  // Function to generate left titles (ml amounts)
  SideTitles get _leftTitles => SideTitles(
    showTitles: true,
    reservedSize: 40, // Space for the titles
    interval: 1000, // Show labels every 1000ml (1 Liter)
    getTitlesWidget: (value, meta) {
      // Only show titles for multiples of 1000
      if (value % 1000 == 0) {
        return Text(
          '${value.toInt()}', // Display in ml
          style: TextStyle(color: TColor.gray, fontSize: 10),
          textAlign: TextAlign.center,
        );
      }
      return Container(); // Don't show title for other values
    },
    // Optional: Set a minimum value for the Y axis if needed
    // minY: 0, // Ensure graph starts at 0
  );


  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to handle the asynchronous data fetching
    return FutureBuilder<Map<String, int>>(
      future: _historicalDataFuture, // The future that will provide the data
      builder: (context, snapshot) {
        // --- Handle Loading State ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200, // Match the desired graph height
            alignment: Alignment.center,
            child: const CircularProgressIndicator(), // Show a loading indicator
          );
        }

        // --- Handle Error State ---
        if (snapshot.hasError) {
          print("Error building water intake graph: ${snapshot.error}");
          return Container(
            height: 200, // Match the desired graph height
            alignment: Alignment.center,
            child: Text(
              "Error loading graph data: ${snapshot.error}",
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }

        // --- Handle Data Ready State ---
        // snapshot.hasData will be true if the future completed successfully
        // The data is in snapshot.data (which is Map<String, int> or null)
        final Map<String, int> historicalData = snapshot.data ?? {};

        if (historicalData.isEmpty) {
          // Handle case where no data is available for any of the days
          return Container(
            height: 200, // Match the desired graph height
            alignment: Alignment.center,
            child: Text(
              "No water intake data available for the last ${widget.numberOfDays} days.",
              style: TextStyle(color: TColor.gray),
              textAlign: TextAlign.center,
            ),
          );
        }

        // Data is available, prepare spots for the graph
        final List<FlSpot> spots = _getGraphSpots(historicalData);

        // Determine max Y value for the graph (maybe 1 or 2 Liters above max achieved)
        double maxY = (spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0) + 1000; // Add 1000ml buffer
        if (maxY < 4000) maxY = 4000; // Ensure Y-axis goes up to at least a few liters if data is low

        // Build the LineChart
        return Container(
          padding: const EdgeInsets.only(top: 15, right: 15, left: 0, bottom: 0), // Adjust padding
          height: 200, // Set a suitable height for the graph
          child: LineChart(
            LineChartData(
              // Remove showingTooltipIndicators if you don't want default tooltips
              // showingTooltipIndicators: showingTooltipOnSpots.map((index) { ... }).toList(), // If you had custom tooltips

              lineTouchData: LineTouchData(
                enabled: true, // Enable touch
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: TColor.primaryColor1, // Tooltip background color
                  tooltipRoundedRadius: 8,
                  // Customize tooltip text: show date and amount for the spot
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      // spot.x is the index (0 to N-1)
                      // spot.y is the value (total ML)
                      // Need to map spot.x back to the actual date string
                      final now = DateTime.now();
                      final dateForSpot = now.subtract(Duration(days: widget.numberOfDays - 1 - spot.x.toInt()));
                      final dateStringForSpot = DateFormat('MMM d').format(dateForSpot); // e.g., Oct 27

                      return LineTooltipItem(
                          '$dateStringForSpot\n${spot.y.toInt()} ml', // Display date and amount
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center
                      );
                    }).toList();
                  },
                ),
                // Keep or remove gesture handling based on your needs
                // touchCallback: (FlTouchEvent event, LineTouchResponse? response) { ... },
                // mouseCursorResolver: (FlTouchEvent event, LineTouchResponse? response) { ... },
                // getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) { ... },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots, // Use the dynamically generated spots
                  isCurved: true, // Make the line curved
                  gradient: LinearGradient(
                      colors: TColor.primaryG, // Use your gradient
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight),
                  barWidth: 3,
                  dotData: FlDotData(show: true), // Show dots on spots
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(colors: [
                      TColor.primaryColor2.withOpacity(0.4),
                      TColor.primaryColor1.withOpacity(0.1),
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                ),
              ],
              minX: 0, // Start X axis at 0 (for the first day)
              maxX: (widget.numberOfDays - 1).toDouble(), // End X axis at the last day index
              minY: 0, // Start Y axis at 0
              maxY: maxY, // Dynamic max Y based on data
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide right titles
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide top titles
                bottomTitles: AxisTitles(sideTitles: _bottomTitles), // Use custom bottom titles (weekdays)
                leftTitles: AxisTitles(sideTitles: _leftTitles), // Use custom left titles (ml amounts)
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 1000, // Draw horizontal lines every 1000ml (1 Liter)
                drawVerticalLine: true, // Draw vertical lines (optional, aligns with days)
                verticalInterval: 1, // Vertical lines for each day
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: TColor.gray.withOpacity(0.15),
                    strokeWidth: 1, // Thinner lines
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: TColor.gray.withOpacity(0.15),
                    strokeWidth: 1, // Thinner lines
                  );
                },
              ),
              borderData: FlBorderData(
                show: false, // Remove default border
              ),
            ),
          ),
        );
      }, // End of FutureBuilder builder
    ); // End of FutureBuilder
  }
}
