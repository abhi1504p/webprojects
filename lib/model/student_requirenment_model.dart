class StudentRequirement {
  final String studentName;
  final int requiredCapacity;
  final bool needsAC;
  final bool needsAttachedWashroom;

  StudentRequirement({
    required this.studentName,
    required this.requiredCapacity,
    required this.needsAC,
    required this.needsAttachedWashroom,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'requiredCapacity': requiredCapacity,
      'needsAC': needsAC,
      'needsAttachedWashroom': needsAttachedWashroom,
    };
  }

  factory StudentRequirement.fromJson(Map<String, dynamic> json) {
    return StudentRequirement(
      studentName: json['studentName'] as String,
      requiredCapacity: json['requiredCapacity'] as int,
      needsAC: json['needsAC'] as bool,
      needsAttachedWashroom: json['needsAttachedWashroom'] as bool,
    );
  }

  @override
  String toString() {
    return 'StudentRequirement{studentName: $studentName, requiredCapacity: $requiredCapacity, needsAC: $needsAC, needsAttachedWashroom: $needsAttachedWashroom}';
  }
}