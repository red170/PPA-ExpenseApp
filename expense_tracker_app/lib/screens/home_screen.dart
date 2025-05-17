import 'package:flutter/material.dart';
import '../models/expense.dart'; // Importa el modelo de gasto
import '../database/database_helper.dart'; // Importa el helper de base de datos
import 'add_edit_expense_screen.dart'; // Importa la pantalla para agregar/editar gastos
import 'package:intl/intl.dart'; // Importa el paquete intl para formatear fecha y moneda

// Pantalla principal que muestra el resumen de gastos y la lista de transacciones.
class HomeScreen extends StatefulWidget {
  // Usando la sintaxis de super parameter para el key
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = []; // Lista para almacenar los gastos
  double _totalExpenses = 0.0; // Variable para el total de gastos
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instancia del helper de base de datos

  @override
  void initState() {
    super.initState();
    _loadExpenses(); // Carga los gastos al iniciar la pantalla
  }

  // Carga los gastos desde la base de datos y actualiza el estado.
  Future<void> _loadExpenses() async {
    List<Expense> expenses = await _dbHelper.getExpenses();

    // Verifica si el widget aún está montado antes de llamar a setState
    if (!mounted) return;

    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    setState(() {
      _expenses = expenses;
      _totalExpenses = total;
    });
  }

  // Navega a la pantalla de agregar/editar gasto.
  // Si se pasa un gasto, es para editar; si no, es para agregar uno nuevo.
  void _navigateToAddEditExpense({Expense? expense}) async {
    // Espera el resultado de la pantalla de agregar/editar.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(expense: expense),
      ),
    );

    // Verifica si el widget aún está montado antes de usar el resultado o llamar a funciones que actualizan la UI
    if (!mounted) return;

    // Si el resultado es true, significa que se guardó o eliminó un gasto,
    // por lo que recargamos la lista de gastos.
    if (result == true) {
      _loadExpenses();
    }
  }

  // Muestra un diálogo de confirmación para eliminar un gasto.
  void _confirmDeleteExpense(Expense expense) {
    showDialog(
      context: context, // Es seguro usar context aquí porque showDialog es síncrono
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este gasto?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                await _dbHelper.deleteExpense(expense.id!); // Elimina el gasto de la base de datos

                // Verifica si el widget aún está montado antes de actualizar la UI
                if (!mounted) return;

                _loadExpenses(); // Recarga la lista de gastos
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formatea el total de gastos a moneda local.
    // Asegúrate de que 'es_SV' sea el locale correcto para El Salvador o usa uno genérico como 'en_US' si prefieres.
    final currencyFormat = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Gastos Personales'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tarjeta que muestra el resumen de gastos.
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total de Gastos:',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    currencyFormat.format(_totalExpenses), // Muestra el total formateado
                    style: const TextStyle(fontSize: 24.0, color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
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
          // Lista expandible para mostrar las transacciones.
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('No hay gastos registrados.')) // Mensaje si no hay gastos
                : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                // Formatea la fecha del gasto.
                final dateFormat = DateFormat('dd/MM/yyyy'); // DateFormat se usa directamente

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        currencyFormat.format(expense.amount), // Muestra el monto en el círculo
                        style: const TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                    ),
                    title: Text(expense.description), // Descripción del gasto
                    subtitle: Text('${expense.category} - ${dateFormat.format(expense.date)}'), // Categoría y fecha
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón para editar el gasto.
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _navigateToAddEditExpense(expense: expense); // Navega a la pantalla de edición
                          },
                        ),
                        // Botón para eliminar el gasto.
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            _confirmDeleteExpense(expense); // Muestra el diálogo de confirmación para eliminar
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
      // Botón flotante para agregar un nuevo gasto.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddEditExpense(); // Navega a la pantalla para agregar un nuevo gasto
        },
        tooltip: 'Agregar Gasto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
