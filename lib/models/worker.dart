class Worker {
  final int id;
  final int producerId;
  final String fullName;
  final String documentNumber;

  Worker({
    required this.id,
    required this.producerId,
    required this.fullName,
    required this.documentNumber,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as int,
      producerId: json['producerId'] as int,
      fullName: json['fullName'] as String,
      documentNumber: json['documentNumber'] as String,
    );
  }
}
