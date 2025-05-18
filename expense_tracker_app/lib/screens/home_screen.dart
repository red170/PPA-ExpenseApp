import 'package:flutter/material.dart';
import '../models/expense.dart'; // Define cómo es un gasto
import '../database/database_helper.dart'; // Para manejar la base de datos
import 'add_edit_expense_screen.dart'; // La pantalla para añadir/editar gastos
import 'package:intl/intl.dart'; // Para dar formato a números y fechas

// Esta es la pantalla principal que muestra los gastos y el total
class HomeScreen extends StatefulWidget {
  // Constructor básico
  const HomeScreen({super.key});

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

  // Se ejecuta justo cuando la pantalla aparece por primera vez
  @override
  void initState() {
    super.initState();
    // Carga los gastos guardados en la base de datos
    _loadExpenses();
  }

  // Carga los gastos desde la base de datos y actualiza la pantalla
  Future<void> _loadExpenses() async {
    // Obtiene la lista de gastos de la base de datos
    List<Expense> expenses = await _dbHelper.getExpenses();

    // Si la pantalla ya no está visible, no hagas nada más
    if (!mounted) return;

    // Calcula el total sumando todos los montos de los gastos
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    // Actualiza la pantalla con la nueva lista de gastos y el total
    setState(() {
      _expenses = expenses;
      _totalExpenses = total;
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

    // Si volviste y se guardó o borró algo (el resultado es true), recarga los gastos
    if (result == true) {
      _loadExpenses();
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
                _loadExpenses();
                // Cierra el diálogo de confirmación
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
    final currencyFormat = NumberFormat.currency(locale: 'es_SV', symbol: '\$'); // Formato para El Salvador

    // Scaffold es la estructura base de la pantalla (barra de arriba, cuerpo, etc.)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Gastos Personales'), // Título en la barra de arriba
        centerTitle: true, // Centra el título
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
                    'Total de Gastos:', // Etiqueta para el total
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0), // Espacio vertical
                  Text(
                    currencyFormat.format(_totalExpenses), // Muestra el total formateado
                    style: const TextStyle(fontSize: 24.0, color: Colors.redAccent, fontWeight: FontWeight.bold), // Estilo del texto del total
                  ),
                ],
              ),
            ),
          ),
          // Un texto que dice 'Transacciones:'
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
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Espacio alrededor de la tarjeta del gasto
                  child: ListTile( // Un elemento de lista con un icono, título y subtítulo
                    leading: CircleAvatar( // El círculo a la izquierda con el monto
                      backgroundColor: Theme.of(context).primaryColor, // Color del círculo
                      radius: 18.0, // Tamaño del círculo
                      child: Padding(
                        padding: const EdgeInsets.all(2.0), // Espacio dentro del círculo
                        child: FittedBox( // Intenta ajustar el texto dentro del círculo
                          child: Text(
                            currencyFormat.format(expense.amount), // El monto del gasto formateado
                            style: const TextStyle(color: Colors.white, fontSize: 10.0), // Estilo del texto del monto
                          ),
                        ),
                      ),
                    ),
                    title: Text(expense.description), // La descripción del gasto
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
                          color: Colors.red, // Color rojo para el icono de borrar
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
