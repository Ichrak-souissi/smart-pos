import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/authentication/widgets/number_buttom.dart';
import '../controllers/pin_controller.dart';
import '../widgets/pin_code_field.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({Key? key}) : super(key: key);

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  String pin = "";
  String selectedRole = "";
  bool isForgotPin = false;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    loadData();
  }

  Future loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  void _toggleForgotPin() {
    setState(() {
      isForgotPin = !isForgotPin;
    });

    if (isForgotPin) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PinController controller = Get.put(PinController());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 238, 216),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  height: 70,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _buildRoleAvatar(
                          'Administrateur', 'assets/images/admin.png'),
                      const SizedBox(width: 10),
                      _buildRoleAvatar(
                          'Chef de Cuisine', 'assets/images/chef.png'),
                      const SizedBox(width: 10),
                      _buildRoleAvatar('Serveur', 'assets/images/waiter.png'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Bienvenue!',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Align(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: _buildAnimatedContent(controller),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedContent(PinController controller) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * 3.1416;
        final transform = Matrix4.identity()..rotateY(angle);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: isForgotPin
              ? _buildForgotPinForm()
              : _buildPinEntryForm(controller),
        );
      },
    );
  }

  Widget _buildRoleAvatar(String role, String imagePath) {
    bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Column(
        children: [
          Container(
            width: 70.0,
            height: 70.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.green : Colors.transparent,
                width: 2.0,
              ),
            ),
            child: Center(
              child: CircleAvatar(
                radius: 35.0,
                backgroundImage: AssetImage(imagePath),
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            role,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinEntryForm(PinController controller) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 400,
        maxHeight: 520,
      ),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Entrez votre code PIN!',
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 4; i++)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 5),
                      child: PinCodeField(
                        key: Key('pinField$i'),
                        pin: pin,
                        pinCodeFieldIndex: i,
                        onChanged: (String value) {
                          setState(() {
                            if (value.length == 1) {
                              pin = pin.length < 4 ? pin + value : pin;
                            } else if (value.isEmpty) {
                              pin = pin.isNotEmpty
                                  ? pin.substring(0, pin.length - 1)
                                  : pin;
                            }
                          });
                        },
                        theme: PinThemeData(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                for (int row = 0; row < 3; row++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int col = 1; col <= 3; col++)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: NumberButton(
                            number: row * 3 + col,
                            onPressed: () {
                              setState(() {
                                if (pin.length < 4) {
                                  pin += (row * 3 + col).toString();
                                }
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await controller.sendPin(pin);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(23),
                        elevation: 3,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 25,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 15),
                    NumberButton(
                      number: 0,
                      onPressed: () {
                        setState(() {
                          if (pin.length < 4) {
                            pin += '0';
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (pin.isNotEmpty) {
                            pin = pin.substring(0, pin.length - 1);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(23),
                        elevation: 3,
                      ),
                      child: const Icon(
                        Icons.backspace,
                        size: 25,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Code PIN oublié ?",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPinForm() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 400,
        maxHeight: 400,
      ),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Réinitialiser votre PIN',
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),
          const Text(
            'Entrez votre adresse email pour réinitialiser votre PIN.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'Adresse email',
              border: OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}
