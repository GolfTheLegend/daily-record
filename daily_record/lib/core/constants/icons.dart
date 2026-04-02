import 'package:flutter/material.dart';

class IconItem {
  final IconData? icon;
  final String? iconPath; //ใช้สำหรับsvg
  final int keyId;

  const IconItem({this.icon, this.iconPath, required this.keyId});
}

const List<IconItem> iconsData = [
  // ===== ใช้ทุกวัน =====
  IconItem(icon: Icons.add, keyId: 0),
  IconItem(icon: Icons.access_time, keyId: 1),
  IconItem(icon: Icons.delete_rounded, keyId: 2),
  IconItem(icon: Icons.edit_document, keyId: 3),
  IconItem(icon: Icons.call, keyId: 4),
  IconItem(icon: Icons.email_outlined, keyId: 5),
  IconItem(icon: Icons.camera_alt_rounded, keyId: 6),
  IconItem(icon: Icons.calendar_month_outlined, keyId: 7),
  IconItem(icon: Icons.alarm_rounded, keyId: 8),
  IconItem(icon: Icons.account_balance_wallet_rounded, keyId: 9),
  IconItem(icon: Icons.account_box_rounded, keyId: 10),

  // ===== การเงิน / งาน =====
  IconItem(icon: Icons.account_balance, keyId: 11),
  IconItem(icon: Icons.balance_rounded, keyId: 12),
  IconItem(icon: Icons.analytics_rounded, keyId: 13),
  IconItem(icon: Icons.bar_chart_rounded, keyId: 14),
  IconItem(icon: Icons.assignment_outlined, keyId: 15),
  IconItem(icon: Icons.assignment_turned_in_outlined, keyId: 16),
  IconItem(icon: Icons.badge_rounded, keyId: 17),
  IconItem(icon: Icons.business_center_rounded, keyId: 18),
  IconItem(icon: Icons.apartment_rounded, keyId: 19),
  IconItem(icon: Icons.desktop_windows_rounded, keyId: 20),

  // ===== สุขภาพ / ไลฟ์สไตล์ =====
  IconItem(icon: Icons.directions_run_rounded, keyId: 21),
  IconItem(icon: Icons.fitness_center_rounded, keyId: 22),
  IconItem(icon: Icons.fastfood_rounded, keyId: 23),
  IconItem(icon: Icons.free_breakfast_rounded, keyId: 24),
  IconItem(icon: Icons.bed_rounded, keyId: 25),
  IconItem(icon: Icons.bedtime, keyId: 26),
  IconItem(icon: Icons.cake_rounded, keyId: 27),
  IconItem(icon: Icons.bakery_dining_rounded, keyId: 28),

  // ===== การเดินทาง =====
  IconItem(icon: Icons.directions_car_filled_rounded, keyId: 29),
  IconItem(icon: Icons.directions_bus_filled_sharp, keyId: 30),
  IconItem(icon: Icons.directions_bike_rounded, keyId: 31),
  IconItem(icon: Icons.airplane_ticket_rounded, keyId: 32),
  IconItem(icon: Icons.airplanemode_active_rounded, keyId: 33),
  IconItem(icon: Icons.airport_shuttle_rounded, keyId: 34),
  IconItem(icon: Icons.commute_rounded, keyId: 35),
  IconItem(icon: Icons.delivery_dining_rounded, keyId: 36),

  // ===== บ้าน / ของใช้ =====
  IconItem(icon: Icons.chair_rounded, keyId: 37),
  IconItem(icon: Icons.blender_rounded, keyId: 38),
  IconItem(icon: Icons.bathtub_outlined, keyId: 39),
  IconItem(icon: Icons.deck_rounded, keyId: 40),
  IconItem(icon: Icons.anchor_rounded, keyId: 41),

  // ===== เอกสาร / อ่านหนังสือ =====
  IconItem(icon: Icons.auto_stories_outlined, keyId: 42),
  IconItem(icon: Icons.chrome_reader_mode_rounded, keyId: 43),
  IconItem(icon: Icons.drafts_rounded, keyId: 44),
  IconItem(icon: Icons.attach_email_outlined, keyId: 45),

  // ===== อื่น ๆ =====
  IconItem(icon: Icons.build_rounded, keyId: 46),
  IconItem(icon: Icons.content_cut_rounded, keyId: 47),
  IconItem(icon: Icons.beach_access_rounded, keyId: 48),
  IconItem(icon: Icons.brightness_low_rounded, keyId: 49),
  IconItem(icon: Icons.aod_rounded, keyId: 50),
];
