import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Carga la pantalla principal de la app

// Importaciones para configurar la base de datos en diferentes sistemas
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io'; // Para saber en qué sistema operativo estamos

// Importación para guardar y cargar preferencias localmente
import 'package:shared_preferences/shared_preferences.dart';

// Aquí comienza la app
void main() async { // main ahora es async porque necesitamos esperar al cargar preferencias
  // Asegura que los bindings de Flutter estén inicializados.
  WidgetsFlutterBinding.ensureInitialized();

  // Si la app corre en una computadora (no en un teléfono),
  // configura la base de datos para que funcione ahí
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inicia la app mostrando el widget MyApp
  runApp(MyApp()); // MyApp sigue siendo un StatefulWidget
}

// El widget principal que define la estructura base de la aplicación
// Es un StatefulWidget para poder cambiar el tema y guardarlo
class MyApp extends StatefulWidget {
  // Constructor básico
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

// El estado de la aplicación principal, maneja si está en modo oscuro o no
class _MyAppState extends State<MyApp> {
  // Variable para saber si el modo oscuro está activado.
  // Inicialmente es falso, pero se cargará la preferencia guardada.
  bool _isDarkMode = false;

  // Se llama cuando el widget se crea. Aquí cargaremos la preferencia guardada.
  @override
  void initState() {
    super.initState();
    _loadThemePreference(); // Llama a la función para cargar la preferencia al iniciar
  }

  // Carga la preferencia de tema guardada localmente
  Future<void> _loadThemePreference() async {
    // Obtiene una instancia de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Lee el valor booleano guardado con la clave 'isDarkMode'.
    // Si no hay nada guardado, usa falso como valor por defecto.
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;

    // Actualiza el estado de la aplicación con la preferencia cargada
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  // Función para cambiar entre modo claro y oscuro y guardar la preferencia
  void _toggleTheme() async {
    // Obtiene una instancia de SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Actualiza el estado y redibuja la interfaz
    setState(() {
      _isDarkMode = !_isDarkMode; // Cambia al estado opuesto
    });

    // Guarda el nuevo estado del modo oscuro localmente
    prefs.setBool('isDarkMode', _isDarkMode);
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
