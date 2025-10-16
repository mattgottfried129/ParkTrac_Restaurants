import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../theme/colors.dart';
import 'dashboard_screen.dart';
import 'restaurant_list_screen.dart';
import 'favorites_screen.dart';
import 'about_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    RestaurantListScreen(),
    FavoritesScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.cream,
        indicatorColor: AppColors.gold.withOpacity(0.25),
        elevation: 5,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: Icon(MdiIcons.castle, color: AppColors.wdw),
            selectedIcon: Icon(MdiIcons.castle, color: AppColors.gold),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(MdiIcons.foodForkDrink, color: AppColors.uni),
            selectedIcon: Icon(MdiIcons.foodForkDrink, color: AppColors.gold),
            label: 'Restaurants',
          ),
          NavigationDestination(
            icon: Icon(MdiIcons.star, color: AppColors.shadow),
            selectedIcon: Icon(MdiIcons.star, color: AppColors.gold),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(MdiIcons.informationOutline, color: AppColors.shadow),
            selectedIcon: Icon(MdiIcons.information, color: AppColors.gold),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
