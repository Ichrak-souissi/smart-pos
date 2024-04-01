import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/table/models/table.dart' as Customtable;
import '../controllers/table_controller.dart';
import '../models/table.dart';

class TableGridView extends StatefulWidget {
  const TableGridView({Key? key}) : super(key: key);

  @override
  State<TableGridView> createState() => _TableGridViewState();
}

class _TableGridViewState extends State<TableGridView> {
  final TableController tableController = Get.put(TableController());
  bool isOnDineSelected = false;
  bool isReservedSelected = false;
  bool isAllSelected = true;
  bool isAvailableSelected = false;


  @override
  void initState() {
    super.initState();
    tableController.getTableList();
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int maxPosition = tableController.tableList.isNotEmpty
          ? tableController.tableList
          .map((table) => table.position)
          .reduce((value, element) => value > element ? value : element)
          : 0;
      int numRows = (maxPosition / 6).ceil();

      return Row(
        children: [
          // Container 1
          Expanded(
            flex: 2,
            // table details
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAllSelected = true;
                              isOnDineSelected = false;
                              isReservedSelected = false;
                              isAvailableSelected = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: isAllSelected
                                  ? Border.all(color: Colors.green, width: 2)
                                  : null,
                              color: isAllSelected ? Colors.white : Colors
                                  .white,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: const Text('Tous'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAllSelected = false;
                              isOnDineSelected = true;
                              isReservedSelected = false;
                              isAvailableSelected = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: isOnDineSelected
                                  ? Border.all(color: Colors.green, width: 2)
                                  : null,
                              color: isOnDineSelected ? Colors.white : Colors
                                  .white,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Occupés'),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAllSelected = false;
                              isOnDineSelected = false;
                              isReservedSelected = true;
                              isAvailableSelected = false;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: isReservedSelected
                                  ? Border.all(color: Colors.green, width: 2)
                                  : null,
                              color: isReservedSelected
                                  ? Colors.white
                                  : Colors.white,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Réservés'),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAllSelected = false;
                              isOnDineSelected = false;
                              isReservedSelected = false;
                              isAvailableSelected = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: isAvailableSelected
                                  ? Border.all(color: Colors.green, width: 2)
                                  : null,
                              color: isAvailableSelected
                                  ? Colors.white
                                  : Colors.white,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Disponible'),
                          ),
                        ),
                      ],
                    ),
                  ),

                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    itemCount: tableController.tableList.length,
                    itemBuilder: (context, index) {
                      final table = tableController.tableList[index];
                      Color circleColor;
                      String statusText;

                      if ((isAllSelected) ||
                          (isOnDineSelected && table.reserved == false &&
                              table.active) ||
                          (isReservedSelected && table.reserved &&
                              table.active) ||
                          (isAvailableSelected && !table.reserved &&
                              !table.active)) {
                        if (table.reserved && table.active) {
                          circleColor = Colors.green;
                          statusText = 'Réservé';
                        } else if (table.reserved == false && table.active) {
                          circleColor = Colors.red;
                          statusText = 'Occupé';
                        } else {
                          circleColor = Colors.blue;
                          statusText = 'Disponible';
                        }

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Text(
                                          'Table : ${table.id}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Position : ${table.position}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                                Icons.people_outline_outlined,
                                                size: 20),
                                            Text(
                                              ': ${table.capacity}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.circle, color: circleColor,
                                          size: 10),
                                      SizedBox(width: 5),
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                            fontSize: 14, color: circleColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
//add a reservation


              ],
            ),
          ),
          // Container 2
          Expanded(
            flex: 8,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Gérer les tables',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showAddTableDialog();
                        },
                        child: Text('Ajouter une table', style: TextStyle(
                            color: Colors.black)),
                      )

                    ],
                  ),
                  Container(
                    color: Colors.white,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //  const SizedBox(width: 10,),
                        Icon(Icons.circle, color: Colors.blueGrey, size: 10,),
                        SizedBox(width: 9,),
                        Text(
                          'Disponible',
                          style: TextStyle(fontSize: 15,),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 10,),
                        Icon(Icons.circle, color: Colors.green, size: 10,),
                        SizedBox(width: 10,),
                        Text(
                          'Reservé',
                          style: TextStyle(fontSize: 15,),
                          overflow: TextOverflow.ellipsis,

                        ),
                        SizedBox(width: 10,),
                        Icon(
                          Icons.circle, color: Colors.redAccent, size: 10,),
                        SizedBox(width: 10,),
                        Text(
                          'Occupé',
                          style: TextStyle(fontSize: 15,),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      color: Colors.white,
                      child: SizedBox(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height - 130,
                        child: GridView.builder(
                          itemCount: numRows * 6,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final table = tableController.tableList
                                .firstWhereOrNull(
                                  (table) => table.position == index + 1,
                            );

                            if (table != null) {
                              return GestureDetector(
                                onTap: () {
                                  _showTableDetailsDialog(table);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Table: ${table.id.toString()}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      );
    });
  }

  void _showTableDetailsDialog(Customtable.Table table) {
    String tableState = '';
    Color stateColor = Colors.black;

    if (table.reserved && table.active) {
      tableState = 'Réservé';
      stateColor = Colors.green;
    } else if (table.reserved == false && table.active) {
      tableState = 'Occupé';
      stateColor = Colors.red;
    } else {
      tableState = 'Disponible';
      stateColor = Colors.blue;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Table ${table.id} Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Position: ${table.position}'),
                Text('Capacité: ${table.capacity}'),
                Text('État: $tableState', style: TextStyle(color: stateColor)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Passer une commande',),
            ),
            TextButton(
              onPressed: () {
                _showReservationDialog(table);
              },
              child: Text('Ajouter une réservation',),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer',),
            ),
          ],
        );
      },
    );
  }

  void _showReservationDialog(Customtable.Table table) {
    String clientName = '';
    int reservationDuration = 0;
    int numberOfSeats = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une réservation pour la table ${table.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nom du client',
                ),
                onChanged: (value) {
                  clientName = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Durée de la réservation (en heures)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  reservationDuration = int.tryParse(value) ?? 0;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nombre de places',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  numberOfSeats = int.tryParse(value) ?? 0;
                },
              ),
              SizedBox(height: 10),
            ],
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
                Customtable.Table updatedTable = Customtable.Table(
                  id: table.id,
                  position: table.position,
                  capacity: table.capacity,
                  reserved: true,
                  active: true,
                );

                await tableController.updateTable(updatedTable);
                tableController.getTableList();

                Navigator.of(context).pop();
              },
              child: Text('Réserver',),
            ),
          ],
        );
      },
    );
  }

  void _showAddTableDialog() {
    int position = 0; // Initialize position
    int capacity = 0;
    int id = 0;
    bool isReserved = false; // Initialize reservation status

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une table'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Position de la table',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  position = int.tryParse(value) ?? 0;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Capacité de la table',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  capacity = int.tryParse(value) ?? 0;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('État de la table: '),
                  SizedBox(width: 10),
                  DropdownButton<bool>(
                    value: isReserved,
                    onChanged: (value) {
                      setState(() {
                        isReserved = value!;
                      });
                    },
                    items: [
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text('Disponible'),
                      ),
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('Réservé'),
                      ),
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('Occupé'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Customtable.Table newTable= Customtable.Table (
                  id: id,
                  position: position,
                  capacity: capacity,
                  reserved: isReserved,
                  active: true,
                );
                tableController.addTable(newTable);
                tableController.getTableList();
                Navigator.of(context).pop();
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

}

