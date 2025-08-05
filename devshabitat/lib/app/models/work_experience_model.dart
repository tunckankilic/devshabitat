class WorkExperience {
  final String title;
  final String company;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrentRole;

  WorkExperience({
    required this.title,
    required this.company,
    required this.startDate,
    this.endDate,
    this.isCurrentRole = false,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isCurrentRole: json['isCurrentRole'] ?? false,
    );
  }
}
