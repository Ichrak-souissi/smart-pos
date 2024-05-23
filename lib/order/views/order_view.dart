import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 8,
              fit: FlexFit.tight,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bienvenue',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                          });
                                        },
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 30,
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade500,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Center(
                                              child: Icon(Icons.search, color: Colors.white, size: 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          hintText: 'Rechercher',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        onChanged: (value) {
                                          value.trim();
                                          setState(() {
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PopupMenuButton<String>(
                              icon: const FaIcon(
                                FontAwesomeIcons.sliders,
                                color: Colors.black38,
                                size: 20,
                              ),
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'price',
                                  child: Text('Filtrer par prix'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'alphabet',
                                  child: Text('de A à Z'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'creationDate',
                                  child: Text('Les plus récents'),
                                ),
                              ],
                              onSelected: (String value) {
                                switch (value) {
                                  case 'price':
                                    break;
                                  case 'alphabet':
                                    break;
                                  case 'creationDate':
                                    break;
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
              ),
          
            ),
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: Container(), 
            ),
          ],
        ),
      ),
    );
  }
}
