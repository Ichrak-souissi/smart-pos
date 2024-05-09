import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentTime;

  const CustomAppBar({Key? key, required this.currentTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.green.shade400, // Change the color here
        title: const Text(
          'Pos restaurant',
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Roboto'), // Modern typography and color
        ),
        actions: [
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    currentTime,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
