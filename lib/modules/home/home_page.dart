import 'package:flutter/material.dart';
import '../../shared/widgets/drawer_menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Compras')),
      drawer: const DrawerMenu(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              Text(
                'Bem-vindo ao Lista de Compras 🛒',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Organize suas compras de forma simples e eficiente.\nUse o menu lateral ou clique abaixo para começar!',
                style: TextStyle(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Criar nova lista'),
                onPressed: () => Navigator.pushNamed(context, '/shopping-list'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.calculate),
                label: const Text('Ir para a calculadora'),
                onPressed: () => Navigator.pushNamed(context, '/calculator'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
