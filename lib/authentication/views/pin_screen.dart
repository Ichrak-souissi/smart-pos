import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/app_theme.dart';
import 'package:pos/authentication/widgets/number_buttom.dart';
import 'package:pos/authentication/widgets/shimmer.dart';

import '../controllers/pin_controller.dart';
import '../widgets/pin_code_field.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({Key? key}) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String pin = "";
  bool showShimmer = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      showShimmer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final PinController controller = Get.put(PinController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: showShimmer
              ? ShimmerCodePin(
                  child: _buildPinScreenContent(controller),
                )
              : _buildPinScreenContent(controller),
        ),
      ),
    );
  }

  Widget _buildPinScreenContent(PinController controller) {
    return Column(
      key: const ValueKey('pin_screen'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Taper votre code Pin !',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 4; i++)
              PinCodeField(
                key: Key('pinField$i'),
                pin: pin,
                pinCodeFieldIndex: i,
                onChanged: (String value) {},
                theme: PinThemeData(),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            for (int row = 0; row < 3; row++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int col = 1; col <= 3; col++)
                    NumberButton(
                      number: row * 3 + col,
                      onPressed: () {
                        setState(() {
                          pin += (row * 3 + col).toString();
                        });
                      },
                    ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: GestureDetector(
                    onTap: () async {
                      await controller.sendPin(pin);
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 19),
                NumberButton(
                  number: 0,
                  onPressed: () {
                    setState(() {
                      pin += '0';
                    });
                  },
                ),
                //  const SizedBox(width: 5),
                CupertinoButton(
                  onPressed: () {
                    setState(() {
                      if (pin.isNotEmpty) {
                        pin = pin.substring(0, pin.length - 1);
                      }
                    });
                  },
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.backspace,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
