import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry_model.dart';

class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'journal_entries';

  // Save journal entry to Firestore
  Future<void> saveJournalEntry(JournalEntry entry) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(entry.id)
          .set(entry.toMap());
    } catch (e) {
      throw 'Error saving journal entry: $e';
    }
  }

  // Get all journal entries for a user
  Future<List<JournalEntry>> getJournalEntries(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => JournalEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error getting journal entries: $e';
    }
  }

  // Stream journal entries for real-time updates
  Stream<List<JournalEntry>> getJournalEntriesStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JournalEntry.fromFirestore(doc))
            .toList());
  }

  // Delete journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    try {
      await _firestore.collection(_collection).doc(entryId).delete();
    } catch (e) {
      throw 'Error deleting journal entry: $e';
    }
  }

  // Update journal entry
  Future<void> updateJournalEntry(JournalEntry entry) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(entry.id)
          .update(entry.toMap());
    } catch (e) {
      throw 'Error updating journal entry: $e';
    }
  }
}

