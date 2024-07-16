import 'package:flutter/material.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/supplement/controllers/supplement_controller.dart';
import 'package:pos/supplement/models/supplement.dart';
import 'package:get/get.dart';

class ItemDetailDialog extends StatelessWidget {
  final Item item;

  const ItemDetailDialog({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
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
                    Text(
                      'Détails du plat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        // Implémentez la logique pour éditer l'article ici
                        print('Editer l\'article');
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  //   decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(12),
                  //       image: DecorationImage(
                  //       image: CachedNetworkImageProvider(item.imageUrl),
                  //       fit: BoxFit.cover,
                  //    ),
                  //  ),
                  // Placeholder or loading indicator can be added here
                  // if image loading takes time
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  item.description ?? 'Aucune description disponible',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              Divider(height: 1, thickness: 1),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Suppléments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AddSupplementDialog(itemId: item.id),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        shape: CircleBorder(),
                      ),
                      child: Icon(Icons.add, size: 24),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Souhaitez-vous ajouter des suppléments ?',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 12),
              SupplementsListDialog(itemId: item.id),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class SupplementsListDialog extends StatelessWidget {
  final int itemId;

  const SupplementsListDialog({
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Supplement>>(
      future: SupplementController().getSupplementsByItemId(itemId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '',
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          final supplements = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: supplements.length,
            itemBuilder: (context, index) {
              final supplement = supplements[index];
              return SupplementListItem(supplement: supplement);
            },
          );
        }
      },
    );
  }
}

class SupplementListItem extends StatelessWidget {
  final Supplement supplement;

  const SupplementListItem({
    required this.supplement,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(supplement.name),
      subtitle: Text('Prix: ${supplement.price.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    EditSupplementDialog(supplement: supplement),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              //    SupplementController().deleteSupplement(supplement.id);
            },
          ),
        ],
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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter un supplément',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du supplément',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Prix du supplément',
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Annuler'),
                  ),
                  SizedBox(width: 16),
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

                        setState(() {
                          supplementController
                              .addSupplementToItem(newSupplement);

                          Get.find<SupplementController>()
                              .getSupplementsByItemId(widget.itemId);
                        });
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirmation'),
                            content:
                                Text('Supplément $name ajouté avec succès'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text('Ajouter'),
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

class EditSupplementDialog extends StatefulWidget {
  final Supplement supplement;

  const EditSupplementDialog({
    required this.supplement,
  });

  @override
  _EditSupplementDialogState createState() => _EditSupplementDialogState();
}

class _EditSupplementDialogState extends State<EditSupplementDialog> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  final SupplementController supplementController =
      Get.put(SupplementController());

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.supplement.name);
    priceController =
        TextEditingController(text: widget.supplement.price.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifier le supplément',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du supplément',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Prix du supplément',
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Annuler'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final String name = nameController.text.trim();
                      final double price =
                          double.tryParse(priceController.text.trim()) ?? 0.0;

                      if (name.isNotEmpty && price > 0) {
                        final updatedSupplement = Supplement(
                          id: widget.supplement.id,
                          name: name,
                          itemId: widget.supplement.itemId,
                          price: price,
                        );

                        //   supplementController
                        //      .updateSupplement(updatedSupplement);
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirmation'),
                            content:
                                Text('Supplément $name modifié avec succès'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text('Modifier'),
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
