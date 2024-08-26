import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/authentication/controllers/pin_controller.dart';
import 'package:pos/authentication/controllers/user_controller.dart';
import 'package:pos/authentication/models/user.dart';
import 'package:pos/shared/widgets/appbar_widget.dart';

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
  final Map<int, TextEditingController> workHoursControllers = {};
  final Map<int, TextEditingController> emailControllers = {};
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
                AppTheme.lightTheme.primaryColor.withOpacity(0.2)),
            dataRowColor: MaterialStateProperty.all(Colors.white),
            columns: [
              DataColumn(
                  label: Text('ID',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Utilisateur',
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
                  label: Text('Horaire de Travail',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Email',
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
              workHoursControllers[user.id] ??=
                  TextEditingController(text: user.workHours ?? '');
              emailControllers[user.id] ??=
                  TextEditingController(text: user.email);

              return DataRow(cells: [
                DataCell(Text(user.id.toString())),
                DataCell(
                  editingUsers.contains(user.id)
                      ? TextFormField(
                          controller: nameControllers[user.id],
                          decoration: InputDecoration(border: InputBorder.none),
                        )
                      : Text('${user.name}'),
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
                  editingUsers.contains(user.id)
                      ? TextFormField(
                          controller: workHoursControllers[user.id],
                          decoration: InputDecoration(border: InputBorder.none),
                        )
                      : Text(user.workHours ?? 'Non défini'),
                ),
                DataCell(
                  editingUsers.contains(user.id)
                      ? TextFormField(
                          controller: emailControllers[user.id],
                          decoration: InputDecoration(border: InputBorder.none),
                        )
                      : Text(user.email),
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
                              email:
                                  emailControllers[user.id]?.text ?? user.email,
                              image: user.image,
                              role: roleControllers[user.id]?.text ?? user.role,
                              code: codeControllers[user.id]?.text ?? user.code,
                              phone: int.tryParse(
                                      phoneControllers[user.id]?.text ?? '') ??
                                  user.phone,
                              workHours: workHoursControllers[user.id]?.text ??
                                  user.workHours,
                            );
                            await userController.updateUser(updatedUser);

                            setState(() {
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
          content: Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
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
                setState(() {
                  filteredUsers.removeWhere((u) => u.id == user.id);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _showAddUserDialog() {
    String name = '';
    String role = '';
    String code = '';
    int phone = 0;
    String workHours = '';
    String email = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un utilisateur'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : AssetImage('assets/images/user.png') as ImageProvider,
                    child: Icon(
                      Icons.add_a_photo,
                      size: 50,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(labelText: 'Nom'),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Rôle'),
                  onChanged: (value) {
                    role = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Code'),
                  onChanged: (value) {
                    code = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    phone = int.tryParse(value) ?? 0;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Horaire de Travail'),
                  onChanged: (value) {
                    workHours = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                  onChanged: (value) {
                    email = value;
                  },
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
                  name: name,
                  role: role,
                  code: code,
                  phone: phone,
                  workHours: workHours,
                  email: email,
                  image: _pickedImage != null
                      ? _pickedImage!.path
                      : 'assets/images/user.png',
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
