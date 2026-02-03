class RoomFilter {
  final int? minCapacity;
  final bool? requiresAC;
  final bool? requiresAttachedWashroom;
  final bool? showOnlyAvailable;

  RoomFilter({
    this.minCapacity,
    this.requiresAC,
    this.requiresAttachedWashroom,
    this.showOnlyAvailable,
  });

  RoomFilter copyWith({
    int? minCapacity,
    bool? requiresAC,
    bool? requiresAttachedWashroom,
    bool? showOnlyAvailable,
  }) {
    return RoomFilter(
      minCapacity: minCapacity ?? this.minCapacity,
      requiresAC: requiresAC ?? this.requiresAC,
      requiresAttachedWashroom:
      requiresAttachedWashroom ?? this.requiresAttachedWashroom,
      showOnlyAvailable: showOnlyAvailable ?? this.showOnlyAvailable,
    );
  }

  bool get hasActiveFilters {
    return minCapacity != null ||
        requiresAC != null ||
        requiresAttachedWashroom != null ||
        (showOnlyAvailable ?? false);
  }

  RoomFilter clear() {
    return RoomFilter(
      minCapacity: null,
      requiresAC: null,
      requiresAttachedWashroom: null,
      showOnlyAvailable: null,
    );
  }
}