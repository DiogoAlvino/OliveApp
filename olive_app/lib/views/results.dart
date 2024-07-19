import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

class ClassificationResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final bool showSaveAndNewSampling;

  const ClassificationResultScreen({super.key, required this.result, this.showSaveAndNewSampling = true});

  @override
  _ClassificationResultScreenState createState() => _ClassificationResultScreenState();
}

class _ClassificationResultScreenState extends State<ClassificationResultScreen> {
  bool isResultSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfResultIsSaved();
  }

  Future<void> _checkIfResultIsSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedResults = prefs.getStringList('savedResults') ?? [];
    String currentResult = jsonEncode(widget.result);

    if (savedResults.contains(currentResult)) {
      setState(() {
        isResultSaved = true;
      });
    }
  }

  Future<void> _saveResult(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedResults = prefs.getStringList('savedResults') ?? [];
    savedResults.add(jsonEncode(widget.result));
    await prefs.setStringList('savedResults', savedResults);

    setState(() {
      isResultSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resultado salvo com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obter classes e percentagens, ou usar listas vazias como padrão
    List<dynamic> classes = widget.result['classes'] ?? [];
    List<dynamic> percentAmostras = widget.result['percentAmostras'] ?? [];
    int totalAmostras = int.tryParse(widget.result['totalAmostras'].toString()) ?? 0;

    // Calcular quantidade de azeitonas para cada classe com base no percentual
    List<int> quantidadeAzeitonas = [];
    for (int i = 0; i < percentAmostras.length; i++) {
      quantidadeAzeitonas.add((percentAmostras[i] * totalAmostras / 100).round());
    }

    // Dados para o gráfico de barras
    List<ChartData> chartData = [];
    for (int i = 0; i < classes.length; i++) {
      chartData.add(ChartData('C${i + 1}', percentAmostras[i].toDouble()));
    }

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
      body: Stack(
        children: [
          Container(
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
                        _buildResultItem('Lote', widget.result['lote'] ?? 'N/A'),
                        const SizedBox(height: 10),

                        // Exibir as informações adicionais
                        _buildResultItem('Informações', widget.result['informacoes'] ?? 'N/A'),
                        const SizedBox(height: 10),

                        // Exibir o padrão de cor
                        _buildResultItem('Padrão de cor', widget.result['padraoDeCor'] ?? 'N/A'),
                        const SizedBox(height: 10),

                        // Exibir o total de amostras processadas
                        _buildResultItem('Total de Amostras', widget.result['totalAmostras']?.toString() ?? 'N/A'),
                        const SizedBox(height: 10),

                        // Exibir o índice de maturação
                        _buildResultItem('Índice de Maturação', widget.result['indiceMaturacao']?.toString() ?? 'N/A'),
                        const SizedBox(height: 20),

                        // Exibir a classificação em classes de maturação
                        const Text(
                          'Classes de Maturação:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        _buildClassesTable(classes, percentAmostras, quantidadeAzeitonas),
                        const SizedBox(height: 20),

                        const Text(
                          'Gráfico:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),

                        // Adicionar gráfico de barras
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(8.0),
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            series: <ChartSeries>[
                              ColumnSeries<ChartData, String>(
                                dataSource: chartData,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.y,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (widget.showSaveAndNewSampling) ...[
                        Expanded(
                          child: ElevatedButton(
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
                              textStyle: const TextStyle(fontSize: 11),
                            ),
                            child: const Text('Realizar Nova Amostragem', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
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
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text('Ir para o Menu', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                      if (!widget.showSaveAndNewSampling)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navegar para a Lista de Resultados
                              Navigator.pushNamed(context, '/result_list');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 10,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text('Voltar para a Lista', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (widget.showSaveAndNewSampling && !isResultSaved)
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () => _saveResult(context),
                icon: const Icon(Icons.download, color: Colors.green),
                iconSize: 30,
                tooltip: 'Salvar Resultado',
              ),
            ),
        ],
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

  // Função para criar widgets de exibição das classes e porcentagens em forma de tabela
  Widget _buildClassesTable(List<dynamic> classes, List<dynamic> percentages, List<int> quantities) {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Classe', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Imagem', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Percentual', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Quantidade', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ],
        ),
        for (int i = 0; i < classes.length; i++)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Classe ${i + 1}', textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Image.asset(
                    'lib/assets/classes/classe${i + 1}.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${percentages[i]}%', textAlign: TextAlign.center),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${quantities[i]}', textAlign: TextAlign.center),
              ),
            ],
          ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
