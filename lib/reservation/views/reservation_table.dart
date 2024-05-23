import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pos/reservation/controller/reservation_controller.dart';

class ReservationTableView extends StatefulWidget {
  const ReservationTableView({Key? key}) : super(key: key);

  @override
  State<ReservationTableView> createState() => _ReservationTableState();
}

class _ReservationTableState extends State<ReservationTableView> {
  final ReservationController reservationController = Get.put(ReservationController());

  @override
  void initState() {
    super.initState();
    reservationController.fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 8,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Bienvenue',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        const SizedBox(width: 20),
   Flexible(
  child: Container(
    constraints: BoxConstraints(maxWidth: 900), 
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
              setState(() {});
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 30,
              ),
              child: Container(
                width: 30,
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
          child: Container(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (value) {
                value.trim();
                setState(() {});
              },
            ),
          ),
        ),
      ],
    ),
  ),
),
                        SizedBox(width: 20,),
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
                                  break;
                                case 'alphabet':
                                  break;
                                case 'creationDate':
                                  break;
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40,),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(() {
                          if (reservationController.isLoading.value) {
                            return Center(child: CircularProgressIndicator());
                          }
                          return Theme(
                            data: ThemeData(
                              dividerColor: Colors.grey,
                              highlightColor: Colors.grey.shade200,
                            ),
                            child: DataTable(
                              columnSpacing: 30,
                              headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                              columns:  [
DataColumn(
  label: Container(
    alignment: Alignment.center,
    child: Text('ID de la table'),
  ),
),
DataColumn(
  label: Container(
    alignment: Alignment.center,
    child: Text('Nom du Client'),
  ),
),
DataColumn(
  label: Container(
    alignment: Alignment.center,
    child: Text('Date de Réservation'),
  ),
),
DataColumn(
  label: Container(
    alignment: Alignment.center,
    child: Text('Heure de Réservation'),
  ),
),
DataColumn(
  label: Container(
    alignment: Alignment.center,
    child: Text('Nombre de Clients'),
  ),
),
DataColumn(
  label: Container(
    alignment: Alignment.center,
    child: Text('Commander', textAlign: TextAlign.center,),
  ),
),
DataColumn(
  label: Container(
    alignment: Alignment.center,
    child: Text('Actions'),
  ),
),
                              ],
                              rows: reservationController.reservations.map((reservation) {
                                return DataRow(
                                  cells: [
DataCell(Container(
  alignment: Alignment.center,
  child: Text(reservation.foodtableId.toString()),
)),                                    
DataCell(Container(
  alignment: Alignment.center,
  child: Text(reservation.client),
)),                                  
DataCell(Container(
  alignment: Alignment.center,
  child: Text(reservation.date),
)),                                  
DataCell(Container(
  alignment: Alignment.center,
  child: Text(reservation.hour),
)),                                 
DataCell(Container(
  alignment: Alignment.center,
  child: Text(reservation.numberOfGuests.toString()),
)),                          
          DataCell(Container(
  alignment: Alignment.center,
  child: TextButton(
    onPressed: () {
    },
    child: Text('Passer une commande'),
  ),
)),

                                    DataCell(
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () {
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
