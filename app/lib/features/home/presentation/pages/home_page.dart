import 'package:flutter/material.dart';

/// Pantalla de Inicio. Esqueleto vacío por ahora: solo título centrado.
/// La funcionalidad (resumen del día, calorías, etc.) llega en fases futuras.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(
        child: Text('Inicio', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
