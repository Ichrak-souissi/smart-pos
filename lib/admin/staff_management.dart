import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
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

class _StaffManagementState extends State<StaffManagement> {
  final PinController pinController = Get.put(PinController());
  final UserController userController = Get.put(UserController());
  late List<User> filteredUsers = [];
  final Map<int, TextEditingController> nameControllers = {};
  final Map<int, TextEditingController> roleControllers = {};
  final Map<int, TextEditingController> codeControllers = {};
  final Map<int, TextEditingController> phoneControllers = {};
  final Map<int, TextEditingController> workHoursControllers = {};
  final Map<int, TextEditingController> emailControllers = {};
  final Set<int> editingUsers = Set<int>();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String _selectedRole = 'all';
  bool _isCodeVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await userController.getAllUsers();
    _filterUsers();
  }

  void _filterUsers() {
    setState(() {
      switch (_selectedRole) {
        case 'waiter':
          filteredUsers = userController.users
              .where((user) => user.role == 'waiter')
              .toList();
          break;
        case 'admin':
          filteredUsers = userController.users
              .where((user) => user.role == 'admin')
              .toList();
          break;
        case 'chief':
          filteredUsers = userController.users
              .where((user) => user.role == 'chief')
              .toList();
          break;
        default:
          filteredUsers = userController.users;
          break;
      }
    });
  }

  Widget _buildCategoryBoxes() {
    final roles = ['Tous', 'Serveurs', 'Admins', 'Chefs'];
    final roleValues = ['all', 'waiter', 'admin', 'chief'];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(roles.length, (index) {
            final role = roles[index];
            final roleValue = roleValues[index];
            final isSelected = _selectedRole == roleValue;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRole = roleValue;
                });
                _filterUsers();
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
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
                    _buildCategoryBoxes(),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 250,
                child: _buildTable(filteredUsers),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: Icon(
          Icons.add,
          color: Colors.green,
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
                          obscureText: !_isCodeVisible,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isCodeVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isCodeVisible = !_isCodeVisible;
                                });
                              },
                            ),
                          ),
                        )
                      : Text(_isCodeVisible ? user.code : '********'),
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
                          keyboardType: TextInputType.emailAddress,
                        )
                      : Text(user.email ?? ''),
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
                              name: nameControllers[user.id]!.text,
                              role: roleControllers[user.id]!.text,
                              code: codeControllers[user.id]!.text,
                              phone: int.parse(phoneControllers[user.id]!.text),
                              workHours: workHoursControllers[user.id]!.text,
                              email: emailControllers[user.id]!.text,
                            );

                            await userController.updateUser(updatedUser);

                            setState(() {
                              editingUsers.remove(user.id);
                              _initializeData();
                            });
                          },
                        ),
                      IconButton(
                        icon: editingUsers.contains(user.id)
                            ? Icon(Icons.cancel, color: Colors.red)
                            : Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            if (editingUsers.contains(user.id)) {
                              editingUsers.remove(user.id);
                            } else {
                              editingUsers.add(user.id);
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await userController.deleteUser(user.id);
                          setState(() {
                            _initializeData();
                          });
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

  Future<void> _showAddUserDialog() async {
    String _selectedRole = 'waiter';
    TimeOfDay? _startTime;
    TimeOfDay? _endTime;

    final _formKey = GlobalKey<FormState>(); // Ajoutez cette ligne

    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final phoneController = TextEditingController();
    final workHoursController = TextEditingController();
    final emailController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter un utilisateur'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey, // Utilisez ce formulaire
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est requis';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'waiter', child: Text('Serveur')),
                    DropdownMenuItem(
                        value: 'admin', child: Text('Administrateur')),
                    DropdownMenuItem(value: 'chief', child: Text('Chef')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le rôle est requis';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: codeController,
                  obscureText: !_isCodeVisible,
                  decoration: InputDecoration(
                    labelText: 'Code',
                    prefixIcon: Icon(Icons.pin_sharp),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isCodeVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isCodeVisible = !_isCodeVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le code est requis';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le téléphone est requis';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Le numéro de téléphone n\'est pas valide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final TimeOfDay? pickedStartTime =
                              await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedStartTime != null) {
                            setState(() {
                              _startTime = pickedStartTime;
                              workHoursController.text =
                                  '${_startTime?.format(context)} - ${_endTime?.format(context) ?? ''}';
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(_startTime != null
                            ? _startTime!.format(context)
                            : 'Début'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final TimeOfDay? pickedEndTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedEndTime != null) {
                            setState(() {
                              _endTime = pickedEndTime;
                              workHoursController.text =
                                  '${_startTime?.format(context) ?? ''} - ${_endTime?.format(context)}';
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                        ),
                        child: Text(_endTime != null
                            ? _endTime!.format(context)
                            : 'Fin'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: workHoursController,
                  decoration: InputDecoration(
                    labelText: 'Horaire de Travail',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Email non valide';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Annuler', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newUser = User(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameController.text,
                  role: _selectedRole,
                  code: codeController.text,
                  phone: int.tryParse(phoneController.text) ?? 0,
                  workHours: workHoursController.text,
                  email: emailController.text,
                );
                userController.addUser(newUser);
                Navigator.of(context).pop();
                setState(() {
                  filteredUsers.add(newUser);
                });
              }
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
