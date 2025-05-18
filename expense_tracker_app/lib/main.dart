import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importa la pantalla principal de la aplicación

// Importaciones para configurar la base de datos en diferentes sistemas
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io'; // Permite identificar el sistema operativo

// La función principal donde empieza la ejecución de la aplicación
void main() {
  // Asegura que Flutter esté listo antes de inicializar cosas importantes
  WidgetsFlutterBinding.ensureInitialized();

  // Verifica si la aplicación se ejecuta en una computadora (Windows, Linux, macOS)
  // Si es así, configura la base de datos de una manera especial para que funcione
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Inicializa la configuración específica para bases de datos en computadoras
    sqfliteFfiInit();
    // Establece cómo se crearán y abrirán las bases de datos en este entorno
    databaseFactory = databaseFactoryFfi;
  }

  // Ejecuta la aplicación principal (el widget MyApp)
  runApp(const MyApp());
}

// El widget principal que define la estructura base de la aplicación
class MyApp extends StatelessWidget {
  // Constructor del widget, usa la clave estándar de Flutter
  const MyApp({super.key});

  // Este método construye la interfaz visual de la aplicación
  @override
  Widget build(BuildContext context) {
    // MaterialApp configura la apariencia general de la app al estilo Material Design de Android
    return MaterialApp(
      title: 'Control de Gastos', // El título que aparece en la barra de tareas del sistema
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define el color principal de la aplicación
        visualDensity: VisualDensity.adaptivePlatformDensity, // Ajusta la densidad visual según la plataforma
      ),
      home: const HomeScreen(), // La pantalla que se muestra primero al abrir la app
      debugShowCheckedModeBanner: false, // Oculta una etiqueta de "Debug" en la esquina
    );
  }
}
