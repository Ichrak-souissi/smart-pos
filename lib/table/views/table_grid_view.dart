import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/table_controller.dart';

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
                              color: isAllSelected ? Colors.white : Colors.white,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Text('All'),
                          ),
                        ),
                        SizedBox(width: 10),
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
                              color: isOnDineSelected ? Colors.white : Colors.white,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Text('On Dine'),
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
                              color: isReservedSelected ? Colors.white : Colors.white,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Reserved'),
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
                              color: isAvailableSelected ? Colors.white : Colors.white,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Available'),
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
      (isOnDineSelected && table.reserved == false && table.active) ||
      (isReservedSelected && table.reserved && table.active) ||
      (isAvailableSelected && !table.reserved && !table.active)) {
      if (table.reserved && table.active) {
      circleColor = Colors.green;
      statusText = 'Reserved';
      } else if (table.reserved == false && table.active) {
      circleColor = Colors.red;
      statusText = 'On Dine';
      } else {
      circleColor = Colors.blue;
      statusText = 'Available';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Text(
      'Table : ${table.id}',
      style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      ),
      ),
      SizedBox(height: 5),
      Row(
      children: [
      Icon(Icons.people_outline_outlined, size: 20),
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
      Icon(Icons.circle, color: circleColor, size: 10),
      SizedBox(width: 5),
      Text(
      statusText,
      style: TextStyle(fontSize: 14, color: circleColor),
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
              ],
            ),
          ),
          // Container 2
          Expanded(
            flex: 8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Manage Tables',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Card(
                          color: Colors.green.shade400,
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('Main dining',),
                          ),
                        ),
                        Card(
                          color: Colors.grey.shade100,
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('Terrace'),

                          ),
                        ),
                        Card(
                          color: Colors.grey.shade100,
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('Outdoor'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                     //  const SizedBox(width: 10,),
                        const Icon(Icons.circle, color: Colors.blueGrey, size: 10,),
                        const SizedBox(width: 9,),
                        const Text(
                          'Available',
                          style: TextStyle(fontSize: 15,),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 10,),
                        const Icon(Icons.circle, color: Colors.green, size: 10,),
                        const SizedBox(width: 10,),
                        const Text(
                          'Reserved',
                          style: TextStyle(fontSize: 15,),
                            overflow: TextOverflow.ellipsis,

                        ),
                        const SizedBox(width: 10,),
                        const Icon(Icons.circle, color: Colors.redAccent, size: 10,),
                        const SizedBox(width: 10,),
                        const Text(
                          'On Dine',
                          style: TextStyle(fontSize: 15,),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 130,
                      child: GridView.builder(
                        itemCount: numRows * 6,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final table = tableController.tableList.firstWhereOrNull(
                                (table) => table.position == index + 1,
                          );

                          if (table != null) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'id: ${table.id.toString()}',
                                  style: const TextStyle(fontSize: 16),
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
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}