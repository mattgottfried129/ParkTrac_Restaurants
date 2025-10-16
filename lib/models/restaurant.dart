import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@HiveType(typeId: 0)
class Restaurant extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String location;

  @HiveField(3)
  String type;

  @HiveField(4)
  String resort;

  @HiveField(5)
  bool visited;

  @HiveField(6)
  double ratingMatt;

  @HiveField(7)
  double ratingHeather;

  Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.resort,
    this.visited = false,
    this.ratingMatt = 0.0,
    this.ratingHeather = 0.0,
  });

  /// ✅ Firestore: create from DocumentSnapshot
  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      type: data['type'] ?? '',
      resort: data['resort'] ?? '',
      visited: data['visited'] ?? false,
      ratingMatt: (data['ratingMatt'] ?? 0).toDouble(),
      ratingHeather: (data['ratingHeather'] ?? 0).toDouble(),
    );
  }

  /// ✅ Firestore: for older FirestoreService using fromMap/toMap
  factory Restaurant.fromMap(Map<String, dynamic> map, String id) {
    return Restaurant(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      type: map['type'] ?? '',
      resort: map['resort'] ?? '',
      visited: map['visited'] ?? false,
      ratingMatt: (map['ratingMatt'] ?? 0).toDouble(),
      ratingHeather: (map['ratingHeather'] ?? 0).toDouble(),
    );
  }
  Map<String, dynamic> toMap() => toFirestore();

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'type': type,
      'resort': resort,
      'visited': visited,
      'ratingMatt': ratingMatt,
      'ratingHeather': ratingHeather,
    };
  }
}
