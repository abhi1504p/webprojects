

import 'package:companyproject/model/room_filter_model.dart';
import 'package:companyproject/model/room_model.dart';
import 'package:companyproject/model/student_requirenment_model.dart';

class RoomRepository {
  // Mock database - in-memory storage
  final List<Room> _rooms = [];
  int _idCounter = 1;

  RoomRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Add some initial rooms for demonstration
    _rooms.addAll([
      Room(
        id: '${_idCounter++}',
        roomNumber: '101',
        capacity: 2,
        hasAC: true,
        hasAttachedWashroom: true,
      ),
      Room(
        id: '${_idCounter++}',
        roomNumber: '102',
        capacity: 3,
        hasAC: false,
        hasAttachedWashroom: true,
      ),
      Room(
        id: '${_idCounter++}',
        roomNumber: '103',
        capacity: 1,
        hasAC: true,
        hasAttachedWashroom: false,
      ),
      Room(
        id: '${_idCounter++}',
        roomNumber: '201',
        capacity: 4,
        hasAC: true,
        hasAttachedWashroom: true,
      ),
      Room(
        id: '${_idCounter++}',
        roomNumber: '202',
        capacity: 2,
        hasAC: false,
        hasAttachedWashroom: false,
      ),
    ]);
  }

  // Simulate async operations with Future.delayed
  Future<List<Room>> getAllRooms() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_rooms);
  }

  Future<Room> addRoom(Room room) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Check if room number already exists
    if (_rooms.any((r) => r.roomNumber == room.roomNumber)) {
      throw Exception('Room number ${room.roomNumber} already exists');
    }

    final newRoom = room.copyWith(id: '${_idCounter++}');
    _rooms.add(newRoom);
    return newRoom;
  }

  Future<Room?> getRoomById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _rooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Room?> getRoomByNumber(String roomNumber) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _rooms.firstWhere((room) => room.roomNumber == roomNumber);
    } catch (e) {
      return null;
    }
  }

  Future<List<Room>> searchRooms(RoomFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 400));

    List<Room> filteredRooms = List.from(_rooms);

    if (filter.minCapacity != null) {
      filteredRooms = filteredRooms
          .where((room) => room.capacity >= filter.minCapacity!)
          .toList();
    }

    if (filter.requiresAC != null && filter.requiresAC!) {
      filteredRooms =
          filteredRooms.where((room) => room.hasAC == true).toList();
    }

    if (filter.requiresAttachedWashroom != null &&
        filter.requiresAttachedWashroom!) {
      filteredRooms = filteredRooms
          .where((room) => room.hasAttachedWashroom == true)
          .toList();
    }

    if (filter.showOnlyAvailable != null && filter.showOnlyAvailable!) {
      filteredRooms =
          filteredRooms.where((room) => !room.isAllocated).toList();
    }

    return filteredRooms;
  }

  Future<Room?> findBestMatch(StudentRequirement requirement) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Get all available rooms
    List<Room> availableRooms =
    _rooms.where((room) => !room.isAllocated).toList();

    if (availableRooms.isEmpty) {
      return null;
    }

    // Filter by requirements
    List<Room> matchingRooms = availableRooms.where((room) {
      bool capacityMatch = room.capacity >= requirement.requiredCapacity;
      bool acMatch = !requirement.needsAC || room.hasAC;
      bool washroomMatch =
          !requirement.needsAttachedWashroom || room.hasAttachedWashroom;

      return capacityMatch && acMatch && washroomMatch;
    }).toList();

    if (matchingRooms.isEmpty) {
      return null;
    }

    // Sort by best match (smallest capacity that fits, then by amenities)
    matchingRooms.sort((a, b) {
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

    return matchingRooms.first;
  }

  Future<Room> allocateRoom(String roomId, String studentName) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);

    if (roomIndex == -1) {
      throw Exception('Room not found');
    }

    if (_rooms[roomIndex].isAllocated) {
      throw Exception('Room is already allocated');
    }

    final updatedRoom = _rooms[roomIndex].copyWith(
      isAllocated: true,
      allocatedTo: studentName,
      allocationDate: DateTime.now(),
    );

    _rooms[roomIndex] = updatedRoom;
    return updatedRoom;
  }

  Future<Room> deallocateRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);

    if (roomIndex == -1) {
      throw Exception('Room not found');
    }

    final updatedRoom = _rooms[roomIndex].copyWith(
      isAllocated: false,
      allocatedTo: null,
      allocationDate: null,
    );

    _rooms[roomIndex] = updatedRoom;
    return updatedRoom;
  }

  Future<bool> deleteRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);

    if (roomIndex == -1) {
      return false;
    }

    _rooms.removeAt(roomIndex);
    return true;
  }

  Future<Map<String, dynamic>> getStatistics() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final totalRooms = _rooms.length;
    final allocatedRooms = _rooms.where((r) => r.isAllocated).length;
    final availableRooms = totalRooms - allocatedRooms;
    final acRooms = _rooms.where((r) => r.hasAC).length;
    final washroomRooms = _rooms.where((r) => r.hasAttachedWashroom).length;
    final totalCapacity = _rooms.fold(0, (sum, room) => sum + room.capacity);

    return {
      'totalRooms': totalRooms,
      'allocatedRooms': allocatedRooms,
      'availableRooms': availableRooms,
      'acRooms': acRooms,
      'washroomRooms': washroomRooms,
      'totalCapacity': totalCapacity,
      'occupancyRate':
      totalRooms > 0 ? (allocatedRooms / totalRooms * 100).toStringAsFixed(1) : '0.0',
    };
  }
}