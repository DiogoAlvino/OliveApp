import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:olive_app/views/configurations.dart';
import 'package:olive_app/views/new_sampling.dart';
import 'package:olive_app/views/results_list.dart';
import 'package:olive_app/widgets/custom_bottom_menu.dart';
import 'package:olive_app/widgets/menu_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            Lottie.asset(
              'lib/assets/animation.json',
              height: 400,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'Erro ao carregar a animação',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Bem-vindo ao Olive App!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Aqui você pode gerenciar as suas amostras com facilidade!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            CustomBottomMenu(
              selectedIndex: 0,
              items: [
                MenuItem(icon: Icons.bar_chart, label: 'Resultados', route: const ResultListScreen()),
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
