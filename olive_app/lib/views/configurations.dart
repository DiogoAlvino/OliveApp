import 'package:flutter/material.dart';
import 'package:olive_app/views/edit_pattern.dart';
import 'package:olive_app/views/home.dart';
import 'package:olive_app/views/results_list.dart';
import 'package:olive_app/widgets/custom_bottom_menu.dart';
import 'package:olive_app/widgets/menu_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ConfigurationsScreen extends StatefulWidget {
  const ConfigurationsScreen({super.key});

  @override
  _ConfigurationsScreenState createState() => _ConfigurationsScreenState();
}

class _ConfigurationsScreenState extends State<ConfigurationsScreen> {
  List<Map<String, dynamic>> colorPatterns = [];

  @override
  void initState() {
    super.initState();
    _loadColorPatterns();
  }

  Future<void> _loadColorPatterns() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedPatterns = prefs.getStringList('colorPatterns');

    if (savedPatterns != null) {
      setState(() {
        colorPatterns = savedPatterns
            .map((pattern) => Map<String, dynamic>.from(jsonDecode(pattern)))
            .toList();
      });
    }
  }

  Future<void> _saveColorPatterns() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedPatterns =
        colorPatterns.map((pattern) => jsonEncode(pattern)).toList();
    await prefs.setStringList('colorPatterns', savedPatterns);
  }

  Future<void> _deleteColorPattern(int index) async {
    setState(() {
      colorPatterns.removeAt(index);
    });
    _saveColorPatterns();
  }

  void _navigateToEditPattern({Map<String, dynamic>? pattern, int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPatternScreen(
          pattern: pattern ??
              {
                'name': '',
                'colors': [
                  {'name': 'Verde escuro', 'r': 0, 'g': 128, 'b': 0},
                  {'name': 'Verde claro', 'r': 144, 'g': 238, 'b': 144},
                  {'name': 'Violeta escuro', 'r': 148, 'g': 0, 'b': 211},
                  {'name': 'Violeta claro', 'r': 238, 'g': 130, 'b': 238},
                  {'name': 'Branco', 'r': 255, 'g': 255, 'b': 255},
                ],
              },
          onSave: (updatedPattern) {
            setState(() {
              if (index != null) {
                colorPatterns[index] = updatedPattern;
              } else {
                colorPatterns.add(updatedPattern);
              }
            });
            _saveColorPatterns();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Configurações',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.green.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30.0),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: colorPatterns.isEmpty
                  ? const Center(
                      child: Text('Nenhum padrão cadastrado.'),
                    )
                  : ListView.builder(
                      itemCount: colorPatterns.length,
                      itemBuilder: (context, index) {
                        final pattern = colorPatterns[index];
                        return Dismissible(
                          key: Key(pattern['name'] ?? index.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _deleteColorPattern(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('${pattern['name']} deletado')),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                pattern['name'] ?? 'Sem nome',
                                style: const TextStyle(fontSize: 18),
                              ),
                              trailing: const Icon(Icons.edit, color: Colors.green),
                              onTap: () => _navigateToEditPattern(
                                  pattern: pattern, index: index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            CustomBottomMenu(
              selectedIndex: 2,
              items: [
                MenuItem(icon: Icons.home, label: 'Menu', route: const HomeScreen()),
                MenuItem(icon: Icons.add,label: 'Adicionar Padrão',route: () => _navigateToEditPattern(),),
                MenuItem(icon: Icons.bar_chart,label: 'Resultados',route: const ResultListScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
