import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class DailyRoutinePage extends StatefulWidget {
  final AppUser user;
  
  const DailyRoutinePage({super.key, required this.user});

  @override
  State<DailyRoutinePage> createState() => _DailyRoutinePageState();
}

class _DailyRoutinePageState extends State<DailyRoutinePage> {
  DateTime _selectedDate = DateTime.now();

  // Sample routine data - in a real app, this would come from a database
  late List<Map<String, dynamic>> _routines = [
    {
      'time': '08:00 AM',
      'activity': 'Morning Exercise',
      'description': 'Light stretching and walking',
      'completed': false,
      'icon': Icons.fitness_center,
    },
    {
      'time': '09:00 AM',
      'activity': 'Breakfast',
      'description': 'Healthy breakfast meal',
      'completed': false,
      'icon': Icons.restaurant,
    },
    {
      'time': '10:00 AM',
      'activity': 'Medication',
      'description': 'Take prescribed medications',
      'completed': false,
      'icon': Icons.medication,
    },
    {
      'time': '12:00 PM',
      'activity': 'Lunch',
      'description': 'Nutritious lunch',
      'completed': false,
      'icon': Icons.lunch_dining,
    },
    {
      'time': '02:00 PM',
      'activity': 'Rest Time',
      'description': 'Afternoon nap or relaxation',
      'completed': false,
      'icon': Icons.bedtime,
    },
    {
      'time': '04:00 PM',
      'activity': 'Social Activity',
      'description': 'Call family or friends',
      'completed': false,
      'icon': Icons.phone,
    },
    {
      'time': '06:00 PM',
      'activity': 'Dinner',
      'description': 'Evening meal',
      'completed': false,
      'icon': Icons.dinner_dining,
    },
    {
      'time': '08:00 PM',
      'activity': 'Medication',
      'description': 'Evening medications',
      'completed': false,
      'icon': Icons.medication,
    },
    {
      'time': '09:00 PM',
      'activity': 'Bedtime',
      'description': 'Prepare for sleep',
      'completed': false,
      'icon': Icons.bed,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRoutinesForDate(_selectedDate);
  }

  void _loadRoutinesForDate(DateTime date) {
    // TODO: Load routines from database for selected date
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _routines.where((r) => r['completed'] == true).length;
    final progressPercentage = (_routines.isEmpty ? 0 : (completedCount / _routines.length * 100)).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Routine',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2196F3).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Date selector
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(
                            const Duration(days: 1),
                          );
                        });
                        _loadRoutinesForDate(_selectedDate);
                      },
                    ),
                    Column(
                      children: [
                        Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getDayName(_selectedDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(
                            const Duration(days: 1),
                          );
                        });
                        _loadRoutinesForDate(_selectedDate);
                      },
                    ),
                  ],
                ),
              ),
              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress: $completedCount/${_routines.length} completed ($progressPercentage%)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _routines.isEmpty ? 0 : (completedCount / _routines.length),
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completedCount == _routines.length ? Colors.green : const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Routine list
              Expanded(
                child: _routines.isEmpty
                    ? Center(
                        child: Text(
                          'No routines scheduled for this day',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _routines.length,
                        itemBuilder: (context, index) {
                          final routine = _routines[index];
                          return _buildRoutineCard(routine, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineCard(Map<String, dynamic> routine, int index) {
    final isCompleted = routine['completed'] as bool;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _routines[index]['completed'] = !isCompleted;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isCompleted
                ? Colors.green.withOpacity(0.1)
                : Colors.white,
            border: Border.all(
              color: isCompleted
                  ? Colors.green
                  : Colors.grey.withOpacity(0.3),
              width: isCompleted ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Time
              SizedBox(
                width: 80,
                child: Text(
                  routine['time'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? Colors.green[700]
                        : const Color(0xFF2196F3),
                  ),
                ),
              ),
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getIconColor(routine['icon'] as IconData).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  routine['icon'] as IconData,
                  color: _getIconColor(routine['icon'] as IconData),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Activity details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine['activity'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      routine['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Checkbox
              Checkbox(
                value: isCompleted,
                onChanged: (value) {
                  setState(() {
                    _routines[index]['completed'] = value ?? false;
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconColor(IconData icon) {
    return icon == Icons.medication ? Colors.red : const Color(0xFF2196F3);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDayName(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}

