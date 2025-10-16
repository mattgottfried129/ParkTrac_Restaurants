import 'package:hive/hive.dart';
import 'restaurant.dart';

class RestaurantAdapter extends TypeAdapter<Restaurant> {
  @override
  final int typeId = 0;

  @override
  Restaurant read(BinaryReader reader) {
    return Restaurant(
      id: reader.readString(),
      name: reader.readString(),
      location: reader.readString(),
      type: reader.readString(),
      resort: reader.readString(),
      visited: reader.readBool(),
      ratingMatt: reader.readDouble(),
      ratingHeather: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Restaurant obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.location)
      ..writeString(obj.type)
      ..writeString(obj.resort)
      ..writeBool(obj.visited)
      ..writeDouble(obj.ratingMatt)
      ..writeDouble(obj.ratingHeather);
  }
}
