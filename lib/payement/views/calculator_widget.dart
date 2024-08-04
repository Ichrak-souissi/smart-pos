import 'package:flutter/material.dart';
import 'package:flutter_awesome_calculator/flutter_awesome_calculator.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/order/controllers/order_controller.dart';
import 'package:pos/order/models/order.dart';
import 'package:pos/payement/controllers/payement_controller.dart';

class CalculatorWidget extends StatefulWidget {
  final double orderTotal;
  final List<Order> orders;

  CalculatorWidget({
    required this.orderTotal,
    required this.orders,
  });

  @override
  _CalculatorWidgetState createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  double clientAmount = 0.0;
  double amountToReturn = 0.0;
  TextEditingController clientAmountController = TextEditingController();
  final PaymentController paymentController = Get.put(PaymentController());
  final OrderController orderController = Get.put(OrderController());

  @override
  void dispose() {
    clientAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth * 0.3,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Montant d\'entrée',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.input),
                  ),
                  keyboardType: TextInputType.number,
                  controller: clientAmountController,
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        clientAmount = double.parse(value);
                      } else {
                        clientAmount = 0.0;
                      }
                      amountToReturn = clientAmount - widget.orderTotal;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Montant de la commande',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.shopping_cart),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: '${widget.orderTotal.toStringAsFixed(3)} DT',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Montant à rendre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.money_off),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: '${amountToReturn.toStringAsFixed(3)} DT',
                  ),
                ),
                SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 250,
                  ),
                  child: FlutterAwesomeCalculator(
                    context: context,
                    digitsButtonColor: Color.fromARGB(255, 4, 204, 107),
                    operatorsButtonColor: Color.fromARGB(255, 119, 246, 185),
                    backgroundColor: Colors.white,
                    clearButtonColor: Color.fromARGB(255, 119, 246, 185),
                    expressionAnswerColor: Color.fromARGB(255, 119, 246, 185),
                    onChanged: (answer, expression) {
                      setState(() {
                        if (expression == 'del') {
                          clientAmountController.text = '';
                          clientAmount = 0.0;
                          amountToReturn = 0.0;
                        } else {
                          if (answer.isNotEmpty) {
                            clientAmount = double.parse(answer);
                            clientAmountController.text =
                                clientAmount.toStringAsFixed(3);
                          } else {
                            clientAmount = 0.0;
                            clientAmountController.text = '';
                          }
                          amountToReturn = clientAmount - widget.orderTotal;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          for (Order order in widget.orders) {
                            await orderController.UpdateOrder(
                                order.id.toString());
                          }

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightTheme.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          'Valider',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
