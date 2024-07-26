import 'package:flutter/material.dart';
import 'package:flutter_awesome_calculator/flutter_awesome_calculator.dart';
import 'package:pos/order/models/order.dart';

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
                    text: '${widget.orderTotal.toStringAsFixed(2)} DT',
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
                    text: '${amountToReturn.toStringAsFixed(2)} DT',
                  ),
                ),
                SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 250,
                  ),
                  child: FlutterAwesomeCalculator(
                    context: context,
                    digitsButtonColor: Colors.teal,
                    backgroundColor: Colors.white,
                    expressionAnswerColor: Colors.redAccent,
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
                                clientAmount.toStringAsFixed(2);
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
                          Navigator.of(context).pop(); // Close the dialog
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
                        onPressed: () {
                          // Add your logic to validate the payment
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
