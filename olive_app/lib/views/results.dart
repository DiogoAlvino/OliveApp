import 'package:flutter/material.dart';

class ClassificationResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ClassificationResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Obter classes e percentagens, ou usar listas vazias como padrão
    List<dynamic> classes = result['classes'] ?? [];
    List<dynamic> percentAmostras = result['percentAmostras'] ?? [];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Resultado da Classificação',
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
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Exibir o lote
                    _buildResultItem('Lote', result['lote'] ?? 'N/A'),
                    const SizedBox(height: 10),

                    // Exibir as informações adicionais
                    _buildResultItem('Informações', result['informacoes'] ?? 'N/A'),
                    const SizedBox(height: 10),

                    // Exibir o padrão de cor
                    _buildResultItem('Padrão de cor', result['padraoDeCor'] ?? 'N/A'),
                    const SizedBox(height: 10),

                    // Exibir a classificação em classes de maturação
                    const Text(
                      'Classes de Maturação:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    ..._buildClasses(classes, percentAmostras),
                    const SizedBox(height: 20),

                    // Exibir o modelo preditivo usado
                    _buildResultItem('Modelo preditivo', result['modeloPred'] ?? 'N/A'),
                    const SizedBox(height: 10),

                    // Exibir o total de amostras processadas
                    _buildResultItem('Total de Amostras', result['totalAmostras']?.toString() ?? 'N/A'),
                    const SizedBox(height: 10),

                    // Exibir o índice de maturação
                    _buildResultItem('Índice de Maturação', result['indiceMaturacao']?.toString() ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Botão "Realizar Nova Amostragem"
              ElevatedButton(
                onPressed: () {
                  // Navegar para a tela de Nova Amostragem
                  Navigator.pushNamed(context, '/new_sampling');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Realizar Nova Amostragem', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              // Botão "Ir para o Menu"
              ElevatedButton(
                onPressed: () {
                  // Navegar para o Menu (Tela Principal)
                  Navigator.pushNamed(context, '/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Ir para o Menu', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para exibir uma linha de resultado
  Widget _buildResultItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  // Função para criar widgets de exibição das classes e porcentagens
  List<Widget> _buildClasses(List<dynamic> classes, List<dynamic> percentages) {
    List<Widget> widgets = [];
    for (int i = 0; i < classes.length; i++) {
      widgets.add(
        Row(
          children: [
            Text(
              'N${i + 1}: ${percentages[i]}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
    return widgets;
  }
}