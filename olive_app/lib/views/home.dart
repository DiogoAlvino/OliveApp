import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:olive_app/views/new_sampling.dart';

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
            Container(
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
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMenuButton(
                    context,
                    icon: Icons.add,
                    label: 'Nova Amostragem',
                    route: const NewSamplingScreen(),
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.bar_chart,
                    label: 'Resultados',
                    route: null,
                  ),
                  _buildMenuButton(
                    context,
                    icon: Icons.settings,
                    label: 'Configurações',
                    route: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required IconData icon, required String label, Widget? route}) {
    return InkWell(
      onTap: route != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => route),
              );
            }
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Colors.green.shade500),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(color: Colors.green.shade500),
          ),
        ],
      ),
    );
  }
}
