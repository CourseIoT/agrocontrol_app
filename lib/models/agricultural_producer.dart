class AgriculturalProducer {
  final int userId;
  final int agriculturalProducerId;
  final String fullName;
  final String city;
  final String country;
  final String phone;
  final String dni;

  const AgriculturalProducer({
    required this.userId,
    required this.agriculturalProducerId,
    required this.fullName,
    required this.city,
    required this.country,
    required this.phone,
    required this.dni,
  });

  factory AgriculturalProducer.fromJson(Map<String, dynamic> json) {
    return AgriculturalProducer(
      userId: json['userId'] as int,
      agriculturalProducerId: json['agriculturalProducerId'] as int,
      fullName: json['fullName'] ?? 'Usuario',
      city: json['city'] ?? 'N/A',
      country: json['country'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      dni: json['dni'] ?? 'N/A',
    );
  }
}
