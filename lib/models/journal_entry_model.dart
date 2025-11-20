class JournalEntry {
  final String id;
  final String userId;
  final String text;
  final DateTime timestamp;
  final String type; // 'voice' or 'text'

  JournalEntry({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.type,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  // Create from Firestore document
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      type: map['type'] ?? 'text',
    );
  }

  // Create from Firestore document snapshot
  factory JournalEntry.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
      type: data['type'] ?? 'text',
    );
  }
}

