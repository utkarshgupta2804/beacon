class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final String type; // 'text', 'location', 'image', 'call'
  final DateTime timestamp;
  bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      content: json['content'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}