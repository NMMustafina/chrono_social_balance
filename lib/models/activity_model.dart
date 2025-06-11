import 'package:hive/hive.dart';

import 'activity_type.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 1)
class ActivityModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String iconAsset;

  @HiveField(2)
  final ActivityType type;

  @HiveField(3)
  final bool isCustom;

  ActivityModel({
    required this.name,
    required this.iconAsset,
    required this.type,
    this.isCustom = false,
  });
}
