import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import '../../services/routine_service.dart';
import 'daily_routine_page.dart';

class UnifiedRoutinePage extends StatefulWidget {
  const UnifiedRoutinePage({super.key});

  @override
  State<UnifiedRoutinePage> createState() => _UnifiedRoutinePageState();
}

class _UnifiedRoutinePageState extends State<UnifiedRoutinePage> {
  final RoutineService _routineService = RoutineService();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>>? _sortedTasksFuture;

  @override
  void initState() {
    super.initState();
    _loadAndSortTasks();
  }

  void _loadAndSortTasks() {
    setState(() {
      _sortedTasksFuture = _fetchAndSort();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAndSort() async {
    final data = await _routineService.getDailySuggestions(uid);
    if (data == null) return [];

    List<Map<String, dynamic>> allTasks = [];

    // 1. Parse Common Tasks
    final common = List<dynamic>.from(data['common'] ?? []);
    for (var t in common) {
      allTasks.add({
        'title': t['task_name'],
        'time': t['default_time'], // "HH:mm"
        'type': 'General',
        'icon': Icons.check_circle_outline,
        'color': Colors.blue,
      });
    }

    // 2. Parse Therapy
    final therapy = List<dynamic>.from(data['therapy'] ?? []);
    for (var t in therapy) {
      // Use assigned_time or default to 10:00 if missing
      // Note: Backend 'therapy_assignments' might not have a clean time field yet, check app.py aggregation?
      // app.py assigns 'assigned_time' key.
      allTasks.add({
        'title': t['activity_name'],
        'time': t['assigned_time'] ?? "10:00", 
        'type': 'Therapy',
        'icon': Icons.accessibility_new,
        'color': Colors.purple,
      });
    }

    // 3. Parse Meds
    final meds = List<dynamic>.from(data['medications'] ?? []);
    for (var m in meds) {
      // Meds usually have 'timing' key like 'before_breakfast'. 
      // We need to map that to a rough time for sorting.
      String timeStr = "08:00"; // default
      String timing = (m['timing'] ?? "").toString().toLowerCase();
      
      if (timing.contains('breakfast')) timeStr = "08:00";
      else if (timing.contains('lunch')) timeStr = "13:00";
      else if (timing.contains('dinner')) timeStr = "19:00";
      else if (timing.contains('bed')) timeStr = "21:00";

      allTasks.add({
        'title': "Take ${m['drug_name']}",
        'time': timeStr,
        'type': 'Medication',
        'icon': Icons.medication,
        'color': Colors.red,
        'subtitle': m['dosage']
      });
    }

    // 4. Sort by Time
    allTasks.sort((a, b) {
      // Simple string comparison works for "HH:mm" 24-hour format
      // e.g. "08:00" < "09:00"
      return (a['time'] ?? "00:00").compareTo(b['time'] ?? "00:00");
    });

    return allTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Daily Schedule"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sortedTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No tasks scheduled yet.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTimelineCard(task, index, tasks.length);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // Go to the "Planner" view to add/edit items
           Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyRoutinePage()));
        },
        child: const Icon(Icons.add),
        tooltip: "Manage/Add Tasks",
      ),
    );
  }

  Widget _buildTimelineCard(Map<String, dynamic> task, int index, int total) {
    bool isLast = index == total - 1;
    
    String displayTime = task['time'];
    try {
      final dt = DateFormat("HH:mm").parse(task['time']);
      displayTime = DateFormat("h:mm a").format(dt);
    } catch (_) {}

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Column
          SizedBox(
            width: 70, // Wider for larger text
            child: Column(
              children: [
                Text(
                  displayTime, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: 3, // Thicker line
                    color: isLast ? Colors.transparent : Colors.teal.shade100,
                  ),
                ),
              ],
            ),
          ),
          
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0), // More spacing
              child: Card(
                elevation: 3,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (task['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(task['icon'], color: task['color'], size: 28),
                    ),
                    title: Text(
                      task['title'], 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        task['type'] + (task['subtitle'] != null ? " • ${task['subtitle']}" : ""),
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                    trailing: Transform.scale(
                      scale: 1.5, // Bigger checkbox
                      child: Checkbox(
                        value: false, 
                        activeColor: Colors.teal,
                        shape: const CircleBorder(),
                        onChanged: (val) {
                          // TODO: Implement completion toggle
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
