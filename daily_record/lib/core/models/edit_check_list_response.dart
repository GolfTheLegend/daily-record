class EditCheckListResponse {
  final int id;
  final bool checkStatus;

  EditCheckListResponse({
    required this.id,
    required this.checkStatus,
  });

  factory EditCheckListResponse.fromMap(Map<String, dynamic> map) {
    return EditCheckListResponse(
      id: map['id'] ?? 0,
      checkStatus: map['check_status'] ?? false,
    );
  }
}