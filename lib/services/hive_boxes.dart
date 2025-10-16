import 'package:hive/hive.dart';
import '../models/restaurant.dart';

class HiveBoxes {
  static late Box<Restaurant> restaurants;

  static Future<void> openAll() async {
    restaurants = await Hive.openBox<Restaurant>('restaurants');
  }
}
