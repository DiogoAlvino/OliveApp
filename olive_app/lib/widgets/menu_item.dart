import 'package:flutter/material.dart';

class MenuItem {
  final IconData icon;
  final String label;
  final dynamic route; // Pode ser uma Widget ou uma função anônima

  MenuItem({required this.icon, required this.label, required this.route});
}
