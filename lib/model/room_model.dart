class Room {
  final String id;
  final String roomNumber;
  final int capacity;
  final bool hasAC;
  final bool hasAttachedWashroom;
  final bool isAllocated;
  final String? allocatedTo;
  final DateTime? allocationDate;

  Room({
    required this.id,
    required this.roomNumber,
    required this.capacity,
    required this.hasAC,
    required this.hasAttachedWashroom,
    this.isAllocated = false,
    this.allocatedTo,
    this.allocationDate,
  });

  Room copyWith({
    String? id,
    String? roomNumber,
    int? capacity,
    bool? hasAC,
    bool? hasAttachedWashroom,
    bool? isAllocated,
    String? allocatedTo,
    DateTime? allocationDate,
  }) {
    return Room(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      capacity: capacity ?? this.capacity,
      hasAC: hasAC ?? this.hasAC,
      hasAttachedWashroom: hasAttachedWashroom ?? this.hasAttachedWashroom,
      isAllocated: isAllocated ?? this.isAllocated,
      allocatedTo: allocatedTo ?? this.allocatedTo,
      allocationDate: allocationDate ?? this.allocationDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'capacity': capacity,
      'hasAC': hasAC,
      'hasAttachedWashroom': hasAttachedWashroom,
      'isAllocated': isAllocated,
      'allocatedTo': allocatedTo,
      'allocationDate': allocationDate?.toIso8601String(),
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      roomNumber: json['roomNumber'] as String,
      capacity: json['capacity'] as int,
      hasAC: json['hasAC'] as bool,
      hasAttachedWashroom: json['hasAttachedWashroom'] as bool,
      isAllocated: json['isAllocated'] as bool? ?? false,
      allocatedTo: json['allocatedTo'] as String?,
      allocationDate: json['allocationDate'] != null
          ? DateTime.parse(json['allocationDate'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'Room{roomNumber: $roomNumber, capacity: $capacity, hasAC: $hasAC, hasAttachedWashroom: $hasAttachedWashroom, isAllocated: $isAllocated}';
  }
}