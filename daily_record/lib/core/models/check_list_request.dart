class CheckListRequest {
  final bool checkStatus;
  final String dayCheck;

  CheckListRequest({required this.checkStatus, required this.dayCheck});

  Map<String, dynamic> toMap() {
    return {'check_status': checkStatus, 'day_check': dayCheck};
  }
}
