import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/authentication/widgets/shimmer.dart';

import '../controllers/pin_controller.dart';
import '../widgets/Pin_code_field.dart';
import '../widgets/number_buttom.dart';


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
          child: showShimmer ? ShimmerCodePin(
            child: Column(
              key: const ValueKey('pin_screen'),
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Taper votre  code Pin !',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 1; i <= 3; i++)
                          NumberButton(
                            number: i,
                            onPressed: () {
                              setState(() {
                                pin += i.toString();
                              });
                            },
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 4; i <= 6; i++)
                          NumberButton(
                            number: i,
                            onPressed: () {
                              setState(() {
                                pin += i.toString();
                              });
                            },
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 7; i <= 9; i++)
                          NumberButton(
                            number: i,
                            onPressed: () {
                              setState(() {
                                pin += i.toString();
                              });
                            },
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                           await controller.sendPin(pin);
                          },
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                            size: 60,
                          ),
                        ),
                        const SizedBox(width: 10),
                        NumberButton(
                          number: 0,
                          onPressed: () {
                            setState(() {
                              pin += '0';
                            });
                          },
                        ),
                        CupertinoButton(
                          onPressed: () {
                            setState(() {
                              if (pin.isNotEmpty) {
                                pin = pin.substring(0, pin.length - 1);
                              }
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Center(
                              child: Text(
                                '⌫',
                                style: TextStyle(fontSize: 25, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ) : Column(
            key: const ValueKey('pin_screen'),
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Taper votre  code Pin !',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 1; i <= 3; i++)
                        NumberButton(
                          number: i,
                          onPressed: () {
                            setState(() {
                              pin += i.toString();
                            });
                          },
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 4; i <= 6; i++)
                        NumberButton(
                          number: i,
                          onPressed: () {
                            setState(() {
                              pin += i.toString();
                            });
                          },
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 7; i <= 9; i++)
                        NumberButton(
                          number: i,
                          onPressed: () {
                            setState(() {
                              pin += i.toString();
                            });
                          },
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: ()  {
                          controller.sendPin(pin);
                        },
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 60,
                        ),
                      ),
                      const SizedBox(width: 10),
                      NumberButton(
                        number: 0,
                        onPressed: () {
                          setState(() {
                            pin += '0';
                          });
                        },
                      ),
                      CupertinoButton(
                        onPressed: () {
                          setState(() {
                            if (pin.isNotEmpty) {
                              pin = pin.substring(0, pin.length - 1);
                            }
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Center(
                            child: Text(
                              '⌫',
                              style: TextStyle(fontSize: 25, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
