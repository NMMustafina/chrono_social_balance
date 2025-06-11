import 'package:hive/hive.dart';

part 'friend_model.g.dart';

@HiveType(typeId: 0)
class FriendModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? photo;

  @HiveField(2)
  final String namee;

  @HiveField(3)
  final String? phoneNum;

  @HiveField(4)
  final String? maill;

  FriendModel({
    required this.id,
     this.photo,
    required this.namee,
     this.phoneNum,
     this.maill,
  });
}
