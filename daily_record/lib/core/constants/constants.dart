class StatusItem {
  final String trailing;
  final int key;

  const StatusItem({required this.trailing, required this.key});
}

//สถานะ
final List<StatusItem> statusList = [
  const StatusItem(trailing: 'ทุกวัน', key: 0),
  const StatusItem(trailing: 'เลือกวัน', key: 1),
];
