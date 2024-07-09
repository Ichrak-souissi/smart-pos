import 'package:flutter/material.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/supplement/controllers/supplement_controller.dart';
import 'package:pos/supplement/models/supplement.dart';

class ItemDetailDialog extends StatelessWidget {
  final Item item;

  const ItemDetailDialog({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    List<Supplement> supplements = [];

    return Dialog(
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
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
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                // image: DecorationImage(
                                //   image: NetworkImage(item.imageUrl),
                                //  fit: BoxFit.cover,
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

                                  return Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: supplements
                                        .map((supplement) => CheckboxListTile(
                                              title: Row(
                                                children: [
                                                  Text(
                                                    supplement.name,
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  Text(
                                                    ' + ${supplement.price.toStringAsFixed(2)} dt',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.blue),
                                                  ),
                                                ],
                                              ),
                                              value: false,
                                              onChanged: (newValue) {},
                                            ))
                                        .toList(),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Fermer',
                        style: TextStyle(color: Colors.redAccent),
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
  }
}
