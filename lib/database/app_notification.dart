import 'dart:convert';

class AppNotification {
  final String title;
  final String body;
  final DateTime receivedAt;
  final String origin; // foreground | background | terminated

  const AppNotification({
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.origin,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
        'origin': origin,
      };

  factory AppNotification.fromMap(Map<String, dynamic> m) => AppNotification(
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        receivedAt: DateTime.tryParse(m['receivedAt'] as String? ?? '') ?? DateTime.now(),
        origin: m['origin'] as String? ?? 'foreground',
      );

  static String encodeList(List<AppNotification> l) =>
      jsonEncode(l.map((e) => e.toMap()).toList());

  static List<AppNotification> decodeList(String? s) {
    if (s == null || s.isEmpty) return [];
    final raw = jsonDecode(s) as List;
    return raw.map((e) => AppNotification.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }
}
