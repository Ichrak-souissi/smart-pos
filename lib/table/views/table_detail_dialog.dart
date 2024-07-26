import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/table/models/table.dart';
import 'package:table_calendar/table_calendar.dart';

class TableDetailsDialog {
  final BuildContext context;
  final List<Order> ordersForSelectedTable;

  TableDetailsDialog(this.context, this.ordersForSelectedTable);

  void show(table) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? selectedDate;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.all(15),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Adjust width here
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Table N°${table.position}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'Capacité: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${table.capacity}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                          const Icon(
                            Icons.person_3_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Text(
                        '${table.active ? 'Occupé' : 'Disponible'}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // History header and calendar icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Historique des commandes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      color: AppTheme.lightTheme.primaryColor,
                      onPressed: () {
                        _showCalendarDialog(context, selectedDate);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Orders list
                Obx(() {
                  var filteredOrders = ordersForSelectedTable.where((order) {
                    if (selectedDate == null) return true;
                    return DateFormat('dd-MM-yyyy').format(order.createdAt) ==
                        DateFormat('dd-MM-yyyy').format(selectedDate!);
                  }).toList();

                  return filteredOrders.isNotEmpty
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: filteredOrders.map((order) {
                                String formattedDate = DateFormat('dd-MM-yyyy')
                                    .format(order.createdAt);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Commande #${order.id.toString().padLeft(4, '0')}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Total: ${order.total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            'Aucune commande pour cette date.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Fermer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCalendarDialog(BuildContext context, DateTime? selectedDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionner une date'),
          content: SizedBox(
            width: double.maxFinite,
            child: TableCalendar(
              focusedDay: DateTime.now(),
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                selectedDate = selectedDay;
                Navigator.pop(context);
                (context as Element).markNeedsBuild();
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(color: Colors.white),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              firstDay: DateTime(2000, 1, 1),
              lastDay: DateTime(2100, 12, 31),
            ),
          ),
        );
      },
    );
  }
}
