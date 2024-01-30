import 'dart:ui';

import 'package:custom_pin_screen/custom_pin_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pos/authentication/controllers/pin_controller.dart';

import '../widgets/Pin_code_field.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({Key? key}) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String pin = "";
  PinTheme pinTheme = PinTheme(
    keysColor: Colors.blue,
  );


  @override
  Widget build(BuildContext context) {

    final PinController controller = Get.put(PinController());


    return Scaffold(
      appBar: AppBar(
         elevation: 5,
        title: const  Text(
          "Binevenue",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            // color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          key:  GlobalKey(debugLabel: "pin_screen"),
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 4; i++)
                  PinCodeField(
                    key: Key('pinField$i'),
                    pin: pin,
                    pinCodeFieldIndex: i,
                    onChanged: (String ) {

                    }, theme: PinThemeData(),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            CustomKeyBoard(

              pinTheme: pinTheme,
              onChanged: (v) {
                if (kDebugMode) {
                  print(v);
                  pin = v;
                  setState(() {

                  });
                }
              },
              specialKey:const  Icon(
                Icons.check_circle_rounded,
                key: Key('login'),
                color: Colors.green,
                size: 50,
              ),
              specialKeyOnTap: () {
                controller.sendPin(pin) ;



              },
              maxLength: 4,
            ),
          ],
        ),
      ),
    );
  }
}

