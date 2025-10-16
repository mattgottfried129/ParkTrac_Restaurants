import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About ParkTrac'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ParkTrac: Disney & Universal Restaurant Tracker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.wdw,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Track every restaurant you visit across Walt Disney World and Universal Orlando. '
                  'See progress charts, add personal ratings, and mark your magical dining experiences.',
              style: TextStyle(color: AppColors.textDark),
            ),
            SizedBox(height: 24),
            Text(
              'Created by Matthew R. Gottfried, CPA, MSA\n© 2025 All Rights Reserved',
              style: TextStyle(color: AppColors.shadow, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
