import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear moneda
import '../database/database_helper.dart'; // Para obtener datos de gastos
import 'add_edit_expense_screen.dart'; // Para acceder a la lista de categorías

// Pantalla para mostrar un resumen de gastos por categoría.
class SummaryScreen extends StatefulWidget {
  // Símbolo de moneda actual (opcional, si se pasa desde HomeScreen)
  final String? currentCurrencySymbol;

  const SummaryScreen({super.key, this.currentCurrencySymbol});

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, double> _categorySummary = {}; // Resumen de gastos por categoría
  double _totalMonthlySpent = 0.0; // Total gastado en el mes
  DateTime _selectedMonth = DateTime.now(); // Mes seleccionado para el resumen

  // Se ejecuta cuando la pantalla se crea por primera vez
  @override
  void initState() {
    super.initState();
    _loadSummary(); // Carga el resumen al iniciar
  }

  // Carga el resumen de gastos por categoría para el mes seleccionado.
  Future<void> _loadSummary() async {
    final int month = _selectedMonth.month;
    final int year = _selectedMonth.year;

    Map<String, double> summary = await _dbHelper.getMonthlyCategorySummary(month, year);
    double total = 0.0;
    summary.forEach((category, amount) {
      total += amount;
    });

    if (!mounted) return;
    setState(() {
      _categorySummary = summary;
      _totalMonthlySpent = total;
    });
  }

  // Muestra un selector de mes/año.
  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.year, // Esta es la propiedad correcta para el modo inicial
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
      _loadSummary(); // Recarga el resumen para el nuevo mes
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa el símbolo de moneda pasado o el valor por defecto '$'
    final currencySymbol = widget.currentCurrencySymbol ?? '\$';
    final currencyFormat = NumberFormat.currency(locale: 'es_SV', symbol: currencySymbol);
    final dateFormatMonthYear = DateFormat('MMMM y', 'es'); // Formato para mes y año

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Gastos'),
        centerTitle: true,
        actions: [
          // Botón para seleccionar el mes del resumen
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectMonth(context),
            tooltip: 'Seleccionar Mes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Muestra el mes actual del resumen y el total gastado
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen para ${dateFormatMonthYear.format(_selectedMonth)}',
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Total Gastado: ${currencyFormat.format(_totalMonthlySpent)}',
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.redAccent),
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
                'Gastos por Categoría:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Lista de gastos por categoría
          Expanded(
            child: _categorySummary.isEmpty
                ? const Center(child: Text('No hay gastos registrados para este mes.'))
                : ListView.builder(
              itemCount: categories.length, // Iteramos sobre todas las categorías predefinidas
              itemBuilder: (context, index) {
                final category = categories[index];
                final amount = _categorySummary[category] ?? 0.0; // Obtiene el monto o 0 si no hay gastos en esa categoría

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(category),
                    trailing: Text(
                      currencyFormat.format(amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: amount > 0 ? Theme.of(context).primaryColor : Colors.grey, // Color si hay gasto
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}