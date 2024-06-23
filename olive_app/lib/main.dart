import 'package:flutter/material.dart';
import 'package:olive_app/views/new_sampling.dart';
import 'views/home.dart'; // Importa a tela principal

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Olive App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Rawline',
        textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'Rawline',
            ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/new_sampling': (context) => const NewSamplingScreen(),
      },
    );
  }
}