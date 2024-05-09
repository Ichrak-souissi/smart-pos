import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({Key? key}) : super(key: key);

  @override
  _ReservationViewState createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  final RoomController roomController = Get.put(RoomController());
  int selectedRoomIndex = 0;
  String? selectedTableId;
  int numberOfClients = 0;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void initializeCounter() {
    setState(() {
      numberOfClients = 0;
    });
  }

  void incrementCounter() {
    setState(() {
      numberOfClients++;
    });
  }

  void decrementCounter() {
    setState(() {
      if (numberOfClients > 0) {
        numberOfClients--;
      }
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Réserver une table ',
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: DropdownButton<String>(
                        iconEnabledColor: AppTheme.lightTheme.primaryColor,
                        iconSize: 40,
                        value: selectedTableId,
                        onChanged: (value) {
                          setState(() {
                            selectedTableId = value;
                          });
                        },
                   items: roomController.tableList
    .where((table) => !table.active && !table.reserved)
    .map((table) {
  return DropdownMenuItem<String>(
    value: '${table.id}',
    child: Text(
      'Table ${table.id}',
      style: const TextStyle(color: Colors.black),
    ),
  );
}).toList(),


                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.grey.shade200,),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Nom du client',
                  prefixIcon: const Icon(Icons.person_outline),
                  fillColor: Colors.grey.shade50,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppTheme.lightTheme.primaryColor, width: 1.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Nombre de clients',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.remove, size: 15),
                            onPressed: decrementCounter,
                          ),
                        ),
                        Text(
                          '$numberOfClients',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.add, size: 15),
                              onPressed: incrementCounter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Date',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today_outlined),
                            onPressed: () {
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  TableCalendar(
                    calendarFormat: CalendarFormat.month,
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
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


}
