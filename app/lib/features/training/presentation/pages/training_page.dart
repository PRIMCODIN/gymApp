import 'package:flutter/material.dart';

/// Pantalla de Entreno. Esqueleto vacío por ahora: solo título centrado.
/// La funcionalidad (registro de ejercicio) llega en fases futuras.
class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entreno')),
      body: Center(
        child: Text('Entreno', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
