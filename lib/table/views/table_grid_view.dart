import 'package:flutter/material.dart';

class TableGridView extends StatelessWidget {
  const TableGridView({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> items = List.generate(30, (index) => 'Item ${index + 1}');

    return Container(
  margin:  const  EdgeInsets.all(20),
      child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              width: 50,
              height: 50,
              padding:  const EdgeInsets.all(20),
              child: Center(
                child:  Text(items[index])
              ),
             );
          }
      ),
    )
    ;
  }
}




