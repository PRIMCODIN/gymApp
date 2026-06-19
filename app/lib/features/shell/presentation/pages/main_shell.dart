import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../nutrition/presentation/pages/nutrition_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../training/presentation/pages/training_page.dart';

/// Contenedor de navegación principal: se muestra cuando hay sesión activa.
///
/// El índice de la pestaña seleccionada es estado de UI puramente local y efímero
/// del shell (no estado de negocio), así que vive en un `StatefulWidget` con
/// `setState`, no en Riverpod (reservado para estado de negocio/asíncrono según
/// `specs/conventions.md`). Un `IndexedStack` mantiene vivas las cuatro pantallas
/// y preserva su estado al cambiar de pestaña.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // Orden de las pestañas (izquierda → derecha): Inicio, Entreno, Nutrición, Perfil.
  static const List<Widget> _pages = [
    HomePage(),
    TrainingPage(),
    NutritionPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = context.palette;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.onSurface,
        unselectedItemColor: palette.textSecondary,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            label: 'Entreno',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            label: 'Nutrición',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
