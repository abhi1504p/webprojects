import 'dart:io';
import 'package:realm/realm.dart';
import '../model/room_model.dart';

class MongoDBService {
  static MongoDBService? _instance;
  static MongoDBService get instance {
    _instance ??= MongoDBService._();
    return _instance!;
  }

  MongoDBService._();

  Realm? _realm;
  late RealmConfiguration _config;

  // Initialize MongoDB Realm connection
  Future<void> initialize() async {
    try {
      // Update with your MongoDB Atlas App Services App ID
      final appId = 'your-mongodb-realm-app-id'; // Replace with your actual App ID
      
      // For web, we'll use local Realm storage that can sync later
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        _config = Configuration.local([Room.schema]);
      } else {
        // For mobile, you can use sync configuration
        _config = Configuration.local([Room.schema]);
      }
      
      _realm = Realm(_config);
      print('MongoDB Realm initialized successfully');
    } catch (e) {
      print('Failed to initialize MongoDB Realm: $e');
      rethrow;
    }
  }

  // Get all rooms
  List<Room> getAllRooms() {
    try {
      final results = _realm?.all<Room>();
      return results?.toList() ?? [];
    } catch (e) {
      print('Error fetching rooms: $e');
      return [];
    }
  }

  // Add a new room
  Future<bool> addRoom(Room room) async {
    try {
      _realm?.write(() {
        _realm?.add(room);
      });
      return true;
    } catch (e) {
      print('Error adding room: $e');
      return false;
    }
  }

  // Update a room
  Future<bool> updateRoom(String roomId, Map<String, dynamic> updates) async {
    try {
      final room = _realm?.find<Room>(roomId);
      if (room != null) {
        _realm?.write(() {
          if (updates.containsKey('roomNumber')) {
            room.roomNumber = updates['roomNumber'];
          }
          if (updates.containsKey('capacity')) {
            room.capacity = updates['capacity'];
          }
          if (updates.containsKey('hasAC')) {
            room.hasAC = updates['hasAC'];
          }
          if (updates.containsKey('hasAttachedWashroom')) {
            room.hasAttachedWashroom = updates['hasAttachedWashroom'];
          }
          if (updates.containsKey('isAllocated')) {
            room.isAllocated = updates['isAllocated'];
          }
          if (updates.containsKey('allocatedTo')) {
            room.allocatedTo = updates['allocatedTo'];
          }
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating room: $e');
      return false;
    }
  }

  // Delete a room
  Future<bool> deleteRoom(String roomId) async {
    try {
      final room = _realm?.find<Room>(roomId);
      if (room != null) {
        _realm?.write(() {
          _realm?.delete(room);
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting room: $e');
      return false;
    }
  }

  // Search rooms by criteria
  List<Room> searchRooms({
    int? capacity,
    bool? hasAC,
    bool? hasAttachedWashroom,
    bool? isAvailable,
  }) {
    try {
      var rooms = _realm?.all<Room>() ?? [];

      if (capacity != null) {
        rooms = rooms.query('capacity == \$0', [capacity]);
      }
      if (hasAC != null) {
        rooms = rooms.query('hasAC == \$0', [hasAC]);
      }
      if (hasAttachedWashroom != null) {
        rooms = rooms.query('hasAttachedWashroom == \$0', [hasAttachedWashroom]);
      }
      if (isAvailable != null) {
        rooms = rooms.query('isAllocated == \$0', [!isAvailable]);
      }

      return rooms.toList();
    } catch (e) {
      print('Error searching rooms: $e');
      return [];
    }
  }

  // Allocate a room to a student
  Future<bool> allocateRoom(String roomId, String studentName) async {
    try {
      final room = _realm?.find<Room>(roomId);
      if (room != null && !room.isAllocated) {
        _realm?.write(() {
          room.isAllocated = true;
          room.allocatedTo = studentName;
          room.allocationDate = DateTime.now();
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error allocating room: $e');
      return false;
    }
  }

  // Deallocate a room
  Future<bool> deallocateRoom(String roomId) async {
    try {
      final room = _realm?.find<Room>(roomId);
      if (room != null) {
        _realm?.write(() {
          room.isAllocated = false;
          room.allocatedTo = null;
          room.allocationDate = null;
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error deallocating room: $e');
      return false;
    }
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    try {
      final rooms = _realm?.all<Room>() ?? [];
      final totalRooms = rooms.length;
      final allocatedRooms = rooms.query('isAllocated == true').length;
      final availableRooms = totalRooms - allocatedRooms;
      
      final acRooms = rooms.query('hasAC == true').length;
      final nonAcRooms = totalRooms - acRooms;
      
      final roomsWithWashroom = rooms.query('hasAttachedWashroom == true').length;
      final roomsWithoutWashroom = totalRooms - roomsWithWashroom;

      return {
        'totalRooms': totalRooms,
        'allocatedRooms': allocatedRooms,
        'availableRooms': availableRooms,
        'acRooms': acRooms,
        'nonAcRooms': nonAcRooms,
        'roomsWithWashroom': roomsWithWashroom,
        'roomsWithoutWashroom': roomsWithoutWashroom,
        'occupancyRate': totalRooms > 0 ? (allocatedRooms / totalRooms * 100).toStringAsFixed(1) : '0.0',
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'totalRooms': 0,
        'allocatedRooms': 0,
        'availableRooms': 0,
        'acRooms': 0,
        'nonAcRooms': 0,
        'roomsWithWashroom': 0,
        'roomsWithoutWashroom': 0,
        'occupancyRate': '0.0',
      };
    }
  }

  // Close the realm connection
  void close() {
    _realm?.close();
  }
}
