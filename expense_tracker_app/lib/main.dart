import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importa la pantalla de inicio

// Importaciones necesarias para la inicialización de la base de datos
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io'; // Necesario para Platform

void main() {
  // Asegura que los bindings de Flutter estén inicializados.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la fábrica de base de datos según la plataforma.
  // Esto es crucial para que sqflite funcione correctamente en diferentes entornos,
  // especialmente en escritorio o ciertos emuladores/configuraciones de prueba.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Usa la fábrica FFI (Foreign Function Interface) para plataformas de escritorio.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp()); // Ejecuta la aplicación
}

// Widget principal de la aplicación.
class MyApp extends StatelessWidget {
  // Usando la sintaxis de super parameter para el key
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Gastos', // Título de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema de color principal
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // La pantalla de inicio es la primera que se muestra
      debugShowCheckedModeBanner: false, // Oculta el banner de debug
    );
  }
}

