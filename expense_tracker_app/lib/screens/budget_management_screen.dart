import 'package:flutter/material.dart';
import '../models/budget.dart'; // Importa el modelo de presupuesto
import '../database/database_helper.dart'; // Importa el helper de base de datos
import 'add_edit_expense_screen.dart'; // Para acceder a la lista de categorías
import 'package:intl/intl.dart'; // Para formatear moneda

// Pantalla para gestionar los presupuestos por categoría.
class BudgetManagementScreen extends StatefulWidget {
  // Símbolo de moneda actual (opcional, si se pasa desde HomeScreen)
  final String? currentCurrencySymbol;

  const BudgetManagementScreen({super.key, this.currentCurrencySymbol});

  @override
  _BudgetManagementScreenState createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  List<Budget> _budgets = []; // Lista para almacenar los presupuestos
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instancia del helper de base de datos

  // Se ejecuta cuando la pantalla se crea por primera vez
  @override
  void initState() {
    super.initState();
    _loadBudgets(); // Carga los presupuestos al iniciar la pantalla
  }

  // Carga los presupuestos desde la base de datos y actualiza el estado.
  Future<void> _loadBudgets() async {
    List<Budget> budgets = await _dbHelper.getBudgets();
    if (!mounted) return;
    setState(() {
      _budgets = budgets;
    });
  }

  // Muestra un diálogo para añadir o editar un presupuesto.
  void _showBudgetDialog({Budget? budget}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _amountController = TextEditingController();
    String? _selectedCategory;

    // Si se está editando, precarga los datos
    if (budget != null) {
      _amountController.text = budget.amount.toString();
      _selectedCategory = budget.category;
    }

    // Usa el símbolo de moneda pasado o el valor por defecto '$'
    final currencySymbol = widget.currentCurrencySymbol ?? '\$';
    final currencyFormat = NumberFormat.currency(locale: 'es_SV', symbol: currencySymbol);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(budget == null ? 'Añadir Presupuesto' : 'Editar Presupuesto'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown para seleccionar la categoría del presupuesto
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  value: _selectedCategory,
                  items: categories.map((String category) { // Usa la lista pública de categorías
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    _selectedCategory = newValue; // Actualiza la categoría seleccionada
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor selecciona una categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                // Campo para el monto del presupuesto
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Monto del Presupuesto (${currencySymbol})'), // Muestra el símbolo de moneda
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un monto';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor ingresa un número válido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(budget == null ? 'Añadir' : 'Guardar'),
              onPressed: () async {
                if (_formKey.currentState!.validate() && _selectedCategory != null) {
                  final newBudget = Budget(
                    id: budget?.id, // Mantiene el ID si edita
                    category: _selectedCategory!,
                    amount: double.parse(_amountController.text),
                  );

                  if (budget == null) {
                    await _dbHelper.insertBudget(newBudget); // Añade nuevo presupuesto
                  } else {
                    await _dbHelper.updateBudget(newBudget); // Actualiza presupuesto existente
                  }

                  if (!mounted) return;
                  _loadBudgets(); // Recarga la lista de presupuestos
                  Navigator.of(context).pop(); // Cierra el diálogo
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Muestra un diálogo de confirmación para eliminar un presupuesto.
  void _confirmDeleteBudget(Budget budget) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar el presupuesto para ${budget.category}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                await _dbHelper.deleteBudget(budget.id!); // Elimina el presupuesto

                if (!mounted) return;
                _loadBudgets(); // Recarga la lista de presupuestos
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usa el símbolo de moneda pasado o el valor por defecto '$'
    final currencySymbol = widget.currentCurrencySymbol ?? '\$';
    final currencyFormat = NumberFormat.currency(locale: 'es_SV', symbol: currencySymbol);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Presupuestos'),
        centerTitle: true,
      ),
      body: _budgets.isEmpty
          ? const Center(child: Text('No hay presupuestos configurados.'))
          : ListView.builder(
        itemCount: _budgets.length,
        itemBuilder: (context, index) {
          final budget = _budgets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: ListTile(
              title: Text('Categoría: ${budget.category}'),
              subtitle: Text('Presupuesto: ${currencyFormat.format(budget.amount)}'), // Formatea el monto
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showBudgetDialog(budget: budget), // Editar presupuesto
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _confirmDeleteBudget(budget), // Eliminar presupuesto
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBudgetDialog(), // Añadir nuevo presupuesto
        tooltip: 'Añadir Presupuesto',
        child: const Icon(Icons.add),
      ),
    );
  }
}