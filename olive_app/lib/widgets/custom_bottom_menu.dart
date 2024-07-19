import 'package:flutter/material.dart';
import 'package:olive_app/widgets/menu_item.dart';

class CustomBottomMenu extends StatelessWidget {
  final int selectedIndex;
  final List<MenuItem> items;

  const CustomBottomMenu({super.key, required this.selectedIndex, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, -2),
            blurRadius: 8.0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          MenuItem item = entry.value;
          return _buildMenuButton(context, item: item, index: index);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required MenuItem item, required int index}) {
    Color color = Colors.green.shade700;
    return InkWell(
      onTap: () {
        if (item.route is Widget) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.route as Widget),
          );
        } else if (item.route is Function) {
          (item.route as Function)();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 30, color: color),
          const SizedBox(height: 5),
          Text(
            item.label,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}
