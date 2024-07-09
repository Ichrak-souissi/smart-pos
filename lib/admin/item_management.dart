import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/category/controllers/category_controller.dart';
import 'package:pos/category/models/category.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/item/views/item_detail.dart';
import 'package:pos/item/views/item_view.dart';
import 'package:pos/room/widgets/appbar_widget.dart';
import 'package:pos/supplement/models/supplement.dart';
import 'package:pos/table/controllers/table_controller.dart';

class ItemManagement extends StatefulWidget {
  @override
  _ItemManagementState createState() => _ItemManagementState();
}

class _ItemManagementState extends State<ItemManagement> {
  final CategoryController categoryController = Get.put(CategoryController());
  final TableController tableController = Get.put(TableController());
  final TextEditingController _searchController = TextEditingController();
  Map<Item, int> orderMap = {};

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
    return DefaultTabController(
      length: categoryController.categoryList.length,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
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
                    _buildActionButtons(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TabBar(
                        isScrollable: true,
                        indicatorColor: Colors.redAccent,
                        labelColor: Colors.redAccent,
                        tabs: _buildCategoryTabs(),
                        onTap: _onTabChanged,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: _buildCategoryViews(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Spacer(),
          _buildElevatedButton(
            "Ajouter un plat",
            _showAddItemDialog,
          ),
          const SizedBox(width: 10),
          _buildElevatedButton(
            "Ajouter une catégorie",
            () {},
          ),
        ],
      ),
    );
  }

  ElevatedButton _buildElevatedButton(String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 13),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 150, 133, 224),
      ),
    );
  }

  List<Tab> _buildCategoryTabs() {
    return categoryController.categoryList.map((category) {
      return Tab(
        text: category.name,
      );
    }).toList();
  }

  void _onTabChanged(int index) async {
    await categoryController.getItemsByCategoryId(
      categoryController.categoryList[index].id,
    );
    setState(() {});
  }

  List<Widget> _buildCategoryViews() {
    return categoryController.categoryList.map((category) {
      return Obx(() {
        if (categoryController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return _buildItemsGridView(category);
        }
      });
    }).toList();
  }

  Widget _buildItemsGridView(Category category) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
          return Obx(() {
            if (categoryController.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return GridView.builder(
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 20.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: categoryController.categoryItems.length,
                itemBuilder: (context, index) {
                  final item = categoryController.categoryItems[index];
                  final isNew = isNewItem(item.createdAt);
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => ItemDetailDialog(
                              item: item,
                            ),
                          );
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
                                    width: double.minPositive,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      // image: DecorationImage(
                                      //   image: NetworkImage(item.imageUrl),
                                      //   fit: BoxFit.cover,
                                      // ),
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
                                    child: Text(
                                      '${item.price.toStringAsFixed(2)} dt',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.lightTheme.primaryColor,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
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
                              'New',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      if (item.discount != null)
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
                },
              );
            }
          });
        },
      ),
    );
  }

  bool isNewItem(DateTime createdAt) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return createdAt.isAfter(weekAgo);
  }

  int _calculateCrossAxisCount(double width) {
    int crossAxisCount = (width / 180).floor();
    return crossAxisCount > 0 ? crossAxisCount : 1;
  }

  void _showAddItemDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();
    TextEditingController caloriesController = TextEditingController();
    TextEditingController discountController = TextEditingController();
    TextEditingController supplementNameController = TextEditingController();
    TextEditingController supplementPriceController = TextEditingController();

    Category? selectedCategory = categoryController.categoryList.isNotEmpty
        ? categoryController.categoryList[0]
        : null;

    List<Supplement> selectedSupplements = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Ajouter un plat"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Nom du plat"),
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: "Description"),
                    ),
                    TextFormField(
                      controller: priceController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Prix"),
                    ),
                    TextFormField(
                      controller: imageUrlController,
                      decoration: InputDecoration(labelText: "URL de l'image"),
                    ),
                    TextFormField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Calories"),
                    ),
                    TextFormField(
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Réduction (%)"),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Suppléments:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Ajoutez les suppléments à ajouter à ce plat',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: supplementNameController,
                            decoration:
                                InputDecoration(labelText: "Nom du supplément"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: supplementPriceController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                                labelText: "Prix du supplément"),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              String name =
                                  supplementNameController.text.trim();
                              double price = double.tryParse(
                                      supplementPriceController.text.trim()) ??
                                  0.0;
                              if (name.isNotEmpty && price > 0) {
                                selectedSupplements.add(Supplement(
                                  id: 0,
                                  name: name,
                                  price: price,
                                  itemId: 0,
                                ));
                                supplementNameController.clear();
                                supplementPriceController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: selectedSupplements.map((supplement) {
                        return Chip(
                          label: Text(
                              "${supplement.name} (+${supplement.price.toStringAsFixed(2)} dt)"),
                          onDeleted: () {
                            setState(() {
                              selectedSupplements.remove(supplement);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Category>(
                      value: selectedCategory,
                      hint: Text('Sélectionnez une catégorie'),
                      onChanged: (Category? value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                      items: categoryController.categoryList
                          .map((Category category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Annuler"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Ajouter"),
                  onPressed: () {
                    int? discount;
                    if (discountController.text.isNotEmpty) {
                      discount = int.tryParse(discountController.text);
                    }

                    print('Selected category: ${selectedCategory!.id}');

                    Item newItem = Item(
                      id: 0,
                      name: nameController.text,
                      description: descriptionController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      imageUrl: imageUrlController.text,
                      calories: int.tryParse(caloriesController.text) ?? 0,
                      isActive: true,
                      categoryId: selectedCategory!.id,
                      createdAt: DateTime.now(),
                      supplements: selectedSupplements,
                      discount: discount,
                    );

                    print('New item: ${newItem.toJson()}');

                    categoryController.addNewItem(newItem);

                    Navigator.of(context).pop();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Succès'),
                          content: Text(
                              'Le plat ${newItem.name} a été ajouté avec succès.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
