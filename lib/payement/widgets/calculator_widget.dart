import 'package:flutter/material.dart';
import 'package:flutter_awesome_calculator/flutter_awesome_calculator.dart';
import 'package:get/get.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/payement/controllers/payement_controller.dart';
import 'package:pos/room/controllers/room_controller.dart';
import 'package:pos/table/controllers/table_controller.dart';

class CalculatorWidget extends StatefulWidget {
  final double orderTotal;
  final List<Order> orders;
  final int tableId;

  CalculatorWidget({
    required this.orderTotal,
    required this.orders,
    required this.tableId,
  });

  @override
  _CalculatorWidgetState createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  double clientAmount = 0.0;
  double amountToReturn = 0.0;
  final TextEditingController clientAmountController = TextEditingController();
  final PaymentController paymentController = Get.put(PaymentController());
  final OrderController orderController = Get.put(OrderController());
  final RoomController roomController = Get.put(RoomController());
  final TableController tableController = Get.put(TableController());
  @override
  void dispose() {
    clientAmountController.dispose();
    super.dispose();
  }

  void updateAmountToReturn(String value) {
    setState(() {
      clientAmount = value.isNotEmpty ? double.parse(value) : 0.0;
      amountToReturn = clientAmount - widget.orderTotal;
    });
  }

  Future<void> handlePayment() async {
    if (amountToReturn >= 0) {
      try {
        for (var order in widget.orders) {
          // await orderController.updateOrderStatus(order.id.toString(), 1);
          await orderController.UpdateOrder(order.id.toString());
        }
        await tableController.updateTable(widget.tableId.toString(), false);

        showPaymentSuccessDialog();
      } catch (e) {
        Get.snackbar('Erreur', 'Une erreur est survenue lors du paiement.');
      }
    } else {
      Get.snackbar('Erreur', 'Le montant saisi est insuffisant.');
    }
  }

  void showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          contentPadding: const EdgeInsets.all(20),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.monetization_on_outlined,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 10),
              const Text(
                'Paiement effectué avec succès.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      backgroundColor: Colors.transparent,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Montant d\'entrée',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: Icon(Icons.input, color: Colors.black),
              ),
              keyboardType: TextInputType.number,
              controller: clientAmountController,
              onChanged: updateAmountToReturn,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Montant de la commande',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: Icon(Icons.shopping_cart, color: Colors.black),
              ),
              readOnly: true,
              controller: TextEditingController(
                text: '${widget.orderTotal.toStringAsFixed(2)} DT',
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FlutterAwesomeCalculator(
                context: context,
                digitsButtonColor: Colors.white,
                operatorsButtonColor: Colors.white,
                backgroundColor: Colors.transparent,
                clearButtonColor: Colors.white,
                expressionAnswerColor: Colors.white,
                onChanged: (answer, expression) {
                  if (expression == 'del') {
                    if (clientAmountController.text.isNotEmpty) {
                      clientAmountController.text = clientAmountController.text
                          .substring(0, clientAmountController.text.length - 1);
                      updateAmountToReturn(clientAmountController.text);
                    }
                  } else if (expression == 'C') {
                    clientAmountController.clear();
                    updateAmountToReturn('');
                  } else {
                    updateAmountToReturn(answer);
                    clientAmountController.text = answer;
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    icon: Icon(Icons.credit_card,
                        color: const Color.fromARGB(255, 4, 52, 92)),
                    label: Text(
                      'Carte',
                      style: TextStyle(
                          fontSize: 14, color: Color.fromARGB(255, 4, 52, 92)),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    icon: Icon(Icons.money, color: Colors.white),
                    label: Text(
                      'Cash',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 215, 228, 217),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                'Montant à rendre: ${amountToReturn.toStringAsFixed(2)} DT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: amountToReturn >= 0 ? Colors.black : Colors.black,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 99, 104, 147),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 99, 104, 147),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
                child: Text(
                  'Payer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
