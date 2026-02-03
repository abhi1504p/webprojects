import 'package:companyproject/model/room_filter_model.dart';
import 'package:companyproject/model/room_model.dart';
import 'package:companyproject/model/student_requirenment_model.dart';
import 'package:companyproject/services/mongodb_service.dart';
import 'package:uuid/uuid.dart';

class RoomRepository {
  final MongoDBService _mongoDBService = MongoDBService.instance;
  bool _isInitialized = false;

  RoomRepository() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _mongoDBService.initialize();
      _isInitialized = true;
      
      // Add some sample data if database is empty
      final rooms = _mongoDBService.getAllRooms();
      if (rooms.isEmpty) {
        await _addSampleData();
      }
    } catch (e) {
      print('Failed to initialize RoomRepository: $e');
    }
  }

  Future<void> _addSampleData() async {
    final sampleRooms = [
      Room(
        id: const Uuid().v4(),
        roomNumber: '101',
        capacity: 2,
        hasAC: true,
        hasAttachedWashroom: true,
      ),
      Room(
        id: const Uuid().v4(),
        roomNumber: '102',
        capacity: 3,
        hasAC: false,
        hasAttachedWashroom: true,
      ),
      Room(
        id: const Uuid().v4(),
        roomNumber: '103',
        capacity: 1,
        hasAC: true,
        hasAttachedWashroom: false,
      ),
      Room(
        id: const Uuid().v4(),
        roomNumber: '201',
        capacity: 4,
        hasAC: true,
        hasAttachedWashroom: true,
      ),
      Room(
        id: const Uuid().v4(),
        roomNumber: '202',
        capacity: 2,
        hasAC: false,
        hasAttachedWashroom: false,
      ),
    ];

    for (final room in sampleRooms) {
      await _mongoDBService.addRoom(room);
    }
  }

  Future<List<Room>> getAllRooms() async {
    if (!_isInitialized) {
      await _initialize();
    }
    
    try {
      return _mongoDBService.getAllRooms();
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }
  }

  Future<Room> addRoom(Room room) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      // Check if room number already exists
      final existingRooms = _mongoDBService.getAllRooms();
      if (existingRooms.any((r) => r.roomNumber == room.roomNumber)) {
        throw Exception('Room number ${room.roomNumber} already exists');
      }

      // Generate ID if empty
      final roomToAdd = room.id.isEmpty 
          ? room.copyWith(id: const Uuid().v4())
          : room;

      final success = await _mongoDBService.addRoom(roomToAdd);
      if (!success) {
        throw Exception('Failed to add room');
      }

      return roomToAdd;
    } catch (e) {
      throw Exception('Failed to add room: $e');
    }
  }

  Future<Room?> getRoomById(String id) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      final rooms = _mongoDBService.getAllRooms();
      try {
        return rooms.firstWhere((room) => room.id == id);
      } catch (e) {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get room by ID: $e');
    }
  }

  Future<Room?> getRoomByNumber(String roomNumber) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      final rooms = _mongoDBService.getAllRooms();
      try {
        return rooms.firstWhere((room) => room.roomNumber == roomNumber);
      } catch (e) {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get room by number: $e');
    }
  }

  Future<List<Room>> searchRooms(RoomFilter filter) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      return _mongoDBService.searchRooms(
        capacity: filter.minCapacity,
        hasAC: filter.requiresAC,
        hasAttachedWashroom: filter.requiresAttachedWashroom,
        isAvailable: filter.showOnlyAvailable,
      );
    } catch (e) {
      throw Exception('Failed to search rooms: $e');
    }
  }

  Future<Room?> findBestMatch(StudentRequirement requirement) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      final availableRooms = _mongoDBService.searchRooms(
        capacity: requirement.requiredCapacity,
        hasAC: requirement.needsAC,
        hasAttachedWashroom: requirement.needsAttachedWashroom,
        isAvailable: true,
      );

      if (availableRooms.isEmpty) {
        return null;
      }

      // Sort by best match (smallest capacity that fits, then by amenities)
      availableRooms.sort((a, b) {
        // First priority: exact capacity match
        if (a.capacity == requirement.requiredCapacity &&
            b.capacity != requirement.requiredCapacity) {
          return -1;
        }
        if (b.capacity == requirement.requiredCapacity &&
            a.capacity != requirement.requiredCapacity) {
          return 1;
        }

        // Second priority: smaller capacity (minimize waste)
        int capacityCompare = a.capacity.compareTo(b.capacity);
        if (capacityCompare != 0) return capacityCompare;

        // Third priority: amenities (prefer rooms with more amenities)
        int aScore = (a.hasAC ? 1 : 0) + (a.hasAttachedWashroom ? 1 : 0);
        int bScore = (b.hasAC ? 1 : 0) + (b.hasAttachedWashroom ? 1 : 0);
        return bScore.compareTo(aScore);
      });

      return availableRooms.first;
    } catch (e) {
      throw Exception('Failed to find best match: $e');
    }
  }

  Future<Room> allocateRoom(String roomId, String studentName) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      final room = await getRoomById(roomId);
      if (room == null) {
        throw Exception('Room not found');
      }

      if (room.isAllocated) {
        throw Exception('Room is already allocated');
      }

      final success = await _mongoDBService.allocateRoom(roomId, studentName);
      if (!success) {
        throw Exception('Failed to allocate room');
      }

      return room.copyWith(
        isAllocated: true,
        allocatedTo: studentName,
        allocationDate: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to allocate room: $e');
    }
  }

  Future<Room> deallocateRoom(String roomId) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      final room = await getRoomById(roomId);
      if (room == null) {
        throw Exception('Room not found');
      }

      final success = await _mongoDBService.deallocateRoom(roomId);
      if (!success) {
        throw Exception('Failed to deallocate room');
      }

      return room.copyWith(
        isAllocated: false,
        allocatedTo: null,
        allocationDate: null,
      );
    } catch (e) {
      throw Exception('Failed to deallocate room: $e');
    }
  }

  Future<bool> deleteRoom(String roomId) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      return await _mongoDBService.deleteRoom(roomId);
    } catch (e) {
      throw Exception('Failed to delete room: $e');
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      return _mongoDBService.getStatistics();
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}
