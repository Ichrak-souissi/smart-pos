
import 'package:flutter/material.dart';

class LeftDrawerListTile extends StatelessWidget {
  String  title ;
  Icon icon  ;


  LeftDrawerListTile(this.title, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        color: Colors.yellow.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {},
            icon: icon
          ),
            Text(
            title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ) ;
  }
}
