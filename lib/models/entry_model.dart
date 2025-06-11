import 'package:hive/hive.dart';

import 'activity_model.dart';

part 'entry_model.g.dart';

@HiveType(typeId: 2)
class EntryModel {
  @HiveField(0)
  final DateTime start;

  @HiveField(1)
  final DateTime end;

  @HiveField(2)
  final ActivityModel activity;

  @HiveField(3)
  final List<String> friendIds;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final String? photoPath;

  @HiveField(6)
  final DateTime date;

  EntryModel({
    required this.start,
    required this.end,
    required this.activity,
    this.friendIds = const [],
    this.description,
    this.photoPath,
    required this.date,
  });
}
