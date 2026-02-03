import 'package:companyproject/model/room_filter_model.dart';
import 'package:companyproject/model/room_model.dart';
import 'package:companyproject/model/student_requirenment_model.dart';
import 'package:companyproject/repository/room_repository.dart';
import 'package:flutter/foundation.dart';


class RoomViewModel extends ChangeNotifier {
  final RoomRepository _repository = RoomRepository();

  List<Room> _allRooms = [];
  List<Room> _filteredRooms = [];
  RoomFilter _currentFilter = RoomFilter();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statistics;

  // Getters
  List<Room> get allRooms => _allRooms;
  List<Room> get filteredRooms => _filteredRooms;
  RoomFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get statistics => _statistics;
  bool get hasActiveFilters => _currentFilter.hasActiveFilters;

  RoomViewModel() {
    loadRooms();
    loadStatistics();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadRooms() async {
    _setLoading(true);
    _setError(null);

    try {
      _allRooms = await _repository.getAllRooms();
      _filteredRooms = List.from(_allRooms);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load rooms: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStatistics() async {
    try {
      _statistics = await _repository.getStatistics();
      notifyListeners();
    } catch (e) {
      // Silent fail for statistics
      if (kDebugMode) {
        print('Failed to load statistics: $e');
      }
    }
  }

  Future<bool> addRoom({
    required String roomNumber,
    required int capacity,
    required bool hasAC,
    required bool hasAttachedWashroom,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final newRoom = Room(
        id: '', // Will be assigned by repository
        roomNumber: roomNumber,
        capacity: capacity,
        hasAC: hasAC,
        hasAttachedWashroom: hasAttachedWashroom,
      );

      await _repository.addRoom(newRoom);
      await loadRooms();
      await loadStatistics();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> applyFilters(RoomFilter filter) async {
    _setLoading(true);
    _setError(null);
    _currentFilter = filter;

    try {
      if (!filter.hasActiveFilters) {
        _filteredRooms = List.from(_allRooms);
      } else {
        _filteredRooms = await _repository.searchRooms(filter);
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to apply filters: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearFilters() async {
    _currentFilter = RoomFilter();
    _filteredRooms = List.from(_allRooms);
    notifyListeners();
  }

  Future<Room?> findBestMatchingRoom(
      StudentRequirement requirement) async {
    _setLoading(true);
    _setError(null);

    try {
      final room = await _repository.findBestMatch(requirement);
      return room;
    } catch (e) {
      _setError('Failed to find matching room: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> allocateRoomToStudent({
    required String roomId,
    required String studentName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.allocateRoom(roomId, studentName);
      await loadRooms();
      await loadStatistics();

      // Reapply current filters
      if (_currentFilter.hasActiveFilters) {
        await applyFilters(_currentFilter);
      }

      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deallocateRoom(String roomId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.deallocateRoom(roomId);
      await loadRooms();
      await loadStatistics();

      // Reapply current filters
      if (_currentFilter.hasActiveFilters) {
        await applyFilters(_currentFilter);
      }

      return true;
    } catch (e) {
      _setError('Failed to deallocate room: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteRoom(String roomId) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _repository.deleteRoom(roomId);
      if (success) {
        await loadRooms();
        await loadStatistics();

        // Reapply current filters
        if (_currentFilter.hasActiveFilters) {
          await applyFilters(_currentFilter);
        }
      }
      return success;
    } catch (e) {
      _setError('Failed to delete room: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}