import 'package:flutter/material.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/item/models/item.dart';

class PaymentPage extends StatefulWidget {
  final Map<Item, int> orderMap;
  final double Function(Map<Item, int>) calculateTotal;
  final String? selectedTableId;

  const PaymentPage({
    Key? key,
    required this.orderMap,
    required this.calculateTotal,
    this.selectedTableId,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedTableId;
  bool showPayment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'Table N : ${widget.selectedTableId ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                       
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
            const SizedBox(height: 5),
            Divider(color: Colors.grey.shade100),
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: widget.orderMap.entries.map((entry) {
                  final item = entry.key;
                  final quantity = entry.value;
                  final totalPrice = item.price * quantity;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qte: $quantity',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$totalPrice dt',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.orderMap.remove(item);
                                });
                              },
                              child: const Icon(
                                Icons.remove,
                                color: Colors.black,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      showPayment = !showPayment;
                    });
                  },
                  icon: Icon(showPayment ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                ),
              ],
            ),
            AnimatedContainer(
              height: showPayment ? MediaQuery.of(context).size.height * 0.2 : 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total: ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '${widget.calculateTotal(widget.orderMap)} dt',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.lightTheme.primaryColor,
                              ),
                              child: const Text('Payer', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                          Flexible(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.lightTheme.primaryColor,
                              ),
                              child: const Text('Payer plus tard', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
