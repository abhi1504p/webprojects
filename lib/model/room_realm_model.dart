import 'package:realm/realm.dart';

part 'room_realm_model.g.dart';

@RealmModel()
class _Room {
  @PrimaryKey()
  late ObjectId id;
  late String roomNumber;
  late int capacity;
  late bool hasAC;
  late bool hasAttachedWashroom;
  bool isAllocated = false;
  String? allocatedTo;
  DateTime? allocationDate;
}
