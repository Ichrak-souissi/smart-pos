import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TableGridView extends StatefulWidget {
  const TableGridView({Key? key}) : super(key: key);

  @override
  State<TableGridView> createState() => _TableGridViewState();
}

class _TableGridViewState extends State<TableGridView> {
  List<String> images = [
    'assets/images/cutlery.png',
    'assets/images/restaurant.png',
    'assets/images/image2.png',
    'assets/images/comptoir.png',
    'assets/images/comptoir.png',
    'assets/images/image3.png',
    'assets/images/logo.png',
    'assets/images/image4.png',
    'assets/images/restaurant.png',
    'assets/images/restaurant.png',
    'assets/images/image3.png',
    'assets/images/image3.png',
    'assets/images/image2.png',
    'assets/images/image2.png',
    'assets/images/image4.png',
    'assets/images/cutlery.png',
    'assets/images/restaurant.png',
    'assets/images/image4.png',
    'assets/images/image3.png',
    'assets/images/comptoir.png',
    'assets/images/comptoir.png',
    'assets/images/comptoir.png',
    'assets/images/comptoir.png',
    'assets/images/comptoir.png',
    'assets/images/image4.png',
    'assets/images/image4.png',
    'assets/images/image4.png',
    'assets/images/logo.png',
    'assets/images/logo.png',
    'assets/images/logo.png',
    'assets/images/image2.png',
    'assets/images/image2.png',
    'assets/images/image2.png',
    'assets/images/image2.png',
  ];

  bool showShimmer = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      showShimmer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GridView.builder(
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          return showShimmer ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
            ),
          ) : Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              images[index],
            ),
          );
        },
      ),
    );
  }
}
