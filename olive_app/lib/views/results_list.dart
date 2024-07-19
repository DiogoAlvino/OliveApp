import 'package:flutter/material.dart';
import 'package:olive_app/views/configurations.dart';
import 'package:olive_app/views/home.dart';
import 'package:olive_app/views/new_sampling.dart';
import 'package:olive_app/views/results.dart';
import 'package:olive_app/widgets/custom_bottom_menu.dart';
import 'package:olive_app/widgets/menu_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ResultListScreen extends StatefulWidget {
  const ResultListScreen({super.key});

  @override
  _ResultListScreenState createState() => _ResultListScreenState();
}

class _ResultListScreenState extends State<ResultListScreen> {
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedResults = prefs.getStringList('savedResults');

    if (savedResults != null) {
      setState(() {
        results = savedResults.map((result) => Map<String, dynamic>.from(jsonDecode(result))).toList();
      });
    }
  }

  Future<void> _deleteResult(int index) async {
    final prefs = await SharedPreferences.getInstance();
    results.removeAt(index);
    final List<String> savedResults = results.map((result) => jsonEncode(result)).toList();
    await prefs.setStringList('savedResults', savedResults);
    setState(() {});
  }

  void _navigateToResult(Map<String, dynamic> result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassificationResultScreen(
          result: result,
          showSaveAndNewSampling: false,
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
            Icon(Icons.bar_chart, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Resultados Salvos',
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
              child: results.isEmpty
                  ? const Center(
                      child: Text('Nenhum resultado salvo.'),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return Dismissible(
                          key: Key(result['lote'] ?? index.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _deleteResult(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${result['lote']} deletado')),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                result['lote'] ?? 'Sem nome',
                                style: const TextStyle(fontSize: 18),
                              ),
                              trailing: const Icon(Icons.arrow_forward, color: Colors.green),
                              onTap: () => _navigateToResult(result),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            CustomBottomMenu(
              selectedIndex: 0,
              items: [
                MenuItem(icon: Icons.home, label: 'Menu', route: const HomeScreen()),
                MenuItem(icon: Icons.add, label: 'Nova Amostragem', route: const NewSamplingScreen()),
                MenuItem(icon: Icons.settings, label: 'Configurações', route: const ConfigurationsScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
