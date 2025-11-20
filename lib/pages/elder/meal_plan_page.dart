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
  final List<String> _fullDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
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
    2: { // Wednesday
      'breakfast': [
        {'name': 'Pancakes with berries', 'calories': 350, 'icon': Icons.breakfast_dining},
        {'name': 'Milk', 'calories': 100, 'icon': Icons.local_drink},
      ],
      'lunch': [
        {'name': 'Turkey sandwich', 'calories': 380, 'icon': Icons.lunch_dining},
        {'name': 'Vegetable sticks', 'calories': 50, 'icon': Icons.eco},
      ],
      'dinner': [
        {'name': 'Grilled fish', 'calories': 320, 'icon': Icons.dinner_dining},
        {'name': 'Brown rice', 'calories': 150, 'icon': Icons.eco},
      ],
      'snacks': [
        {'name': 'Cheese', 'calories': 110, 'icon': Icons.restaurant},
        {'name': 'Crackers', 'calories': 120, 'icon': Icons.bakery_dining},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final todayMeals = _mealPlans[_selectedDay] ?? _mealPlans[0]!;
    final totalCalories = _calculateTotalCalories(todayMeals);
    
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
              // Date display
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  _fullDays[_selectedDay],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ),
              // Day selector
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(7, (index) {
                      final isSelected = index == _selectedDay;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDay = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF9800)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFF9800).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
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
                      // Total calories with recommendation
                      _buildTotalCaloriesCard(totalCalories),
                      const SizedBox(height: 16),
                      // Nutritional info
                      _buildNutritionalInfoCard(),
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Subtotal: ${_calculateSectionCalories(meals)} kcal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
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
            meal['icon'] as IconData,
            size: 24,
            color: const Color(0xFFFF9800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              meal['name'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${meal['calories']} kcal',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCaloriesCard(int totalCalories) {
    final recommendedCalories = 2000; // Daily recommendation for elderly
    final percentage = ((totalCalories / recommendedCalories) * 100).toStringAsFixed(0);
    final isHealthy = totalCalories >= 1800 && totalCalories <= 2200;
    
    return Card(
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
        child: Column(
          children: [
            Row(
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
                  '$totalCalories kcal',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (totalCalories / recommendedCalories).clamp(0, 1).toDouble(),
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isHealthy ? Colors.green : Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recommended: $recommendedCalories kcal ($percentage%)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionalInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nutritional Tips',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTipItem(Icons.local_drink, 'Stay hydrated', 'Drink 6-8 glasses of water daily'),
            _buildTipItem(Icons.apple, 'Eat fruits & vegetables', 'Include variety in your meals'),
            _buildTipItem(Icons.fitness_center, 'Light exercise', 'Take walks after meals'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF9800), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
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

