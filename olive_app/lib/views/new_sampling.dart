import 'dart:convert'; // Para conversão Base64
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:olive_app/views/results.dart';

class NewSamplingScreen extends StatefulWidget {
  const NewSamplingScreen({super.key});

  @override
  _NewSamplingScreenState createState() => _NewSamplingScreenState();
}

class _NewSamplingScreenState extends State<NewSamplingScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Map<String, dynamic>? _classificationResult;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      } else {
        print("Nenhuma imagem selecionada.");
      }
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
    }
  }

  Future<void> _classifyImage() async {
  if (_selectedImage == null) return;

  try {
    // Converter a imagem para Base64
    String base64Image = await _convertToBase64(_selectedImage!);

    // Enviar a imagem para a API
    var response = await http.post(
      Uri.parse('http://192.168.1.12:5000/process'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'images': [base64Image]}),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      setState(() {
        _classificationResult = result['classification'];
      });

      // Verifique se as chaves necessárias estão presentes e não nulas
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClassificationResultScreen(
            result: {
              'lote': 'Lote Teste 2',
              'informacoes': 'Segundo lote de teste',
              'padraoDeCor': 'Padrão 2',
              'classes': result['classification']['classes'] ?? [],
              'percentAmostras': result['classification']['percentAmostras'] ?? [],
              'modeloPred': 'Modelo 2',
              'totalAmostras': result['classification']['totalAmostras']?.toString() ?? 'N/A',
              'indiceMaturacao': result['classification']['indiceMaturacao']?.toString() ?? 'N/A',
            },
          ),
        ),
      );
    } else {
      print("Erro na API: ${response.statusCode}");
    }
  } catch (e) {
    print("Erro ao classificar a imagem: $e");
  }
}

  Future<String> _convertToBase64(XFile image) async {
    File file = File(image.path);
    List<int> imageBytes = await file.readAsBytes();
    return base64Encode(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      // Campo Nome do lote
                      TextField(
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
                      // Campo Nº de amostras
                      TextField(
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
                      // Campo Padrão de cor
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Padrão de cor',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Campo Modelo preditivo
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Modelo preditivo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Campo Informações
                      TextField(
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
                      // Botão para selecionar imagens
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        label: const Text(
                          'Selecionar Imagens',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 10,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Mostrar a imagem selecionada
                      if (_selectedImage != null)
                        Image.file(
                          File(_selectedImage!.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Botão Iniciar
              SizedBox(
                width: double.infinity, // Para preencher a largura total
                height: 50,
                child: ElevatedButton(
                  onPressed: _classifyImage, // Chamar a função de classificação ao iniciar
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
