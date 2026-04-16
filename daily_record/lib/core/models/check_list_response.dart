class CheckListResponse {
  final int id;
  final int mainRecordId;
  final DateTime dayCheck;
  final bool checkStatus;
  final DateTime createdAt;

  CheckListResponse({
    required this.id,
    required this.mainRecordId,
    required this.dayCheck,
    required this.checkStatus,
    required this.createdAt,
  });

  factory CheckListResponse.fromMap(Map<String, dynamic> map) {
    return CheckListResponse(
      id: map['id'] ?? 0,
      mainRecordId: map['main_record_id'] ?? 0,
      dayCheck: DateTime.parse(map['day_check']),
      checkStatus: map['check_status'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}