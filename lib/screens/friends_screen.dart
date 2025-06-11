import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

import '../models/friend_model.dart';
import 'add_friend_screen.dart';
import 'friends_details_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<FriendModel> allFriends = [];
  List<FriendModel> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    final box = GetIt.I.get<Box<FriendModel>>();
    allFriends = box.values.toList();
    filteredFriends = allFriends;
    _searchController.addListener(_onSearchChanged);
    box.listenable().addListener(_updateFriends);
  }

  void _updateFriends() {
    final box = GetIt.I.get<Box<FriendModel>>();
    allFriends = box.values.toList();
    _onSearchChanged();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredFriends = allFriends
          .where(
              (friend) => friend.namee?.toLowerCase().contains(query) ?? false)
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : null,
        centerTitle: true,
        title: isSearching
            ? Container(
                margin: EdgeInsets.only(right: 20.w),
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/magnifer.svg',
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: TextStyle(fontSize: 16.sp),
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 16.sp,
                              ),
                              contentPadding: EdgeInsets.only(right: 30.w),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                FocusScope.of(context).requestFocus(
                                    FocusNode()); // сбросить фокус, если надо
                                setState(() {});
                              },
                              child: Icon(
                                Icons.clear,
                                size: 20.sp,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                'Friends',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 28.sp,
                ),
              ),
        actions: [
          if (!isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
              icon: SvgPicture.asset('assets/icons/search.svg'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            filteredFriends.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    height: 140.h,
                    width: double.infinity,
                    margin: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E3E3),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Text(
                      'Nothing was found :(',
                      style: TextStyle(
                        color: Color(0xFF5C5C5C),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(24.w),
                      itemCount: filteredFriends.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 14.h,
                        crossAxisSpacing: 16.w,
                        childAspectRatio: 100 / 104,
                      ),
                      itemBuilder: (context, index) {
                        final friend = filteredFriends[index];
                        final hasPhoto = friend.photo != null &&
                            friend.photo!.isNotEmpty &&
                            File(friend.photo!).existsSync();

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FriendDetailScreen(
                                  friendModel: friend,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 36.r,
                                    backgroundImage: hasPhoto
                                        ? FileImage(File(friend.photo!))
                                        : const AssetImage(
                                                'assets/images/no_photo.png')
                                            as ImageProvider,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  if (friend.phoneNum != null)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: SvgPicture.asset(
                                          'assets/icons/call.svg'),
                                    ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                friend.namee ?? 'No name',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFriendScreen(),
            ),
          );
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 56.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: const Color(0xFF1284EF),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add friend',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              SvgPicture.asset('assets/icons/add.svg'),
            ],
          ),
        ),
      ),
    );
  }
}
