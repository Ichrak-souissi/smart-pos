import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/category/controllers/category_controller.dart';
import 'package:pos/category/views/payement_page.dart';
import 'package:pos/ingredient/models/ingredient.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/item/views/item_view.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({Key? key}) : super(key: key);

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  final CategoryController categoryController = Get.put(CategoryController());

  int selectedCardIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String? selectedTableId;
  Map<Item, int> orderMap = {};

  double calculateTotal(Map<Item, int> orderMap) {
    double total = 0;
    for (var entry in orderMap.entries) {
      final item = entry.key;
      final quantity = entry.value;
      final totalPrice = item.price * quantity;
      total += totalPrice;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _loadCategoryItems();
  }

  void _loadCategoryItems() async {
    await categoryController.getCategoryList();
    if (categoryController.categoryList.isNotEmpty) {
      await categoryController.getItemsByCategoryId(categoryController.categoryList[0].id);
      setState(() {
        selectedCardIndex = 0;
      });
    }
  }

  bool isNewItem(DateTime createdAt) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return createdAt.isAfter(weekAgo);
  }

  void addToOrder(Item item, int quantity, List<Ingredient> selectedIngredients) {
    setState(() {
      if (orderMap.containsKey(item)) {
        orderMap[item] = orderMap[item]! + quantity;
      } else {
        orderMap[item] = quantity;
      }
    });
  }

  int _calculateCrossAxisCount(double width) {
    int crossAxisCount = (width / 160).floor();
    return crossAxisCount > 0 ? crossAxisCount : 1;
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
              Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bienvenue',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          final String query = _searchController.text.trim();
                                          setState(() {
                                            categoryController.searchItemsByName(query);
                                          });
                                        },
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 30,
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade500,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Center(
                                              child: Icon(Icons.search, color: Colors.white, size: 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: const InputDecoration(
                                          hintText: 'Rechercher',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        onChanged: (value) {
                                          final String query = value.trim();
                                          setState(() {
                                            categoryController.searchItemsByName(query);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PopupMenuButton<String>(
                              icon: const FaIcon(
                                FontAwesomeIcons.sliders,
                                color: Colors.black38,
                                size: 20,
                              ),
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'price',
                                  child: Text('Filtrer par prix'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'alphabet',
                                  child: Text('de A à Z'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'creationDate',
                                  child: Text('Les plus récents'),
                                ),
                              ],
                              onSelected: (String value) {
                                switch (value) {
                                  case 'price':
                                    categoryController.filterByPrice();
                                    break;
                                  case 'alphabet':
                                    categoryController.filterAlphabetically();
                                    break;
                                  case 'creationDate':
                                    categoryController.filterByCreationDate();
                                    break;
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TabBar(
                        isScrollable: true,
                        labelColor: AppTheme.lightTheme.primaryColor,
                        indicatorColor: AppTheme.lightTheme.primaryColor,
                        tabs: List.generate(
                          categoryController.categoryList.length,
                          (index) => Tab(
                            text: categoryController.categoryList[index].name,
                          ),
                        ),
                        onTap: (index) async {
                          setState(() {
                            selectedCardIndex = index;
                          });
                          await categoryController.getItemsByCategoryId(categoryController.categoryList[index].id);
                        },
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: List.generate(
                          categoryController.categoryList.length,
                          (index) => Obx(() {
                            if (categoryController.isLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    int crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const AlwaysScrollableScrollPhysics(),
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
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.grey.shade200, width: 1),
                                                color: Colors.white,
                                              ),
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 10),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: Container(
                                                          width: 130,
                                                          height: 95,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.rectangle,
                                                            borderRadius: BorderRadius.circular(10),
                                                            image: DecorationImage(
                                                              image: NetworkImage(item.imageUrl),
                                                              fit: BoxFit.cover,
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
                                                          padding: EdgeInsets.only(left: 10, right: 5),
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
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(10),
                                                          child: Text(
                                                            '${item.price.toStringAsFixed(2)} dt',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14,
                                                              color: Colors.grey.shade500,
                                                            ),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            ItemView().show(context, item, 1, addToOrder);
                                                          },
                                                          child: Padding(
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
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(12),
                                                      bottomRight: Radius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'New',
                                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: PaymentPage(orderMap: orderMap, calculateTotal: calculateTotal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
