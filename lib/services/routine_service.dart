import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/routine_models.dart';

class RoutineService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- SMART URL SELECTION ---
  String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:5000";
    if (defaultTargetPlatform == TargetPlatform.android) return "http://10.0.2.2:5000";
    return "http://192.168.8.115:5000";
  } 

  // --- WRITES (Must go through Python for AI) ---

  // 1. Add Common Routine
  Future<CommonTask?> addCommonTask(CommonTask task) async {
    return await _sendData('/add_task', task.toJson(), (json) => CommonTask.fromJson(json));
  }

  // 2. Add Therapist Activity
  Future<TherapistActivity?> addTherapistActivity(TherapistActivity activity) async {
    return await _sendData('/add_task', activity.toJson(), (json) => TherapistActivity.fromJson(json));
  }

  // 3. Add Medication
  Future<Medication?> addMedication(Medication med) async {
    return await _sendData('/add_task', med.toJson(), (json) => Medication.fromJson(json));
  }

  // Helper for HTTP POST
  Future<T?> _sendData<T>(String endpoint, Map<String, dynamic> data, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return fromJson(jsonDecode(response.body));
      } else {
        print("Backend Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Connection Error: $e");
      return null;
    }
  }

  // --- READS (Can fetch from Python or Firestore) ---

  // 4. Get Daily Suggestions (From Python Logic)
  Future<Map<String, dynamic>?> getDailySuggestions(String uid) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_daily_suggestions/$uid'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error loading suggestions: $e");
    }
    return null;
  }

  // 5. Get Medications for Caregiver (Direct Firestore Read)
  Future<List<Medication>> getMedicationsByElderId(String elderId) async {
    try {
      final snapshot = await _db
          .collection('medication_prescriptions')
          .where('elder_id', isEqualTo: elderId)
          .where('is_active', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Medication(
          id: null, // Firestore ID not needed for simple list
          elderId: data['elder_id'] ?? '',
          drugName: data['drug_name'] ?? data['name'] ?? '', // Handle both keys
          dosage: data['dosage'] ?? '',
          frequency: List<String>.from(data['frequency'] ?? []),
          times: List<String>.from(data['times'] ?? []),
          isActive: data['is_active'] ?? true,
          timing: data['timing'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load medications: $e');
    }
  }

  // 6. Delete/Archive Medication
  Future<void> deleteMedication(Medication med) async {
    try {
      final snapshot = await _db
          .collection('medication_prescriptions')
          .where('elder_id', isEqualTo: med.elderId)
          .where('drug_name', isEqualTo: med.drugName) // Use drugName
          .where('dosage', isEqualTo: med.dosage)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({'is_active': false});
      }
    } catch (e) {
      throw Exception('Failed to delete medication: $e');
    }
  }

  // 7. Get Therapist Activities for Caregiver
  Future<List<TherapistActivity>> getTherapistActivities(String elderId) async {
    try {
      final snapshot = await _db
          .collection('therapist_assignments')
          .where('elder_id', isEqualTo: elderId)
          .where('is_active', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TherapistActivity(
          id: null,
          elderId: data['elder_id'],
          activityName: data['activity_name'] ?? '',
          assignedTime: data['assigned_time'] ?? '',
          isActive: data['is_active'] ?? true,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load therapist activities: $e');
    }
  }

  // 8. Predict Task Outcomes (AI)
  Future<RoutineAIInsights?> predictTaskOutcomes({
    required String uid,
    required String taskName,
    required String taskType,
    required String timeString,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict_task_outcomes'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "uid": uid,
          "task_name": taskName,
          "task_type": taskType,
          "time_string": timeString, // "HH:mm"
        }),
      );

      if (response.statusCode == 200) {
        return RoutineAIInsights.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Prediction Error: $e");
    }
    return null;
  }
}