import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';

class FirestoreImportService {
  static Future<void> importRestaurants() async {
    final firestore = FirebaseFirestore.instance;

    // Load CSV from assets
    final raw = await rootBundle.loadString('assets/restaurants.csv');
    final lines = LineSplitter.split(raw).toList();

    // First line is header
    final headers = lines.first.split(',');
    final rows = lines.skip(1);

    int imported = 0;
    for (var line in rows) {
      final values = line.split(',');

      // Safeguard against malformed rows
      if (values.length != headers.length) continue;

      final data = Map.fromIterables(headers, values);

      final restaurant = Restaurant(
        id: data['name']!.trim(), // use name as Firestore doc ID for simplicity
        name: data['name']!.trim(),
        location: data['location']?.trim() ?? '',
        type: data['type']?.trim() ?? '',
        resort: data['resort']?.trim() ?? '',
        visited: (data['visited']?.trim().toLowerCase() == 'true'),
        ratingHeather: double.tryParse(data['ratingHeather'] ?? '0') ?? 0.0,
        ratingMatt: double.tryParse(data['ratingMatt'] ?? '0') ?? 0.0,
      );

      await firestore.collection('restaurants').doc(restaurant.id).set(restaurant.toFirestore());
      imported++;
    }

    print('✅ Imported $imported restaurants into Firestore');
  }
}
