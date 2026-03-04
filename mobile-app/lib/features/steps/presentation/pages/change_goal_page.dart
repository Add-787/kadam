import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../bloc/steps_bloc.dart';

class ChangeGoalPage extends StatefulWidget {
  const ChangeGoalPage({super.key});

  @override
  State<ChangeGoalPage> createState() => _ChangeGoalPageState();
}

class _ChangeGoalPageState extends State<ChangeGoalPage> {
  late FixedExtentScrollController _scrollController;
  late int _selectedGoal;
  
  final List<int> _goals = List.generate(
    (50000 - 1000 + 500) ~/ 500,
    (index) => 1000 + (index * 500),
  );

  @override
  void initState() {
    super.initState();
    final currentGoal = context.read<StepsBloc>().state.dailyGoal;
    _selectedGoal = currentGoal;
    
    int initialIndex = _goals.indexOf(currentGoal);
    if (initialIndex == -1) {
      // Find closest goal
      initialIndex = _goals.indexWhere((goal) => goal >= currentGoal);
      if (initialIndex == -1) initialIndex = _goals.length - 1;
    }
    
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Change Daily Goal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Select your daily step goal',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$_selectedGoal steps',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 250,
              child: CupertinoPicker(
                scrollController: _scrollController,
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedGoal = _goals[index];
                  });
                },
                children: _goals.map((goal) {
                  return Center(
                    child: Text(
                      goal.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  context.read<StepsBloc>().add(GoalChanged(_selectedGoal));
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Goal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
