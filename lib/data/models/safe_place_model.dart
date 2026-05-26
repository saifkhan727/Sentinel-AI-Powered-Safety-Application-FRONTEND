class SafePlaceModel {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String? address;
  final String? phone;
  final double? distance;
  final double? rating;
  final bool? isOpen;

  SafePlaceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.phone,
    this.distance,
    this.rating,
    this.isOpen,
  });

  factory SafePlaceModel.fromJson(Map<String, dynamic> json) {
    return SafePlaceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      latitude: double.tryParse(
          json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(
          json['longitude'].toString()) ?? 0.0,
      address: json['address'],
      phone: json['phone'],
      distance: json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : null,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      isOpen: json['is_open'],
    );
  }
}