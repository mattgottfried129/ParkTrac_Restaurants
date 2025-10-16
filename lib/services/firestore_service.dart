import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant.dart';
import 'hive_boxes.dart';

/// Handles both Firestore and Hive syncing for restaurants
class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _collection = _db.collection('restaurants');
  static final _localBox = HiveBoxes.restaurants;

  /// 🔁 Real-time stream from Firestore, synced to Hive for offline use
  static Stream<List<Restaurant>> streamRestaurants() {
    return _collection.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Restaurant.fromMap(doc.data(), doc.id))
          .toList();

      // Save latest data to Hive for offline use
      for (final r in list) {
        _localBox.put(r.name, r);
      }

      return list;
    });
  }

  /// 🧭 Load locally cached restaurants (used if offline)
  static List<Restaurant> getLocalRestaurants() {
    return _localBox.values.toList();
  }

  /// ➕ Add a new restaurant to both Firestore and Hive
  static Future<void> addRestaurant(Restaurant r) async {
    await _collection.doc(r.name).set(r.toMap());
    await _localBox.put(r.name, r);
  }

  /// 🔄 Update restaurant in both Firestore and Hive
  static Future<void> updateRestaurant(Restaurant r) async {
    await _collection.doc(r.name).update(r.toMap());
    await _localBox.put(r.name, r);
  }

  /// ❌ Delete restaurant in both Firestore and Hive
  static Future<void> deleteRestaurant(String name) async {
    await _collection.doc(name).delete();
    await _localBox.delete(name);
  }

  /// 🧩 One-time upload from Hive to Firestore (optional sync helper)
  static Future<void> syncLocalToCloud() async {
    for (final r in _localBox.values) {
      await _collection.doc(r.name).set(r.toMap());
    }
  }

  /// 🧲 One-time download from Firestore to Hive (optional)
  static Future<void> syncCloudToLocal() async {
    final snapshot = await _collection.get();
    for (final doc in snapshot.docs) {
      final r = Restaurant.fromMap(doc.data(), doc.id);
      await _localBox.put(r.name, r);
    }
  }
}
