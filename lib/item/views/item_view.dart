import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/models/item.dart';

class ItemView {
  void show(BuildContext context, Item item, int quantity, Function(Item, int, double) onItemSelected) {
    double totalItemPrice = item.discount != null ? item.price * (1 - item.discount! / 100) : item.price.toDouble();
    var selectedQuantity = quantity.obs;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Stack(
                children: [
                  SizedBox(
                    width: 400,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.primaryColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Détails du plat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            // image: DecorationImage(
                                            //  image: NetworkImage(item.imageUrl),
                                            // fit: BoxFit.cover,
                                          ),
                                          //  ),
                                        ),
                                        if (item.discount != null)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.yellowAccent,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '-${item.discount}%',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Description:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        item.description,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 25,
                                width: 25,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.white, size: 10),
                                    onPressed: () {
                                      if (selectedQuantity.value > 1) {
                                        selectedQuantity.value--;
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Obx(() => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  selectedQuantity.value.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )),
                              Container(
                                height: 25,
                                width: 25,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(Icons.add, color: Colors.white, size: 10),
                                    onPressed: () {
                                      selectedQuantity.value++;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                        foregroundColor: Color.fromARGB(255, 221, 136, 9),
                              backgroundColor: Color.fromARGB(255, 221, 136, 9),
                              ),
                              onPressed: () {
                                onItemSelected(item, selectedQuantity.value, totalItemPrice);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Commander  ',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                           const SizedBox(height: 15),

                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
