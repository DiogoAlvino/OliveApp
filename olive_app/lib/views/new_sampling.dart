import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:olive_app/views/results.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewSamplingScreen extends StatefulWidget {
  const NewSamplingScreen({super.key});

  @override
  _NewSamplingScreenState createState() => _NewSamplingScreenState();
}

class _NewSamplingScreenState extends State<NewSamplingScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nomeLoteController = TextEditingController();
  final TextEditingController _numAmostrasController = TextEditingController();
  final TextEditingController _informacoesController = TextEditingController();
  List<XFile> _selectedImages = [];
  Map<String, dynamic>? _classificationResult;
  List<Map<String, dynamic>> colorPatterns = [];
  String? selectedColorPatternName;

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

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      } else {
        print("Nenhuma imagem selecionada.");
      }
    } catch (e) {
      print("Erro ao selecionar imagens: $e");
    }
  }

  Future<void> _classifyImages() async {
    if (_selectedImages.isEmpty) return;

    if (selectedColorPatternName == null) {
      _showAlertDialog('Erro', 'Por favor, selecione um padrão de cor antes de iniciar.');
      return;
    }

    try {
      List<String> base64Images = await Future.wait(_selectedImages.map((image) async {
        return await _convertToBase64(image);
      }));

      var ipAPI = '/process';

      var response = await http.post(
        Uri.parse(ipAPI),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'images': base64Images}),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        setState(() {
          _classificationResult = result['classification'];
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassificationResultScreen(
              result: {
                'lote': _nomeLoteController.text,
                'informacoes': _informacoesController.text,
                'padraoDeCor': selectedColorPatternName ?? 'N/A',
                'classes': result['classification']['classes'] ?? [],
                'percentAmostras': result['classification']['percentAmostras'] ?? [],
                'totalAmostras': result['classification']['totalAmostras']?.toString() ?? 'N/A',
                'indiceMaturacao': result['classification']['indiceMaturacao']?.toString() ?? 'N/A',
              },
              showSaveAndNewSampling: true,
            ),
          ),
        );
      } else {
        print("Erro na API: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro ao classificar as imagens: $e");
    }
  }

  Future<String> _convertToBase64(XFile image) async {
    File file = File(image.path);
    List<int> imageBytes = await file.readAsBytes();
    return base64Encode(imageBytes);
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nomeLoteController.dispose();
    _numAmostrasController.dispose();
    _informacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Nova Amostragem',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _nomeLoteController,
                        decoration: InputDecoration(
                          labelText: 'Nome do lote',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _numAmostrasController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Nº de amostras',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Padrão de cor',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: selectedColorPatternName,
                        items: colorPatterns.map((pattern) {
                          return DropdownMenuItem<String>(
                            value: pattern['name'],
                            child: Text(pattern['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedColorPatternName = value;
                          });
                        },
                        hint: Text(colorPatterns.isEmpty ? 'Nenhum padrão de cor cadastrado' : 'Selecione um padrão de cor'),
                        disabledHint: Text('Nenhum padrão de cor cadastrado'),
                        isExpanded: true,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _informacoesController,
                        decoration: InputDecoration(
                          labelText: 'Informações',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.photo_library, color: Colors.white),
                              tooltip: 'Selecionar Imagens',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Quantidade de imagens: ${_selectedImages.length}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_selectedImages.isNotEmpty)
                        Container(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_selectedImages[index].name),
                                trailing: IconButton(
                                  icon: Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeImage(index),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: colorPatterns.isEmpty ? null : _classifyImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Iniciar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
