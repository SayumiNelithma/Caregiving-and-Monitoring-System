import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class MealPlanPage extends StatefulWidget {
  final AppUser user;
  
  const MealPlanPage({super.key, required this.user});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  int _selectedDay = DateTime.now().weekday - 1; // 0-6 for Monday-Sunday
  
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // Sample meal plan data - in a real app, this would come from AI or database
  final Map<int, Map<String, List<Map<String, dynamic>>>> _mealPlans = {
    0: { // Monday
      'breakfast': [
        {'name': 'Oatmeal with fruits', 'calories': 300, 'icon': Icons.breakfast_dining},
        {'name': 'Orange juice', 'calories': 120, 'icon': Icons.local_drink},
      ],
      'lunch': [
        {'name': 'Grilled chicken salad', 'calories': 400, 'icon': Icons.lunch_dining},
        {'name': 'Whole grain bread', 'calories': 150, 'icon': Icons.bakery_dining},
      ],
      'dinner': [
        {'name': 'Baked salmon', 'calories': 350, 'icon': Icons.dinner_dining},
        {'name': 'Steamed vegetables', 'calories': 100, 'icon': Icons.eco},
      ],
      'snacks': [
        {'name': 'Apple', 'calories': 80, 'icon': Icons.apple},
        {'name': 'Yogurt', 'calories': 100, 'icon': Icons.icecream},
      ],
    },
    1: { // Tuesday
      'breakfast': [
        {'name': 'Scrambled eggs', 'calories': 250, 'icon': Icons.breakfast_dining},
        {'name': 'Whole wheat toast', 'calories': 150, 'icon': Icons.bakery_dining},
      ],
      'lunch': [
        {'name': 'Vegetable soup', 'calories': 200, 'icon': Icons.lunch_dining},
        {'name': 'Sandwich', 'calories': 350, 'icon': Icons.fastfood},
      ],
      'dinner': [
        {'name': 'Pasta with vegetables', 'calories': 400, 'icon': Icons.dinner_dining},
        {'name': 'Green salad', 'calories': 80, 'icon': Icons.eco},
      ],
      'snacks': [
        {'name': 'Banana', 'calories': 90, 'icon': Icons.apple},
        {'name': 'Nuts', 'calories': 150, 'icon': Icons.circle},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final todayMeals = _mealPlans[_selectedDay] ?? _mealPlans[0]!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meal Planner',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF9800).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Day selector
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final isSelected = index == _selectedDay;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF9800)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _days[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Meal plan content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMealSection('Breakfast', todayMeals['breakfast']!, Icons.breakfast_dining, const Color(0xFFFF9800)),
                      const SizedBox(height: 16),
                      _buildMealSection('Lunch', todayMeals['lunch']!, Icons.lunch_dining, const Color(0xFF4CAF50)),
                      const SizedBox(height: 16),
                      _buildMealSection('Dinner', todayMeals['dinner']!, Icons.dinner_dining, const Color(0xFF2196F3)),
                      const SizedBox(height: 16),
                      _buildMealSection('Snacks', todayMeals['snacks']!, Icons.fastfood, const Color(0xFF9C27B0)),
                      const SizedBox(height: 24),
                      // Total calories
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFF9800).withOpacity(0.2),
                                const Color(0xFFFF9800).withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Calories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_calculateTotalCalories(todayMeals)} kcal',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF9800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection(String title, List<Map<String, dynamic>> meals, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...meals.map((meal) => _buildMealItem(meal)),
            const SizedBox(height: 8),
            Text(
              'Subtotal: ${_calculateSectionCalories(meals)} kcal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(Map<String, dynamic> meal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            meal['icon'],
            size: 24,
            color: const Color(0xFFFF9800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              meal['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${meal['calories']} kcal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSectionCalories(List<Map<String, dynamic>> meals) {
    return meals.fold(0, (sum, meal) => sum + (meal['calories'] as int));
  }

  int _calculateTotalCalories(Map<String, List<Map<String, dynamic>>> meals) {
    int total = 0;
    meals.values.forEach((mealList) {
      total += _calculateSectionCalories(mealList);
    });
    return total;
  }
}

