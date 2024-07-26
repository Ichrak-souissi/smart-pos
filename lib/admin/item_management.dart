import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/category/controllers/category_controller.dart';
import 'package:pos/category/models/category.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/item/views/item_detail.dart';
import 'package:pos/room/widgets/appbar_widget.dart';
import 'package:pos/table/controllers/table_controller.dart';

class ItemManagement extends StatefulWidget {
  @override
  _ItemManagementState createState() => _ItemManagementState();
}

class _ItemManagementState extends State<ItemManagement> {
  final CategoryController categoryController = Get.put(CategoryController());
  final TableController tableController = Get.put(TableController());
  Map<Item, int> orderMap = {};
  int selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCategoryItems();
  }

  void _loadCategoryItems() async {
    await categoryController.getCategoryList();
    if (categoryController.categoryList.isNotEmpty) {
      await categoryController
          .getItemsByCategoryId(categoryController.categoryList[0].id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 255, 245),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBarWidget(),
                  SizedBox(height: 10),
                  _buildCategoryBoxes(),
                  Expanded(
                    child: _buildCategoryViews(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCategoryChanged(int index) async {
    await categoryController.getItemsByCategoryId(
      categoryController.categoryList[index].id,
    );
    setState(() {});
  }

  void _showDeleteCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer la catégorie'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer la catégorie ${category.name} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await categoryController.deleteCategory(category);
                Navigator.of(context).pop();

                Get.snackbar(
                  'Succès',
                  'La catégorie ${category.name} a été supprimée avec succès.',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: Duration(seconds: 3),
                );
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryBoxes() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() {
              return Row(
                children: [
                  ...categoryController.categoryList
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key;
                    Category category = entry.value;
                    bool isSelected = index == selectedCategoryIndex;

                    return GestureDetector(
                      onTap: () {
                        selectedCategoryIndex = index;
                        _onCategoryChanged(index);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : Colors.white,
                          border: Border.all(
                            color: AppTheme.lightTheme.primaryColor,
                            width: isSelected ? 0 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isSelected)
                              GestureDetector(
                                onTap: () =>
                                    _showDeleteCategoryDialog(category),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  GestureDetector(
                    onTap: _showAddCategoryDialog,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      padding: const EdgeInsets.all(7.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: AppTheme.lightTheme.primaryColor, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryViews() {
    return Obx(() {
      if (categoryController.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return _buildItemsGridView(
            categoryController.categoryList[selectedCategoryIndex]);
      }
    });
  }

  bool isNewItem(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    return difference < 7;
  }

  int _calculateCrossAxisCount(double width) {
    int crossAxisCount = (width / 180).floor();
    return crossAxisCount > 0 ? crossAxisCount : 1;
  }

  Widget _buildItemsGridView(Category category) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
          return Obx(() {
            var items = categoryController.categoryItems;

            return GridView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
                childAspectRatio: 0.8,
              ),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index < items.length) {
                  final item = items[index];
                  final isNew = isNewItem(item.createdAt as DateTime);

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final updatedItem = await showDialog<Item>(
                            context: context,
                            builder: (BuildContext context) =>
                                ItemDetailDialog(item: item),
                          );

                          if (updatedItem != null) {
                            int index = categoryController.categoryItems
                                .indexWhere((i) => i.id == updatedItem.id);
                            if (index != -1) {
                              setState(() {
                                categoryController.categoryItems[index] =
                                    updatedItem;
                              });
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: CachedNetworkImage(
                                        imageUrl: item.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) {
                                          print('Erreur de chargement: $error');
                                          return Container();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 5),
                                    child: Icon(
                                      Icons.whatshot_sharp,
                                      color: Colors.orange,
                                      size: 15,
                                    ),
                                  ),
                                  Text(
                                    '${item.calories.toString()} calories',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: item.discount != null &&
                                            item.discount != 0
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${item.price.toStringAsFixed(2)} dt',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              Text(
                                                '${(item.price - (item.price * (item.discount?.toDouble() ?? 0) / 100)).toStringAsFixed(2)} dt',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            '${item.price.toStringAsFixed(2)} dt',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              ItemDetailDialog(item: item),
                                        ).then((_) {
                                          setState(() {
                                            categoryController.categoryItems;
                                          });
                                        });
                                      },
                                      child: Text(
                                        'Modifier',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isNew)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Nouveau',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      if (item.discount != null && item.discount != 0)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            width: 33,
                            height: 33,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.yellowAccent,
                            ),
                            child: Center(
                              child: Text(
                                '-${item.discount.toString()}%',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return GestureDetector(
                    onTap: _showAddItemDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        color: Colors.grey.shade100,
                      ),
                      child: Icon(Icons.add,
                          size: 50, color: AppTheme.lightTheme.primaryColor),
                    ),
                  );
                }
              },
            );
          });
        },
      ),
    );
  }

  Future<void> _showAddItemDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final TextEditingController discountController = TextEditingController();
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un plat'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ' entrer le nom du plat';
                    }
                    return null;
                  },
                ),
                TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'entrer la description du plat';
                      }
                      return null;
                    }),
                TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Prix'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'entrer le prix du plat';
                      }
                      return null;
                    }),
                TextFormField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Calories'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'entrer les calories';
                      }
                      return null;
                    }),
                TextFormField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Discount (%)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Entrer la valeur de promotion';
                      }
                      return null;
                    }),
                TextFormField(
                    controller: imageUrlController,
                    decoration:
                        const InputDecoration(labelText: 'URL de l\'image'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Entrer l\'URL de l\'image du plat';
                      }
                      return null;
                    }),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  int? discount = discountController.text.isNotEmpty
                      ? int.parse(discountController.text)
                      : null;

                  final newItem = Item(
                    id: 0,
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.parse(priceController.text),
                    imageUrl: imageUrlController.text,
                    calories: int.parse(caloriesController.text),
                    isActive: true,
                    categoryId: categoryController
                        .categoryList[selectedCategoryIndex].id,
                    createdAt: DateTime.now(),
                    discount: discount,
                  );

                  categoryController.addNewItem(newItem);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Ajouter',
                style: TextStyle(color: AppTheme.lightTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ajouter une catégorie"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Nom de la catégorie"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'entrer le nom de la catégorie ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: imageUrlController,
                  decoration:
                      InputDecoration(labelText: "Image de la catégorie"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'entrer le nom de la catégorie ';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Annuler",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "Ajouter",
                style: TextStyle(color: AppTheme.lightTheme.primaryColor),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Category newCategory = Category(
                    id: 0,
                    name: nameController.text,
                    imageUrl: imageUrlController.text,
                    isActive: true,
                    items: [],
                  );
                  await categoryController.addNewCategory(newCategory);
                  Navigator.of(context).pop();

                  Get.snackbar(
                    'Succès',
                    'La catégorie ${newCategory.name} a été ajoutée avec succès.',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 3),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
