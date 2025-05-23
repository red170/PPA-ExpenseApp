import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Carga la pantalla principal de la app
import 'screens/welcome_screen.dart'; // Importa la Pantalla de Bienvenida

// Importaciones para configurar la base de datos en diferentes sistemas
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io'; // Para saber en qué sistema operativo estamos

// Importación para guardar y cargar preferencias localmente
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Para soporte de idiomas

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

  runApp(const MyApp()); // MyApp sigue siendo un StatefulWidget
}

// El widget principal que define la estructura base de la aplicación
// Es un StatefulWidget para poder cambiar el tema y guardar preferencias
class MyApp extends StatefulWidget {
  // Constructor básico
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

// El estado de la aplicación principal, maneja si está en modo oscuro o no
class _MyAppState extends State<MyApp> {
  // Variable para saber si el modo oscuro está activado.
  bool _isDarkMode = false;
  // Símbolo de moneda seleccionado, por defecto '$'
  String _currencySymbol = '\$';
  // Variable para saber si la pantalla de bienvenida ya se mostró
  bool _showWelcomeScreen = true;

  // Se llama cuando el widget se crea. Aquí cargaremos las preferencias guardadas.
  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Llama a la función para cargar todas las preferencias
  }

  // Carga todas las preferencias guardadas localmente (tema, moneda, bienvenida)
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    final currencySymbol = prefs.getString('currencySymbol') ?? '\$'; // Carga el símbolo de moneda
    final showWelcome = prefs.getBool('showWelcomeScreen') ?? true; // Carga si mostrar bienvenida

    setState(() {
      _isDarkMode = isDarkMode;
      _currencySymbol = currencySymbol;
      _showWelcomeScreen = showWelcome;
    });
  }

  // Función para cambiar entre modo claro y oscuro y guardar la preferencia
  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Función para actualizar el símbolo de moneda y guardarlo
  void _updateCurrencySymbol(String newSymbol) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currencySymbol = newSymbol;
    });
    prefs.setString('currencySymbol', newSymbol);
  }

  // Función para marcar que la pantalla de bienvenida ya se mostró
  void _markWelcomeScreenShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWelcomeScreen', false);
    setState(() {
      _showWelcomeScreen = false;
    });
  }

  // Se eliminó la función _exportToCsv() y _showUserMessage() ya que no se necesitan.

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
      ),
      // Controla qué tema usar basado en la variable _isDarkMode
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Configuración de localización para idiomas (necesario para intl)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Inglés
        Locale('es', ''), // Español
        Locale('es', 'SV'), // Español de El Salvador (opcional, si quieres más específico)
      ],

      // La pantalla inicial: si es la primera vez, muestra la bienvenida; si no, la principal.
      home: _showWelcomeScreen
          ? WelcomeScreen(onWelcomeComplete: _markWelcomeScreenShown)
          : HomeScreen(
        toggleTheme: _toggleTheme,
        currentCurrencySymbol: _currencySymbol,
        onCurrencySymbolChanged: _updateCurrencySymbol,
      ),
      debugShowCheckedModeBanner: false, // Oculta una etiqueta de prueba
    );
  }
}
