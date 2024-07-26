import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/category/controllers/category_controller.dart';
import 'package:pos/item/controllers/item_controller.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/supplement/controllers/supplement_controller.dart';
import 'package:pos/supplement/models/supplement.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/controllers/item_controller.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/supplement/controllers/supplement_controller.dart';
import 'package:pos/supplement/models/supplement.dart';

class ItemDetailDialog extends StatefulWidget {
  Item item;

  ItemDetailDialog({
    super.key,
    required this.item,
  });

  @override
  _ItemDetailDialogState createState() => _ItemDetailDialogState();
}

class _ItemDetailDialogState extends State<ItemDetailDialog> {
  final ItemController itemController = Get.put(ItemController());
  final SupplementController supplementController =
      Get.put(SupplementController());
  final CategoryController categoryController = Get.put(CategoryController());

  @override
  void initState() {
    super.initState();
    supplementController.getSupplementsByItemId(widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Obx(() {
            final item = itemController.categoryItems.firstWhere(
              (item) => item.id == widget.item.id,
              orElse: () => widget.item,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Détails du plat',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => EditItemDialog(item: item),
                          ).then((updatedItem) {
                            if (updatedItem != null) {
                              setState(() {
                                widget.item = updatedItem;
                              });
                              itemController.updateItem(updatedItem).then((_) {
                                itemController.fetchItems();
                                supplementController
                                    .getSupplementsByItemId(updatedItem.id);

                                // Afficher le message de confirmation
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: Text(
                                        'Le plat ${updatedItem.name} a été mis à jour avec succès.'),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            item.imageUrl != null && item.imageUrl!.isNotEmpty
                                ? Image.network(
                                    item.imageUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Text(
                                        'Image',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                      ),
                      if (item.discount != null && item.discount! > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.yellow,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${item.discount}%',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.price} DT',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10, right: 5),
                            child: Icon(
                              Icons.whatshot_sharp,
                              color: Colors.orange,
                              size: 15,
                            ),
                          ),
                          Text(
                            '${item.calories} calories',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    item.description ?? 'Aucune description',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Suppléments',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AddSupplementDialog(itemId: item.id),
                          ).then((_) {
                            supplementController
                                .getSupplementsByItemId(item.id);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          shape: const CircleBorder(),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SupplementsListDialog(itemId: item.id),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          categoryController
                              .getItemsByCategoryId(widget.item.categoryId);
                        },
                        child: const Text(
                          'Confirmer',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class AddSupplementDialog extends StatefulWidget {
  final int itemId;

  const AddSupplementDialog({
    required this.itemId,
  });

  @override
  _AddSupplementDialogState createState() => _AddSupplementDialogState();
}

class _AddSupplementDialogState extends State<AddSupplementDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final SupplementController supplementController =
      Get.put(SupplementController());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajouter un supplément',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du supplément',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix du supplément',
                  hintText: '0.00',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final String name = nameController.text.trim();
                      final double price =
                          double.tryParse(priceController.text.trim()) ?? 0.0;

                      if (name.isNotEmpty && price > 0) {
                        final newSupplement = Supplement(
                          name: name,
                          itemId: widget.itemId,
                          id: 0,
                          price: price,
                        );
                        supplementController.addSupplementToItem(newSupplement);
                        setState(() {
                          Get.find<ItemController>().fetchItems();
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Ajouter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditItemDialog extends StatefulWidget {
  final Item item;

  const EditItemDialog({
    required this.item,
  });

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  late double originalPrice;
  double discountedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.item.name;
    priceController.text = widget.item.price.toString();
    originalPrice = widget.item.price;
    discountedPrice =
        originalPrice; // Initial discounted price is the same as the original
    caloriesController.text = widget.item.calories.toString();
    descriptionController.text = widget.item.description ?? '';
    imageUrlController.text = widget.item.imageUrl ?? '';
    discountController.text = widget.item.discount?.toString() ?? '';
  }

  void _updateDiscountedPrice() {
    final discount = int.tryParse(discountController.text.trim()) ?? 0;
    setState(() {
      discountedPrice = originalPrice * (1 - discount / 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ItemController itemController = Get.find<ItemController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modifier le plat',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du plat',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix du plat',
                  hintText: '0.00',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  final newPrice = double.tryParse(value.trim()) ?? 0.0;
                  setState(() {
                    originalPrice = newPrice;
                    _updateDiscountedPrice();
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: discountController,
                decoration: const InputDecoration(
                  labelText: 'Remise (%)',
                  hintText: 'Remise (facultatif)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _updateDiscountedPrice();
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'Prix après remise: ${discountedPrice.toStringAsFixed(2)} DT',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final updatedItem = widget.item.copyWith(
                        name: nameController.text.trim(),
                        price: originalPrice,
                        calories:
                            int.tryParse(caloriesController.text.trim()) ?? 0,
                        imageUrl: imageUrlController.text.trim().isNotEmpty
                            ? imageUrlController.text.trim()
                            : null,
                        discount: discountController.text.trim().isNotEmpty
                            ? int.tryParse(discountController.text.trim())
                            : null,
                        description: descriptionController.text.trim(),
                      );

                      await itemController.updateItem(updatedItem);
                      await itemController.fetchItems();

                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Enregistrer'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SupplementsListDialog extends StatelessWidget {
  final int itemId;

  const SupplementsListDialog({required this.itemId});

  @override
  Widget build(BuildContext context) {
    final SupplementController controller = Get.find<SupplementController>();

    return Obx(() {
      final supplements = controller.supplements
          .where((supplement) => supplement.itemId == itemId)
          .toList();

      if (supplements.isEmpty) {
        return const Center(
          child: Text('Aucun supplément disponible pour cet article.'),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: supplements
            .map((supplement) => ListTile(
                  title: Text(supplement.name),
                  subtitle: Text('${supplement.price} DT',
                      style: TextStyle(color: Colors.blue)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black54),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                EditSupplementDialog(supplement: supplement),
                          ).then((updatedSupplement) {
                            if (updatedSupplement != null) {
                              controller.updateSupplement(updatedSupplement);
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black54),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Supprimer le supplément'),
                              content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer ce supplément ?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    controller
                                        .deleteSupplement(supplement.id)
                                        .then((_) {
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ))
            .toList(),
      );
    });
  }
}

class EditSupplementDialog extends StatefulWidget {
  final Supplement supplement;

  const EditSupplementDialog({required this.supplement});

  @override
  _EditSupplementDialogState createState() => _EditSupplementDialogState();
}

class _EditSupplementDialogState extends State<EditSupplementDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final SupplementController supplementController =
      Get.find<SupplementController>();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.supplement.name;
    priceController.text = widget.supplement.price.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Modifier le supplément',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du supplément',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix du supplément',
                  hintText: '0.00',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final String name = nameController.text.trim();
                      final double price =
                          double.tryParse(priceController.text.trim()) ?? 0.0;

                      if (name.isNotEmpty && price > 0) {
                        final updatedSupplement = widget.supplement.copyWith(
                          name: name,
                          price: price,
                        );
                        supplementController
                            .updateSupplement(updatedSupplement)
                            .then((_) {
                          supplementController
                              .getSupplementsByItemId(widget.supplement.itemId);
                          Navigator.of(context).pop();
                        });
                      }
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
