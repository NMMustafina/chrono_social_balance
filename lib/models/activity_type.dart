import 'package:hive/hive.dart';

part 'activity_type.g.dart';

@HiveType(typeId: 3)
enum ActivityType {
  @HiveField(0)
  solo,

  @HiveField(1)
  group,
}
