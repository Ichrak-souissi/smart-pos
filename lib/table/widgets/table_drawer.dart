import 'package:flutter/material.dart';

class TableDrawer extends StatelessWidget {
  const TableDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Passer une réservation'),
            onTap: () {
              // Ajoutez ici la logique pour passer une réservation
              Navigator.pop(context); // Ferme le drawer
            },
          ),
          ListTile(
            title: const Text('Afficher les plats'),
            onTap: () {
              // Ajoutez ici la logique pour afficher les plats de la table
              Navigator.pop(context); // Ferme le drawer
            },
          ),
        ],
      ),
    );
  }
}
