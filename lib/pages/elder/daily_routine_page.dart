import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/routine_service.dart';
import '../../models/routine_models.dart';

class DailyRoutinePage extends StatefulWidget {
  const DailyRoutinePage({super.key});

  @override
  State<DailyRoutinePage> createState() => _DailyRoutinePageState();
}

class _DailyRoutinePageState extends State<DailyRoutinePage> with SingleTickerProviderStateMixin {
  final RoutineService _routineService = RoutineService();
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  
  late TabController _tabController;
  Future<Map<String, dynamic>?>? _suggestionsFuture;
  bool _isPredicting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshSuggestions();
  }

  void _refreshSuggestions() {
    setState(() {
      _suggestionsFuture = _routineService.getDailySuggestions(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Your Day"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.wb_sunny), text: "Common"),
            Tab(icon: Icon(Icons.accessibility), text: "Therapy"),
            Tab(icon: Icon(Icons.medication), text: "Meds"),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _suggestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
           // ... (keep existing builder logic, just ensure body is clean)
          
          final data = snapshot.data ?? {};
          final common = List<dynamic>.from(data['common'] ?? []);
          final therapy = List<dynamic>.from(data['therapy'] ?? []);
          final meds = List<dynamic>.from(data['medications'] ?? []);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCommonList(common),
              _buildTherapyList(therapy),
              _buildMedList(meds),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Custom Task"),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _showCreateTaskDialog() {
    final TextEditingController nameController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("New Task"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Task Name", hintText: "e.g., Walk the Dog"),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Time: "),
                    TextButton(
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: selectedTime);
                        if (t != null) setState(() => selectedTime = t);
                      },
                      child: Text(selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    Navigator.pop(context);
                    final timeStr = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
                    // Call prediction/add flow with 'common' type
                    _pickTimeAndPredict(nameController.text, 'common', timeStr);
                  }
                },
                child: const Text("Next"),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- BUCKET A: Common Tasks ---
  Widget _buildCommonList(List<dynamic> tasks) {
    if (tasks.isEmpty) return _emptyState("No common tasks found.");
    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(
          title: task['task_name'],
          subtitle: "Suggested: ${task['default_time']}",
          icon: Icons.check_circle_outline,
          color: Colors.blue,
          onAdd: () => _pickTimeAndPredict(task['task_name'], 'common', task['default_time']),
        );
      },
    );
  }

  // --- BUCKET B: Therapy ---
  Widget _buildTherapyList(List<dynamic> tasks) {
    if (tasks.isEmpty) return _emptyState("No therapy assigned.");
    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(
          title: task['activity_name'],
          subtitle: "Duration: ${task['duration']}",
          icon: Icons.fitness_center,
          color: Colors.purple,
          onAdd: () => _pickTimeAndPredict(task['activity_name'], 'therapist', "10:00"),
        );
      },
    );
  }

  // --- BUCKET C: Medications ---
  Widget _buildMedList(List<dynamic> tasks) {
    if (tasks.isEmpty) return _emptyState("No active medications.");
    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final med = tasks[index];
        String timing = med['timing'] ?? 'Unknown';
        // Pretty print timing
        timing = timing.replaceAll('_', ' ').toUpperCase();

        return _buildTaskCard(
          title: med['drug_name'],
          subtitle: "${med['dosage']} • $timing",
          icon: Icons.medication_liquid,
          color: Colors.red,
          onAdd: () {
             // For meds, we might want to auto-pick based on meal time, but 
             // user still confirms. Proxy time 08:00 for simplicity.
             _pickTimeAndPredict(med['drug_name'], 'medication', "08:00");
          },
        );
      },
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onAdd,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
          onPressed: onAdd,
          tooltip: "Schedule this task",
        ),
      ),
    );
  }

  Widget _emptyState(String msg) => Center(child: Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 16)));

  // --- AI PREDICTION FLOW ---

  Future<void> _pickTimeAndPredict(String taskName, String type, String defaultTimeStr) async {
    // 1. Pick Time
    TimeOfDay initial = const TimeOfDay(hour: 8, minute: 0);
    try {
      final parts = defaultTimeStr.split(':');
      if (parts.length == 2) {
        initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (_) {}

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: "WHEN DO YOU WANT TO DO THIS?",
    );

    if (picked == null) return;

    final String timeKey = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

    // 2. Show Loading & Predict
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final insights = await _routineService.predictTaskOutcomes(
      uid: uid,
      taskName: taskName,
      taskType: type,
      timeString: timeKey,
    );

    if (!mounted) return;
    Navigator.pop(context); // Pop loading

    if (insights != null) {
      _showPredictionResults(taskName, timeKey, type, insights);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI Connection Failed. Try again.")));
    }
  }

  void _showPredictionResults(String taskName, String timeStr, String type, RoutineAIInsights insights) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.purple),
            const SizedBox(width: 8),
            const Text("AI Insights"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Scheduling \"$taskName\" at $timeStr", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInsightRow(
              "Completion Chance", 
              "${(insights.completionProb! * 100).toInt()}%", 
              insights.completionProb! > 0.8 ? Colors.green : Colors.orange
            ),
            _buildInsightRow(
              "Expected Delay", 
              "${insights.expectedDelay?.toInt()} mins", 
              Colors.blueGrey
            ),
            _buildInsightRow(
              "Max Retries", 
              "${insights.predictedRetries}", 
              Colors.brown
            ),
             _buildInsightRow(
              "Allowed Snoozes", 
              "${insights.predictedSnoozes}", 
              Colors.teal
            ),
            if (insights.needsEscalation == true)
               Padding(
                 padding: const EdgeInsets.only(top: 8.0),
                 child: Container(
                   padding: const EdgeInsets.all(8),
                   color: Colors.red.withOpacity(0.1),
                   child: const Row(
                     children: [
                       Icon(Icons.warning, color: Colors.red, size: 16),
                       SizedBox(width: 8),
                       Expanded(child: Text("High Risk! Caregiver will be notified if missed.", style: TextStyle(color: Colors.red, fontSize: 12))),
                     ],
                   ),
                 ),
               )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
            onPressed: () async {
              // 3. Save to Actual Routine (common_routine_templates)
              // This is where "Scheduling" happens.
              // Note: The backend 'add_task' endpoint *already* saves it to Firestore!
              // See app.py line 143: update_time, doc_ref = db.collection(collection_name).add(final_data)
              // Wait... `predictTaskOutcomes` (GET/POST) in app.py logic...
              // Let's re-read app.py.
              
              // Ah, current `predictTaskOutcomes` only PREDICTS (returns JSON), it does NOT save.
              // `add_task` endpoint DOES save but it ALSO predicts.
              
              // So, we should call `add_task` (which is `addCommonTask` in service) HERE.
              
              Navigator.pop(context); // Close dialog first

              try {
                // Construct the task object to save
                final newTask = CommonTask(
                   id: null, 
                   uid: uid,
                   taskName: taskName,
                   defaultTime: timeStr,
                   // isCompleted not needed as per model
                );

                // Call Service to SAVE
                await _routineService.addCommonTask(newTask);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Task '$taskName' scheduled for $timeStr!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Refresh the list to show the new task
                  _refreshSuggestions(); 
                }
              } catch (e) {
                 if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save: $e"))); 
                 }
              }
            },
            child: const Text("Confirm & Schedule"),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}