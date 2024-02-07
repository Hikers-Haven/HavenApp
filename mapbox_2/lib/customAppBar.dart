import 'package:flutter/material.dart';

class customAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.lightGreen[300],
      elevation: 4,
      title: Text('Fox Valley Cyclists'),
      // Add other AppBar properties if needed
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}