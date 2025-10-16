import 'package:flutter/material.dart';
import '../theme/colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: const Center(
        child: Text(
          'Your 5-star favorites will appear here ⭐',
          style: TextStyle(color: AppColors.textDark),
        ),
      ),
    );
  }
}
