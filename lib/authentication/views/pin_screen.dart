import 'dart:ui';

import 'package:custom_pin_screen/custom_pin_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../widgets/Pin_code_field.dart';

class PinAuthScreen extends StatefulWidget {
  const PinAuthScreen({Key? key}) : super(key: key);

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
  String pin = "";
  PinTheme pinTheme = PinTheme(
    keysColor: Colors.blue,
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          mainAxisSize: MainAxisSize.min,
          children: [


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
                  Logger().i(pin) ;
                  Get.snackbar(
                    'login successfully',
                    '',
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 1),
                    animationDuration: const Duration(milliseconds: 400),
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(10),
                    shouldIconPulse: true,
                    icon: const Icon(Icons.info_outline),
                  );
              },
              maxLength: 4,
            ),
          ],
        ),
      ),
    );
  }
}

