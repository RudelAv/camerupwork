import 'package:flutter/material.dart';

class CitySelector extends StatefulWidget {
  @override
  _CitySelectorState createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  String _selectedCity = 'Paris'; // Ville sélectionnée par défaut

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sélectionnez une ville',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        DropdownButton<String>(
          value: _selectedCity,
          onChanged: (newValue) {
            setState(() {
              _selectedCity = newValue!;
            });
          },
          items: [
            'Paris',
            'Lyon',
            'Marseille',
            'Lille',
            'Toulouse',
            'Nice',
            'Nantes',
            'Strasbourg',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
