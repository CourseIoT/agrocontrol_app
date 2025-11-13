class Field {
  final int id;
  final int producerId;
  final String name;
  final String location;
  final int landSize;
  final String imageUrl;

  const Field({
    required this.id,
    required this.producerId,
    required this.name,
    required this.location,
    required this.landSize,
    required this.imageUrl,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] as int,
      producerId: json['producerId'] as int,
      name: json['fieldName'] ?? 'Nombre no disponible',
      location: json['location'] ?? 'Ubicación no disponible',
      landSize: (json['size']),
      imageUrl: 'assets/images/farm_background.png',
    );
  }
}
