import 'dart:async';
import 'package:appwrite/models.dart';
import 'package:chatty/constant/app_color.dart';
import 'package:chatty/controllers/appwrite_controllers.dart';
import 'package:chatty/model/user_data.dart';
import 'package:chatty/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/avatar_widget.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({super.key});

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  final TextEditingController _searchController = TextEditingController();
  late DocumentList searchedUsers = DocumentList(total: -1, documents: []);
  Timer? _debounce;

  // handle the search
  void _handleSearch(String searchItem) {
    if (searchItem.isEmpty) {
      setState(() {
        searchedUsers = DocumentList(total: 0, documents: []);
      });
      return;
    }
    searchUsers(
            searchItem: _searchController.text,
            userId:
                Provider.of<UserDataProvider>(context, listen: false).getUserId)
        .then((value) {
      if (value != null) {
        setState(() {
          searchedUsers = value;
        });
      } else {
        setState(() {
          searchedUsers = DocumentList(total: 0, documents: []);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _handleSearch(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.white,
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left,
          color: AppColors.backgroundColor,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: const Text(
        "Search User",
        style: TextStyle(color: AppColors.darkGray),
      ),
    ),
    body: Column(
      children: [
        // Search bar with improved UI
        Container(
          margin: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Enter phone number",
              hintStyle: const TextStyle(fontWeight: FontWeight.normal),
              prefixIcon: const Icon(Icons.search, color: AppColors.darkGray),
              filled: true,
              fillColor: AppColors.lighterGray,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              // Trigger the search with debounce
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                _handleSearch(value);
              });
            },
          ),
        ),
        // Display search results
        Expanded(
          child: searchedUsers.total == -1
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/search.png', // Replace with your image path
                        width: 90, // Adjust the width as needed
                        height: 90, // Adjust the height as needed
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Use the search box to search users.",
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : searchedUsers.total == 0
                  ? const Center(
                      child: Text(
                        "No users found",
                        style: TextStyle(color: AppColors.darkGray),
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchedUsers.documents.length,
                      itemBuilder: (context, index) {
                        debugPrint(
                            " Name ${searchedUsers.documents[index].data["name"].toString()}");
                        return searchedUsers.documents[index]
                                        .data["name"]
                                        .toString()
                                        .isEmpty ||
                                    searchedUsers.documents[index]
                                            .data["name"]
                                            .toString() ==
                                        'null'
                                ? const SizedBox()
                                : ListTile(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        "/chat",
                                        arguments: UserData.toMap(
                                          searchedUsers.documents[index].data,
                                        ),
                                      );
                                    },
                                    leading: searchedUsers
                                                    .documents[index]
                                                    .data["profile_pic"] !=
                                                null &&
                                            searchedUsers
                                                    .documents[index]
                                                    .data["profile_pic"] !=
                                                ""
                                        ? AvatarWidget(
                                            url: searchedUsers.documents[index]
                                                .data["profile_pic"],
                                            widthHeight: 40,
                                          )
                                        : const CircleAvatar(
                                            backgroundImage: AssetImage(
                                              "assets/images/user.png",
                                            ),
                                          ),
                                    title: Text(
                                      searchedUsers.documents[index]
                                              .data["name"] ??
                                          "No name",
                                    ),
                                    subtitle: Text(
                                      searchedUsers.documents[index]
                                          .data["phone_no"],
                                    ),
                                  );
                      },
                    ),
        ),
      ],
    ),
  );
}
}


