import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/controllers/item_controller.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/ingredient/models/ingredient.dart';
import 'package:pos/supplement/controller/supplement_controller.dart';
import 'package:pos/supplement/models/supplement.dart';

class ItemView {
  void show(BuildContext context, Item item, int quantity, Function(Item, int, List<Ingredient>, List<Supplement>, double) onItemSelected) {
    RxInt selectedQuantity = quantity.obs;
    List<int> selectedIngredientIds = [];
    List<int> selectedSupplementIds = [];
    List<Ingredient> ingredients = [];
    List<Supplement> supplements = [];
    double totalItemPrice = item.discount != null ? item.price * (1 - item.discount! / 100) : item.price.toDouble();

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
                    width: 600,
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
                              const Divider(color: Colors.black),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Ingrédients:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Choisissez les ingrédients',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    FutureBuilder<List<Ingredient>>(
                                      future: ItemController().getIngredientsByItemId(item.id),
                                      builder: (BuildContext context, AsyncSnapshot<List<Ingredient>> snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return const Text('Une erreur');
                                        } else {
                                          ingredients = snapshot.data ?? [];
                                          return Column(
                                            children: ingredients.map((ingredient) {
                                              return CheckboxListTile(
                                                title: Text(
                                                  ingredient.name,
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                value: selectedIngredientIds.contains(ingredient.id),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    if (newValue == true) {
                                                      selectedIngredientIds.add(ingredient.id);
                                                    } else {
                                                      selectedIngredientIds.remove(ingredient.id);
                                                    }
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
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
                                    FutureBuilder<List<Supplement>>(
                                      future: SupplementController().getSuppelmentsByItemId(item.id),
                                      builder: (BuildContext context, AsyncSnapshot<List<Supplement>> snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return const Text('Une erreur');
                                        } else {
                                          supplements = snapshot.data ?? [];
                                          return Column(
                                            children: supplements.map((supplement) {
                                              return CheckboxListTile(
                                                title: Row(
                                                  children: [
                                                    Text(
                                                      supplement.name,
                                                      style: const TextStyle(fontSize: 16),
                                                    ),
                                                    Text(
                                                      ' (+${supplement.price.toStringAsFixed(2)}dt)',
                                                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                                                    ),
                                                  ],
                                                ),
                                                value: selectedSupplementIds.contains(supplement.id),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    if (newValue == true) {
                                                      selectedSupplementIds.add(supplement.id);
                                                      totalItemPrice += supplement.price;
                                                    } else {
                                                      selectedSupplementIds.remove(supplement.id);
                                                      totalItemPrice -= supplement.price;
                                                    }
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.black),
                                onPressed: () {
                                  if (selectedQuantity.value > 1) {
                                    selectedQuantity.value--;
                                  }
                                },
                              ),
                              Obx(() => Text(
                                selectedQuantity.value.toString(),
                                style: const TextStyle(fontSize: 16),
                              )),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.black),
                                onPressed: () {
                                  selectedQuantity.value++;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                List<Ingredient> selectedIngredients = [];
                                for (var id in selectedIngredientIds) {
                                  Ingredient selectedIngredient = ingredients.firstWhere((ingredient) => ingredient.id == id);
                                  selectedIngredients.add(selectedIngredient);
                                }

                                List<Supplement> selectedSupplements = [];
                                for (var id in selectedSupplementIds) {
                                  Supplement selectedSupplement = supplements.firstWhere((supplement) => supplement.id == id);
                                  selectedSupplements.add(selectedSupplement);
                                }
                                onItemSelected(item, selectedQuantity.value, selectedIngredients, selectedSupplements, totalItemPrice);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Commander pour ${totalItemPrice.toStringAsFixed(2) * quantity} dt ',
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ),
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
