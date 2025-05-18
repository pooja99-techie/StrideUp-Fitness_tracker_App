class StepData {
  final int hour;   // Represents the hour of the day (0–23)
  final int steps;  // Step count recorded for that hour

  StepData(this.hour, this.steps);

  // Optional: JSON serialization for persistent storage
  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      json['hour'] as int,
      json['steps'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'steps': steps,
    };
  }
}
