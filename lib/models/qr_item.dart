class QRItem {
  final String id;
  final String text;
  final DateTime createdAt;

  QRItem({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory QRItem.fromJson(Map<String, dynamic> json) => QRItem(
        id: json['id'],
        text: json['text'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
