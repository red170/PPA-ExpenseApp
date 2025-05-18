import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Carga la pantalla principal de la app

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io'; // Para saber en qué sistema operativo estamos

// Aquí comienza la app
void main() {
  // Asegura que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();

  // Si la app corre en una computadora (no en un teléfono),
  // configura la base de datos para que funcione ahí
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inicia la app mostrando el widget MyApp
  runApp(MyApp()); // Ahora MyApp es un StatefulWidget, no necesita 'const' aquí
}

// El widget principal que define la estructura base de la aplicación
// Ahora es un StatefulWidget para poder cambiar el tema
class MyApp extends StatefulWidget {
  // Constructor básico
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

// El estado de la aplicación principal, maneja si está en modo oscuro o no
class _MyAppState extends State<MyApp> {
  // Variable para saber si el modo oscuro está activado. Empieza en falso (modo claro).
  bool _isDarkMode = false;

  // Función para cambiar entre modo claro y oscuro
  void _toggleTheme() {
    // Actualiza el estado y redibuja la interfaz
    setState(() {
      _isDarkMode = !_isDarkMode; // Cambia al estado opuesto
    });
  }

  // Dibuja la interfaz de la app
  @override
  Widget build(BuildContext context) {
    // MaterialApp configura la apariencia general de la app al estilo Material Design de Android
    return MaterialApp(
      title: 'Control de Gastos', // Título que se ve en el sistema
      // Define el tema claro
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light, // Tema claro
      ),
      // Define el tema oscuro
      darkTheme: ThemeData(
        primarySwatch: Colors.blueGrey, // Puedes usar otro color primario para el modo oscuro si quieres
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark, // Tema oscuro
        // Puedes personalizar más colores aquí para el modo oscuro
        // Por ejemplo:
        // cardColor: Colors.grey[850],
        // scaffoldBackgroundColor: Colors.black,
        // appBarTheme: AppBarTheme(backgroundColor: Colors.grey[900]),
      ),
      // Controla qué tema usar basado en la variable _isDarkMode
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // La pantalla inicial, le pasamos la función para cambiar el tema
      home: HomeScreen(toggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false, // Oculta una etiqueta de prueba
    );
  }
}