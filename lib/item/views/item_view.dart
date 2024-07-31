import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/supplement/controllers/supplement_controller.dart';
import 'package:pos/supplement/models/supplement.dart';

class ItemView {
  void show(BuildContext context, Item item, int quantity,
      Function(Item, int, List<Supplement>, double) onItemSelected) {
    RxInt selectedQuantity = quantity.obs;
    List<int> selectedSupplementIds = [];
    List<Supplement> supplements = [];
    double totalItemPrice = item.price.toDouble();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                ),
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
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    //  image: DecorationImage(
                                    //    image: NetworkImage(item.imageUrl),
                                    //    fit: BoxFit.cover,
                                    //  ),
                                  ),
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
                          const SizedBox(width: 10),
                          Flexible(
                            child: FutureBuilder<List<Supplement>>(
                              future: SupplementController()
                                  .getSupplementsByItemId(item.id),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Supplement>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  print(
                                      'Erreur lors du chargement des suppléments: ${snapshot.error}');
                                  return const Text(
                                      'Une erreur est survenue lors du chargement des suppléments.');
                                } else {
                                  supplements = snapshot.data ?? [];
                                  print('Liste des suppléments: $supplements');

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (supplements.isNotEmpty) ...[
                                        const Text(
                                          'Suppléments:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        const Text(
                                          'Choisissez les suppléments',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children:
                                              supplements.map((supplement) {
                                            return CheckboxListTile(
                                              title: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      supplement.name,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Text(
                                                    ' + ${supplement.price.toStringAsFixed(2)} dt',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.blue),
                                                  ),
                                                ],
                                              ),
                                              value: selectedSupplementIds
                                                  .contains(supplement.id),
                                              onChanged: (newValue) {
                                                setState(() {
                                                  if (newValue == true) {
                                                    selectedSupplementIds
                                                        .add(supplement.id);
                                                    totalItemPrice += supplement
                                                        .price
                                                        .toDouble();
                                                  } else {
                                                    selectedSupplementIds
                                                        .remove(supplement.id);
                                                    totalItemPrice -= supplement
                                                        .price
                                                        .toDouble();
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ] else
                                        ...[],
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 15,
                              ),
                              onPressed: () {
                                if (selectedQuantity.value > 1) {
                                  selectedQuantity.value--;
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(() => Text(
                                selectedQuantity.value.toString(),
                                style: const TextStyle(fontSize: 16),
                              )),
                          const SizedBox(width: 10),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 15,
                              ),
                              onPressed: () {
                                selectedQuantity.value++;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Annuler',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              List<Supplement> selectedSupplements = [];
                              for (var id in selectedSupplementIds) {
                                Supplement selectedSupplement =
                                    supplements.firstWhere(
                                        (supplement) => supplement.id == id);
                                selectedSupplements.add(selectedSupplement);
                              }
                              print(
                                  'Suppléments sélectionnés: $selectedSupplements');

                              onItemSelected(item, selectedQuantity.value,
                                  selectedSupplements, totalItemPrice);
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Commander',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
