import 'dart:convert';

class Item {
  final int id;
  final String title;
  final String message;
  final String time;
  final int isRead;

  Item({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] ?? 0,
      title: map['Notification_header'] ?? '', // Adjust keys accordingly
      message: map['Notification_message'] ?? '',
      time: map['Notification_send_time'] ?? DateTime.now().toString(),
      isRead: map['COLUMN_IS_READ'] ?? 0,
    );
  }


  @override
  String toString() {
    return 'Item(id: $id, title: $title, message: $message, time: $time, isRead: $isRead)';
  }
}
