import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditPatternScreen extends StatefulWidget {
  final Map<String, dynamic> pattern;
  final Function(Map<String, dynamic>) onSave;

  const EditPatternScreen({super.key, required this.pattern, required this.onSave});

  @override
  _EditPatternScreenState createState() => _EditPatternScreenState();
}

class _EditPatternScreenState extends State<EditPatternScreen> {
  late Map<String, dynamic> pattern;
  late List<Map<String, dynamic>> colors;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    pattern = Map<String, dynamic>.from(widget.pattern);
    colors = List<Map<String, dynamic>>.from(pattern['colors']);
    _nameController = TextEditingController(text: pattern['name']);
  }

  void _updateColor(int index, Color color) {
    setState(() {
      colors[index]['r'] = color.red;
      colors[index]['g'] = color.green;
      colors[index]['b'] = color.blue;
    });
  }

  void _savePattern() {
    widget.onSave({
      'name': _nameController.text,
      'colors': colors,
    });
    Navigator.pop(context);
  }

  void _showColorPickerDialog(int index) {
    Color currentColor = Color.fromRGBO(
      colors[index]['r'],
      colors[index]['g'],
      colors[index]['b'],
      1.0,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Definir ${colors[index]['name']}'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => _updateColor(index, color),
              enableAlpha: false,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 10,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Padrão de Cor', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nome do padrão',
                  border: OutlineInputBorder(),
                ),
                controller: _nameController,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    return ListTile(
                      title: Text(color['name'] as String),
                      trailing: Container(
                        width: 50,
                        height: 50,
                        color: Color.fromRGBO(color['r'], color['g'], color['b'], 1.0),
                      ),
                      onTap: () => _showColorPickerDialog(index),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _savePattern,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 10,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                    ),
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
