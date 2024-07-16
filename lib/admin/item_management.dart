import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/category/controllers/category_controller.dart';
import 'package:pos/category/models/category.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/item/views/item_detail.dart';
import 'package:pos/room/widgets/appbar_widget.dart';
import 'package:pos/table/controllers/table_controller.dart';

class ItemManagement extends StatefulWidget {
  const ItemManagement({super.key});

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
                  SizedBox(
                    height: 10,
                  ),
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

  int _calculateCrossAxisCount(double width) {
    int crossAxisCount = (width / 180).floor();
    return crossAxisCount > 0 ? crossAxisCount : 1;
  }

  Widget _buildCategoryBoxes() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...categoryController.categoryList.asMap().entries.map((entry) {
                  int index = entry.key;
                  Category category = entry.value;
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryIndex = index;
                            _onCategoryChanged(index);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedCategoryIndex == index
                                  ? Colors.redAccent
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category.name,
                                style: TextStyle(
                                  color: selectedCategoryIndex == index
                                      ? Colors.black
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _showDeleteCategoryDialog(category),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.redAccent,
                                  size: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                GestureDetector(
                  onTap: _showAddCategoryDialog,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onCategoryChanged(int index) async {
    await categoryController.getItemsByCategoryId(
      categoryController.categoryList[index].id,
    );
    setState(() {});
  }

  Widget _buildCategoryViews() {
    if (categoryController.isLoading.value) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return _buildItemsGridView(
          categoryController.categoryList[selectedCategoryIndex]);
    }
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
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
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
                itemCount: categoryController.categoryItems.length + 1,
                itemBuilder: (context, index) {
                  if (index < categoryController.categoryItems.length) {
                    final item = categoryController.categoryItems[index];
                    final isNew = isNewItem(item.createdAt);
                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  ItemDetailDialog(item: item),
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
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      //  child: ClipRRect(
                                      //   borderRadius: BorderRadius.circular(2),
                                      //  child: CachedNetworkImage(
                                      //   imageUrl: item.imageUrl,
                                      //   fit: BoxFit.cover,
                                      //   placeholder: (context, url) => Center(
                                      //      child:
                                      //          CircularProgressIndicator()),
                                      //  errorWidget: (context, url, error) =>
                                      //    Icon(Icons.error),
                                      //  ),
                                      //  ),
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
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                ItemDetailDialog(item: item),
                                          );
                                        },
                                        child: Text(
                                          'Modifier',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
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
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'New',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        _showAddItemDialog(category);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            }
          });
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une catégorie'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Nom de la catégorie',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                String categoryName = nameController.text;
                if (categoryName.isNotEmpty) {
                  //    await categoryController.(categoryName);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddItemDialog(Category category) async {}

  bool isNewItem(DateTime createdAt) {
    Duration difference = DateTime.now().difference(createdAt);
    return difference.inDays <= 7;
  }
}
