import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/restaurant.dart';
import 'hive_boxes.dart';

class ImportService {
  static Future<void> importRestaurantsOnce() async {
    final box = HiveBoxes.restaurants;
    if (box.isEmpty) {
      final csvData = await rootBundle.loadString('assets/restaurants.csv');
      final lines = const LineSplitter().convert(csvData);
      if (lines.isEmpty) return;

      final headers = lines.first.split(',').map((h) => h.trim()).toList();

      for (int i = 1; i < lines.length; i++) {
        final raw = lines[i].trim();
        if (raw.isEmpty) continue;

        // Split while allowing commas in quoted values
        final values = _parseCsvLine(raw);
        if (values.length != headers.length) {
          print('⚠️ Skipping line $i due to length mismatch (${values.length} vs ${headers.length})');
          continue;
        }

        final data = <String, String>{};
        for (var j = 0; j < headers.length; j++) {
          data[headers[j]] = values[j];
        }

        final restaurant = Restaurant(
          name: data['name'] ?? '',
          location: data['location'] ?? '',
          type: data['type'] ?? '',
          resort: data['resort'] ?? '',
          visited: (data['visited'] ?? 'false').toLowerCase() == 'true',
          ratingHeather: double.tryParse(data['ratingHeather'] ?? '') ?? 0.0,
          ratingMatt: double.tryParse(data['ratingMatt'] ?? '') ?? 0.0,
        );

        await box.put(restaurant.name, restaurant);
      }

      print('✅ Restaurants imported successfully: ${box.length}');
    } else {
      print('ℹ️ Restaurants already imported — skipping.');
    }
  }

  /// Custom CSV parser to handle commas inside quotes correctly
  static List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result.map((s) => s.trim()).toList();
  }
}
