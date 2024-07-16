import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/authentication/models/user.dart';
import 'package:pos/room/widgets/appbar_widget.dart';
import 'package:pos/authentication/controllers/pin_controller.dart';
import 'package:pos/authentication/controllers/user_controller.dart';

class StaffManagement extends StatefulWidget {
  const StaffManagement({Key? key}) : super(key: key);

  @override
  State<StaffManagement> createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement>
    with SingleTickerProviderStateMixin {
  final PinController pinController = Get.put(PinController());
  final UserController userController = Get.put(UserController());
  late TabController _tabController;
  late List<User> filteredUsers = [];
  final Map<int, TextEditingController> nameControllers = {};
  final Map<int, TextEditingController> roleControllers = {};
  final Map<int, TextEditingController> codeControllers = {};
  final Map<int, TextEditingController> phoneControllers = {};
  final Set<int> editingUsers = Set<int>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
  }

  void _initializeData() async {
    await userController.getAllUsers();
    _filterUsers();
  }

  void _handleTabSelection() {
    _filterUsers();
  }

  void _filterUsers() {
    switch (_tabController.index) {
      case 0:
        filteredUsers = userController.users;
        break;
      case 1:
        filteredUsers = userController.users
            .where((user) => user.role == 'waiter')
            .toList();
        break;
      case 2:
        filteredUsers =
            userController.users.where((user) => user.role == 'admin').toList();
        break;
      case 3:
        filteredUsers =
            userController.users.where((user) => user.role == 'chief').toList();
        break;
      default:
        filteredUsers = [];
        break;
    }
    setState(() {
      filteredUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 255, 245),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                indicatorColor: AppTheme.lightTheme.primaryColor,
                tabs: [
                  Tab(text: 'Tous'),
                  Tab(text: 'Serveurs'),
                  Tab(text: 'Admins'),
                  Tab(text: 'Chefs'),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 250,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: Icon(Icons.add),
        //backgroundColor: AppTheme.lightTheme.primaryColor,
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
              DataColumn(
                  label: Text('Actions',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: users.map((user) {
              nameControllers[user.id] ??=
                  TextEditingController(text: user.name);
              roleControllers[user.id] ??=
                  TextEditingController(text: user.role);
              codeControllers[user.id] ??=
                  TextEditingController(text: user.code);
              phoneControllers[user.id] ??=
                  TextEditingController(text: user.phone.toString());

              return DataRow(cells: [
                DataCell(Text(user.id.toString())),
                DataCell(
                  editingUsers.contains(user.id)
                      ? TextFormField(
                          controller: nameControllers[user.id],
                          decoration: InputDecoration(border: InputBorder.none),
                        )
                      : Text(user.name),
                ),
                DataCell(
                  editingUsers.contains(user.id)
                      ? TextFormField(
                          controller: roleControllers[user.id],
                          decoration: InputDecoration(border: InputBorder.none),
                        )
                      : Text(user.role),
                ),
                DataCell(
                  editingUsers.contains(user.id)
                      ? TextFormField(
                          controller: codeControllers[user.id],
                          decoration: InputDecoration(border: InputBorder.none),
                        )
                      : Text(user.code),
                ),
                DataCell(
                  editingUsers.contains(user.id)
                      ? TextFormField(
                          controller: phoneControllers[user.id],
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(border: InputBorder.none),
                        )
                      : Text(user.phone.toString()),
                ),
                DataCell(
                  Row(
                    children: [
                      if (editingUsers.contains(user.id))
                        IconButton(
                          icon: Icon(Icons.save, color: Colors.green),
                          onPressed: () async {
                            final updatedUser = User(
                              id: user.id,
                              name: nameControllers[user.id]?.text ?? user.name,
                              role: roleControllers[user.id]?.text ?? user.role,
                              code: codeControllers[user.id]?.text ?? user.code,
                              phone: int.tryParse(
                                      phoneControllers[user.id]?.text ?? '') ??
                                  user.phone,
                            );
                            await userController.updateUser(updatedUser);

                            setState(() {
                              // Mettre à jour l'utilisateur dans la liste
                              final index = filteredUsers
                                  .indexWhere((u) => u.id == user.id);
                              if (index != -1) {
                                filteredUsers[index] = updatedUser;
                              }
                              editingUsers.remove(user.id);
                            });
                          },
                        )
                      else
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () {
                            setState(() {
                              editingUsers.add(user.id);
                            });
                          },
                        ),
                      if (editingUsers.contains(user.id))
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              editingUsers.remove(user.id);
                            });
                          },
                        )
                      else
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            _showDeleteConfirmationDialog(user);
                          },
                        ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer cet utilisateur ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                await userController.deleteUser(user.id);
                Navigator.of(context).pop();
                setState(() {
                  filteredUsers.removeWhere((u) => u.id == user.id);
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController codeController = TextEditingController();
        final TextEditingController phoneController = TextEditingController();
        String selectedRole = 'waiter';

        return AlertDialog(
          title: Text('Ajouter un utilisateur'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRole = newValue!;
                    });
                  },
                  items: <String>['waiter', 'admin', 'chief']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
              onPressed: () async {
                final newUser = User(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameController.text,
                  role: selectedRole,
                  code: codeController.text,
                  phone: int.tryParse(phoneController.text) ?? 0,
                );
                await userController.addUser(newUser);
                Navigator.of(context).pop();
                setState(() {
                  filteredUsers.add(newUser);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
