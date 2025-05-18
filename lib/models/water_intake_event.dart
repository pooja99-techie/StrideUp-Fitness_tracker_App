import 'package:cloud_firestore/cloud_firestore.dart';

class WaterIntakeEvent {
  final String id; // Firestore Document ID
  final int amount; // Amount in ml
  final DateTime timestamp;

  WaterIntakeEvent({
    required this.id,
    required this.amount,
    required this.timestamp,
  });

  // Factory constructor to create a WaterIntakeEvent from a Firestore DocumentSnapshot
  factory WaterIntakeEvent.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Missing data for WaterIntakeEvent document ${doc.id}');
    }

    // Ensure timestamp is converted correctly
    final Timestamp? firestoreTimestamp = data['timestamp'] as Timestamp?;
    if (firestoreTimestamp == null) {
      throw StateError('Missing timestamp for WaterIntakeEvent document ${doc.id}');
    }


    return WaterIntakeEvent(
      id: doc.id,
      amount: data['amount'] as int? ?? 0, // Default to 0 if amount is missing
      timestamp: firestoreTimestamp.toDate(),
    );
  }

  // Helper to convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp), // Save as Firestore Timestamp
    };
  }
}
