import 'package:flutter/material.dart';

// Pantalla de bienvenida que se muestra solo la primera vez que se abre la app.
class WelcomeScreen extends StatelessWidget {
  // Función que se llama cuando el usuario termina la bienvenida
  final VoidCallback onWelcomeComplete;

  const WelcomeScreen({super.key, required this.onWelcomeComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet, // Icono grande para la bienvenida
                size: 100.0,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24.0),
              const Text(
                '¡Bienvenido a Gestor de Gastos 170!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Tu asistente personal para llevar un control fácil y eficiente de tus finanzas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48.0),
              ElevatedButton(
                onPressed: onWelcomeComplete, // Llama a la función para marcar como completada
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Comenzar',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
