class HelpCall {
  String? callId;
  DateTime timestamp;

  HelpCall({
    this.callId,
    required this.timestamp,
  });

  factory HelpCall.fromMap(Map<String, dynamic> data) {
    return HelpCall(
      callId: data['callId'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
