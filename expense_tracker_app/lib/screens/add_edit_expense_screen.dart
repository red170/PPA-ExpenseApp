import 'package:flutter/material.dart';
import '../models/expense.dart'; // Importa el modelo de gasto
import '../database/database_helper.dart'; // Importa el helper de base de datos
import 'package:intl/intl.dart'; // Necesario para formatear la fecha (asegúrate de tener la dependencia 'intl')

// Pantalla para agregar o editar un gasto.
class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense; // El gasto a editar (opcional, si es nulo, es para agregar)

  const AddEditExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  _AddEditExpenseScreenState createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>(); // Clave global para el formulario
  final TextEditingController _descriptionController = TextEditingController(); // Controlador para el campo descripción
  final TextEditingController _categoryController = TextEditingController(); // Controlador para el campo categoría
  final TextEditingController _amountController = TextEditingController(); // Controlador para el campo monto
  DateTime _selectedDate = DateTime.now(); // Fecha seleccionada (por defecto, la fecha actual)
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instancia del helper de base de datos

  bool get _isEditing => widget.expense != null; // Verifica si estamos editando un gasto existente

  @override
  void initState() {
    super.initState();
    // Si estamos editando, precarga los datos del gasto en los controladores.
    if (_isEditing) {
      _descriptionController.text = widget.expense!.description;
      _categoryController.text = widget.expense!.category;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
    }
  }

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se desecha.
    _descriptionController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Muestra un selector de fecha.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Fecha inicial del selector
      firstDate: DateTime(2000), // Fecha mínima seleccionable
      lastDate: DateTime(2101), // Fecha máxima seleccionable
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Actualiza la fecha seleccionada
      });
    }
  }

  // Guarda o actualiza el gasto en la base de datos.
  Future<void> _saveExpense() async {
    // Valida el formulario.
    if (_formKey.currentState!.validate()) {
      final newExpense = Expense(
        id: _isEditing ? widget.expense!.id : null, // Si edita, mantiene el ID; si agrega, es nulo para auto-incremento
        description: _descriptionController.text,
        category: _categoryController.text,
        amount: double.parse(_amountController.text), // Convierte el texto a double
        date: _selectedDate,
      );

      if (_isEditing) {
        await _dbHelper.updateExpense(newExpense); // Actualiza el gasto existente
      } else {
        await _dbHelper.insertExpense(newExpense); // Inserta un nuevo gasto
      }

      // Regresa a la pantalla anterior indicando que se realizó una acción (true).
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatea la fecha seleccionada para mostrarla.
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Gasto' : 'Agregar Nuevo Gasto'), // Título según si edita o agrega
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Asigna la clave global al formulario
          child: ListView(
            children: <Widget>[
              // Campo de texto para la descripción.
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción'; // Validación: campo no vacío
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              // Campo de texto para la categoría.
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una categoría'; // Validación: campo no vacío
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              // Campo de texto para el monto (solo números).
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.numberWithOptions(decimal: true), // Teclado numérico con decimales
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un monto'; // Validación: campo no vacío
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido'; // Validación: debe ser un número
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0),
              // Fila para mostrar la fecha seleccionada y el botón para cambiarla.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha: ${dateFormat.format(_selectedDate)}', // Muestra la fecha formateada
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context), // Llama a la función para seleccionar fecha
                    child: const Text('Seleccionar Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              // Botón para guardar el gasto.
              ElevatedButton(
                onPressed: _saveExpense, // Llama a la función para guardar el gasto
                child: Text(_isEditing ? 'Guardar Cambios' : 'Agregar Gasto'), // Texto según si edita o agrega
              ),
            ],
          ),
        ),
      ),
    );
  }
}
