class EditCheckListRequest {
  final bool checkStatus;

  EditCheckListRequest({required this.checkStatus});

  Map<String, dynamic> toMap() {
    return {'check_status': checkStatus};
  }
}
