import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/category/controllers/category_controller.dart';
import 'package:pos/item/controllers/item_controller.dart';
import 'package:pos/item/models/item.dart';
import 'package:pos/shared/widgets/appbar_widget.dart';

class ItemStatusManagement extends StatefulWidget {
  const ItemStatusManagement({super.key});

  @override
  State<ItemStatusManagement> createState() => _ItemStatusManagementState();
}

class _ItemStatusManagementState extends State<ItemStatusManagement> {
  final ItemController itemController = Get.put(ItemController());
  final CategoryController categoryController = Get.put(CategoryController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadCategories();
  }

  Future<void> _loadItems() async {
    await itemController.fetchItems();
  }

  Future<void> _loadCategories() async {
    await categoryController.getCategoryList();
    setState(() {});
  }

  void _updateItemAvailability(Item item, bool isAvailable) async {
    item.isActive = isAvailable;
    await itemController.updateItem(item);
    setState(() {});
  }

  String getCategoryName(String categoryId) {
    final intId = int.tryParse(categoryId);
    return categoryController.getCategoryNameById(intId ?? -1);
  }

  final RxString _filter = 'all'.obs;

  List<Item> _filterItems() {
    final searchTerm = _searchController.text.toLowerCase();
    List<Item> filteredItems = [];

    switch (_filter.value) {
      case 'available':
        filteredItems = itemController.categoryItems
            .where((item) => item.isActive)
            .toList();
        break;
      case 'unavailable':
        filteredItems = itemController.categoryItems
            .where((item) => !item.isActive)
            .toList();
        break;
      case 'all':
      default:
        filteredItems = itemController.categoryItems;
        break;
    }

    if (searchTerm.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) => item.name.toLowerCase().contains(searchTerm))
          .toList();
    }

    return filteredItems;
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = _filter.value == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filter.value = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightTheme.primaryColor : Colors.white,
          border: Border.all(
            color: AppTheme.lightTheme.primaryColor,
            width: isSelected ? 0 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 24,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 255, 245),
      body: SafeArea(
        child: Column(
          children: [
            const AppBarWidget(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        _buildFilterButton('Tous', 'all'),
                        _buildFilterButton('Disponibles', 'available'),
                        _buildFilterButton('Non Disponibles', 'unavailable'),
                      ],
                    ),
                  ),
                  _buildSearchBar(),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (itemController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                if (itemController.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(
                      itemController.errorMessage.value,
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  );
                }
                if (_filterItems().isEmpty) {
                  return Center(
                    child: Text(
                      'Aucun article disponible.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filterItems().length,
                    itemBuilder: (context, index) {
                      final item = _filterItems()[index];
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.all(8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(item.imageUrl),
                                backgroundColor: Colors.transparent,
                                child: item.imageUrl.isEmpty
                                    ? Icon(Icons.image, size: 50)
                                    : null,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Catégorie: ${getCategoryName(item.categoryId.toString())}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    item.isActive
                                        ? 'Disponible'
                                        : 'Non Disponible',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: item.isActive
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: item.isActive,
                                  onChanged: (bool value) {
                                    _updateItemAvailability(item, value);
                                  },
                                  activeColor: AppTheme.lightTheme.primaryColor,
                                  inactiveTrackColor:
                                      Colors.grey.withOpacity(0.5),
                                  inactiveThumbColor: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
