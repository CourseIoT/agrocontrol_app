class Plantation {
  final String seedName;
  final int quantity;
  final DateTime startDate;
  DateTime? finishDate;

  Plantation({
    required this.seedName,
    required this.quantity,
    required this.startDate,
    this.finishDate,
  });
}
