class GuardianModel {
  final String id;
  final String userId;
  final String contactName;
  final String contactPhone;
  final int priorityOrder;
  final String? createdAt;

  GuardianModel({
    required this.id,
    required this.userId,
    required this.contactName,
    required this.contactPhone,
    required this.priorityOrder,
    this.createdAt,
  });

  // Convert JSON from API to GuardianModel
  factory GuardianModel.fromJson(Map<String, dynamic> json) {
    return GuardianModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      priorityOrder: json['priority_order'] ?? 1,
      createdAt: json['created_at'],
    );
  }

  // Convert GuardianModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'priority_order': priorityOrder,
    };
  }
}