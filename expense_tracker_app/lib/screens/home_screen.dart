import 'package:flutter/material.dart';
import '../models/expense.dart'; // Define cómo es un gasto
import '../database/database_helper.dart'; // Para manejar la base de datos
import 'add_edit_expense_screen.dart'; // La pantalla para añadir/editar gastos
import 'package:intl/intl.dart'; // Para dar formato a números y fechas
import 'add_edit_expense_screen.dart'; // Importa la pantalla para acceder a la lista de categorías
import '../models/budget.dart'; // Importa el modelo de presupuesto
import 'budget_management_screen.dart'; // Importa la pantalla de gestión de presupuestos
import 'summary_screen.dart'; // Importa la pantalla de resumen
// Se han eliminado las importaciones de 'csv', 'path_provider', 'dart:io', 'permission_handler', 'device_info_plus'

// Mapa para asociar categorías con iconos de Material Design
final Map<String, IconData> categoryIcons = {
  'Comida': Icons.fastfood,
  'Transporte': Icons.directions_bus,
  'Entretenimiento': Icons.movie,
  'Hogar': Icons.home,
  'Compras': Icons.shopping_cart,
  'Salud': Icons.medical_services,
  'Educación': Icons.school,
  'Viajes': Icons.flight,
  'Otros': Icons.category,
};


// Esta es la pantalla principal que muestra los gastos y el total
class HomeScreen extends StatefulWidget {
  // Función para cambiar el tema, recibida desde MyApp
  final VoidCallback toggleTheme;
  // Símbolo de moneda actual, recibido de MyApp
  final String currentCurrencySymbol;
  // Función para actualizar el símbolo de moneda, recibida de MyApp
  final ValueChanged<String> onCurrencySymbolChanged;


  // Constructor que recibe las funciones y el símbolo de moneda
  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.currentCurrencySymbol,
    required this.onCurrencySymbolChanged,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// El estado de la pantalla principal (maneja los datos que se ven)
class _HomeScreenState extends State<HomeScreen> {
  // Lista para guardar todos los gastos que se muestran
  List<Expense> _expenses = [];
  // La suma total de todos los gastos
  double _totalExpenses = 0.0;
  // Una herramienta para hablar con la base de datos
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Variables para controlar el filtro y el ordenamiento
  String? _selectedCategoryFilter; // Categoría seleccionada para filtrar
  String _selectedOrder = 'Fecha Desc'; // Criterio de ordenamiento seleccionado
  TextEditingController _searchController = TextEditingController(); // Controlador para la barra de búsqueda

  // Opciones para el filtro de categoría (incluye 'Todas')
  List<String> _categoryFilterOptions = ['Todas', ...categories];

  // Opciones para el ordenamiento
  final List<String> _orderByOptions = [
    'Fecha Desc',
    'Fecha Asc',
    'Monto Desc',
    'Monto Asc',
    'Descripción Asc',
    'Descripción Desc',
  ];

  // Variables para el resumen de presupuesto
  double _totalBudgetForMonth = 0.0;
  double _totalSpentInBudgetedCategories = 0.0;


  // Se ejecuta justo cuando la pantalla aparece por primera vez
  @override
  void initState() {
    super.initState();
    // Inicializa el filtro de categoría con 'Todas'
    _selectedCategoryFilter = _categoryFilterOptions.first;
    // Carga los gastos guardados en la base de datos con el filtro y ordenamiento iniciales
    _loadExpensesAndBudgets(); // Nueva función para cargar ambos

    // Escucha cambios en la barra de búsqueda para recargar gastos
    _searchController.addListener(() {
      _loadExpensesAndBudgets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Limpia el controlador de búsqueda
    super.dispose();
  }

  // Carga los gastos y los datos de presupuesto
  Future<void> _loadExpensesAndBudgets() async {
    await _loadExpenses(); // Carga los gastos
    await _loadBudgetSummary(); // Carga el resumen del presupuesto
  }

  // Carga los gastos desde la base de datos aplicando el filtro, búsqueda y ordenamiento actuales
  Future<void> _loadExpenses() async {
    // Obtiene la lista de gastos de la base de datos, aplicando el filtro, búsqueda y ordenamiento
    List<Expense> expenses = await _dbHelper.getExpenses(
      categoryFilter: _selectedCategoryFilter,
      orderBy: _selectedOrder,
      searchQuery: _searchController.text, // Pasa el texto de búsqueda
    );

    // Si la pantalla ya no está visible, no hagas nada más
    if (!mounted) return;

    // Calcula el total sumando todos los montos de los gastos
    double total = 0.0;
    // Calcula el total solo de los gastos que se están mostrando (después del filtro)
    for (var expense in expenses) {
      total += expense.amount;
    }


    // Actualiza la pantalla con la nueva lista de gastos y el total
    setState(() {
      _expenses = expenses;
      _totalExpenses = total; // Ahora el total refleja solo los gastos filtrados
    });
  }

  // Carga el resumen de los presupuestos para el mes actual
  Future<void> _loadBudgetSummary() async {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    List<Budget> budgets = await _dbHelper.getBudgets();
    double totalBudget = 0.0;
    double totalSpent = 0.0;

    for (var budget in budgets) {
      totalBudget += budget.amount;
      // Obtiene el gasto total para esta categoría en el mes actual
      totalSpent += await _dbHelper.getTotalSpentByCategoryAndPeriod(
          budget.category, currentMonth, currentYear);
    }

    if (!mounted) return;
    setState(() {
      _totalBudgetForMonth = totalBudget;
      _totalSpentInBudgetedCategories = totalSpent;
    });
  }


  // Te lleva a la pantalla para añadir o cambiar un gasto
  void _navigateToAddEditExpense({Expense? expense}) async {
    // Espera a que vuelvas de la pantalla de añadir/editar
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(expense: expense),
      ),
    );

    // Si la pantalla ya no está visible, no hagas nada más
    if (!mounted) return;

    // Si volviste y se guardó o borró algo (el resultado es true), recarga los gastos y presupuestos
    if (result == true) {
      _loadExpensesAndBudgets();
    }
  }

  // Muestra un mensaje emergente para confirmar si quieres borrar un gasto
  void _confirmDeleteExpense(Expense expense) {
    showDialog(
      context: context, // Muestra el diálogo en esta pantalla
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'), // Título del diálogo
          content: const Text('¿Estás seguro de que quieres eliminar este gasto?'), // Mensaje del diálogo
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'), // Botón para cancelar
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text('Eliminar'), // Botón para confirmar eliminación
              onPressed: () async {
                // Borra el gasto de la base de datos
                await _dbHelper.deleteExpense(expense.id!);

                // Si la pantalla ya no está visible, no hagas nada más
                if (!mounted) return;

                // Recarga la lista de gastos en la pantalla
                _loadExpensesAndBudgets(); // Recarga ambos
                // Cierra el diálogo de confirmación
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // La función _exportExpensesToCsv() ha sido eliminada.

  // Muestra un diálogo para seleccionar la moneda
  void _showCurrencySelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? tempSelectedSymbol = widget.currentCurrencySymbol; // Símbolo temporal para el diálogo

        return AlertDialog(
          title: const Text('Seleccionar Moneda'),
          content: DropdownButton<String>(
            value: tempSelectedSymbol,
            onChanged: (String? newValue) {
              if (newValue != null) {
                tempSelectedSymbol = newValue; // Actualiza el valor temporal
                Navigator.of(context).pop(); // Cierra el diálogo al seleccionar
                widget.onCurrencySymbolChanged(newValue); // Llama a la función para actualizar en MyApp
              }
            },
            items: <String>['\$', '€', '£', '¥', 'C\$'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  // Dibuja la interfaz visual de la pantalla
  @override
  Widget build(BuildContext context) {
    // Herramienta para mostrar el total de gastos como moneda
    final currencyFormat = NumberFormat.currency(locale: 'es_SV', symbol: widget.currentCurrencySymbol); // Usa el símbolo de moneda dinámico

    // Calcula el restante del presupuesto
    final double budgetRemaining = _totalBudgetForMonth - _totalSpentInBudgetedCategories;
    // Determina el color del restante
    Color remainingColor = budgetRemaining >= 0 ? Colors.green : Colors.red;

    // Scaffold es la estructura básica de la pantalla (barra superior, cuerpo, etc.)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Gastos Personales'), // Título en la barra de arriba
        centerTitle: true, // Centra el título
        actions: [ // Acciones en la barra de la aplicación (como botones de icono)
          // Botón para ir a la pantalla de Resumen
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Ver Resumen',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SummaryScreen(currentCurrencySymbol: widget.currentCurrencySymbol)), // Pasa el símbolo de moneda
              );
              _loadExpensesAndBudgets(); // Recargar al volver
            },
          ),
          // Botón para ir a la pantalla de Gestión de Presupuestos
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: 'Gestionar Presupuestos',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BudgetManagementScreen(currentCurrencySymbol: widget.currentCurrencySymbol)), // Pasa el símbolo de moneda
              );
              _loadExpensesAndBudgets(); // Recargar al volver
            },
          ),
          // El botón para exportar gastos a CSV ha sido eliminado.
          // IconButton(
          //   icon: const Icon(Icons.download),
          //   tooltip: 'Exportar Gastos',
          //   onPressed: _exportExpensesToCsv, // Esta función ya no existe
          // ),
          // Botón para seleccionar la moneda
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            tooltip: 'Seleccionar Moneda',
            onPressed: _showCurrencySelectionDialog,
          ),
          // Botón para cambiar el tema (modo claro/oscuro)
          IconButton(
            // Icono cambia dependiendo del brillo actual del tema
            icon: Icon(Theme.of(context).brightness == Brightness.dark
                ? Icons.lightbulb_outline // Icono de bombilla si está en modo oscuro
                : Icons.dark_mode), // Icono de luna si está en modo claro
            tooltip: 'Cambiar Tema', // Texto que aparece al mantener presionado
            onPressed: widget.toggleTheme, // Llama a la función para cambiar el tema recibida de MyApp
          ),
        ],
      ),
      body: Column( // Organiza los elementos verticalmente
        children: [
          // Una tarjeta que muestra el resumen del total de gastos
          Card(
            margin: const EdgeInsets.all(16.0), // Espacio alrededor de la tarjeta
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Espacio dentro de la tarjeta
              child: Column( // Elementos dentro de la tarjeta, organizados verticalmente
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto a la izquierda
                children: [
                  const Text(
                    'Total de Gastos (Filtrados):', // Etiqueta para el total
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0), // Espacio vertical
                  Text(
                    currencyFormat.format(_totalExpenses), // Muestra el total formateado
                    // El color rojo puede no verse bien en modo oscuro, podrías ajustarlo
                    style: const TextStyle(fontSize: 24.0, color: Colors.redAccent, fontWeight: FontWeight.bold), // Estilo del texto del total
                  ),
                  const SizedBox(height: 16.0), // Espacio adicional
                  const Text(
                    'Resumen Presupuesto Mensual:',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Presupuesto Total: ${currencyFormat.format(_totalBudgetForMonth)}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'Gastado en Categorías Presupuestadas: ${currencyFormat.format(_totalSpentInBudgetedCategories)}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    'Restante: ${currencyFormat.format(budgetRemaining)}',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: remainingColor),
                  ),
                ],
              ),
            ),
          ),
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Gasto (Descripción o Categoría)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // Columna para los controles de filtro y ordenamiento (AHORA VERTICAL)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column( // Cambiado de Row a Column
              crossAxisAlignment: CrossAxisAlignment.stretch, // Estira los dropdowns horizontalmente
              children: [
                // Dropdown para filtrar por categoría
                DropdownButtonFormField<String>( // Usamos DropdownButtonFormField para mejor alineación en Column
                  decoration: const InputDecoration(labelText: 'Filtrar por Categoría', border: OutlineInputBorder()), // Añade un borde
                  value: _selectedCategoryFilter,
                  items: _categoryFilterOptions.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategoryFilter = newValue; // Actualiza el filtro seleccionado
                    });
                    _loadExpensesAndBudgets(); // Recarga los gastos con el nuevo filtro y presupuesto
                  },
                ),
                const SizedBox(height: 12.0), // Espacio vertical entre dropdowns
                // Dropdown para ordenar
                DropdownButtonFormField<String>( // Usamos DropdownButtonFormField
                  decoration: const InputDecoration(labelText: 'Ordenar por', border: OutlineInputBorder()), // Añade un borde
                  value: _selectedOrder,
                  items: _orderByOptions.map((String order) {
                    return DropdownMenuItem<String>(
                      value: order,
                      child: Text(order),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedOrder = newValue!; // Actualiza el orden seleccionado
                    });
                    _loadExpensesAndBudgets(); // Recarga los gastos con el nuevo orden y presupuesto
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Transacciones:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // La lista que muestra cada gasto individualmente
          Expanded( // Hace que la lista ocupe todo el espacio restante
            child: _expenses.isEmpty // Si no hay gastos...
                ? const Center(child: Text('No hay gastos registrados.')) // Muestra un mensaje
                : ListView.builder( // Si hay gastos, construye la lista
              itemCount: _expenses.length, // Cuántos elementos hay en la lista
              itemBuilder: (context, index) { // Cómo dibujar cada elemento de la lista
                final expense = _expenses[index]; // El gasto actual en este elemento
                // Herramienta para mostrar la fecha del gasto
                final dateFormat = DateFormat('dd/MM/yyyy');

                // Una tarjeta para cada gasto en la lista
                return Card(
                  // Aumentado el espacio vertical y horizontal alrededor de cada tarjeta de gasto
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: ListTile( // Un elemento de lista con un icono, título y subtítulo
                    leading: Container( // El contenedor para el monto
                      width: 60.0, // Ancho del rectángulo
                      height: 40.0, // Alto del rectángulo
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor, // Color de fondo (se adapta al tema)
                        borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                      ),
                      padding: const EdgeInsets.all(4.0), // Espacio dentro del contenedor
                      child: FittedBox( // Intenta ajustar el texto dentro del contenedor
                        child: Text(
                          currencyFormat.format(expense.amount), // El monto del gasto formateado
                          style: const TextStyle(color: Colors.white, fontSize: 14.0), // Tamaño de fuente aumentado
                        ),
                      ),
                    ),
                    // Icono de categoría a la izquierda del título
                    title: Row(
                      children: [
                        Icon(categoryIcons[expense.category] ?? Icons.category, size: 20.0), // Muestra el icono de la categoría
                        const SizedBox(width: 8.0),
                        Expanded(child: Text(expense.description)), // La descripción del gasto
                      ],
                    ),
                    subtitle: Text('${expense.category} - ${dateFormat.format(expense.date)}'), // La categoría y fecha del gasto
                    trailing: Row( // Elementos a la derecha (botones de editar y borrar)
                      mainAxisSize: MainAxisSize.min, // Hace que la fila ocupe el mínimo espacio
                      children: [
                        // Botón para editar el gasto
                        IconButton(
                          icon: const Icon(Icons.edit), // Icono de lápiz
                          onPressed: () {
                            _navigateToAddEditExpense(expense: expense); // Al tocar, va a la pantalla de edición
                          },
                        ),
                        // Botón para eliminar el gasto
                        IconButton(
                          icon: const Icon(Icons.delete), // Icono de bote de basura
                          color: Colors.red, // Color rojo para el icono de borrar (puede necesitar ajuste en modo oscuro)
                          onPressed: () {
                            _confirmDeleteExpense(expense); // Al tocar, muestra el diálogo de confirmación
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Un botón que flota en la esquina para añadir un nuevo gasto
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddEditExpense(); // Al tocar, va a la pantalla para añadir un nuevo gasto
        },
        tooltip: 'Agregar Gasto', // Texto que aparece al mantener presionado el botón
        child: const Icon(Icons.add), // Icono de '+' en el botón
      ),
    );
  }
}
