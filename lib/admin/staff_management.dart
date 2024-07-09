import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/authentication/controllers/pin_controller.dart';
import 'package:pos/authentication/models/user.dart';
import 'package:pos/room/widgets/appbar_widget.dart';

class StaffManagement extends StatefulWidget {
  const StaffManagement({Key? key}) : super(key: key);

  @override
  State<StaffManagement> createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement>
    with SingleTickerProviderStateMixin {
  final PinController pinController = Get.put(PinController());
  late TabController _tabController;
  late List<User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _initializeData() async {
    await pinController.getAllUsers();
    _filterUsers(); // Initial filter
  }

  void _handleTabSelection() {
    setState(() {
      _filterUsers(); // Update filter on tab change
    });
  }

  void _filterUsers() {
    switch (_tabController.index) {
      case 0: // Tous
        filteredUsers = pinController.users.value;
        break;
      case 1: // Serveurs
        filteredUsers = pinController.users.value
            .where((user) => user.role == 'waiter')
            .toList();
        break;
      case 2: // Admins
        filteredUsers = pinController.users.value
            .where((user) => user.role == 'admin')
            .toList();
        break;
      case 3: // Chefs
        filteredUsers = pinController.users.value
            .where((user) => user.role == 'chief')
            .toList();
        break;
      default:
        filteredUsers = [];
        break;
    }
  }

  void _showAddUserDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController roleController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un utilisateur'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(labelText: 'Rôle'),
                ),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(labelText: 'Code'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                // Action pour ajouter un nouveau membre du personnel
                final newUser = User(
                  id: pinController.users.length + 1,
                  name: nameController.text,
                  role: roleController.text,
                  code: codeController.text,
                  phone: int.parse(phoneController.text),
                );
                pinController.addUser(newUser);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            AppBarWidget(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add,
                        color: AppTheme.lightTheme.primaryColor),
                    onPressed: _showAddUserDialog,
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.lightTheme.primaryColor,
              indicatorColor: AppTheme.lightTheme.primaryColor,
              tabs: [
                Tab(text: 'Tous'),
                Tab(text: 'Serveurs'),
                Tab(text: 'Admins'),
                Tab(text: 'Chefs'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTable(filteredUsers),
                  _buildTable(filteredUsers),
                  _buildTable(filteredUsers),
                  _buildTable(filteredUsers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<User> users) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
                AppTheme.lightTheme.primaryColor.withOpacity(0.1)),
            dataRowColor: MaterialStateProperty.all(Colors.white),
            columns: [
              DataColumn(
                  label: Text('ID',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Nom',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Rôle',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Code',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Téléphone',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: users.map((user) {
              return DataRow(
                cells: [
                  DataCell(Text(user.id.toString())),
                  DataCell(Text(user.name)),
                  DataCell(Text(user.role)),
                  DataCell(Text(user.code)),
                  DataCell(Text(user.phone.toString())),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
