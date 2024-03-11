
import 'package:flutter/material.dart';

class LeftDrawerListTile extends StatelessWidget {
  Icon icon  ;


  LeftDrawerListTile( this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(12),

      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {},
              icon: icon
          ),

        ],
      ),
    ) ;
  }
}