import 'package:flutter/material.dart';
import '../models/expense.dart'; // Importa cómo se define un gasto
import '../database/database_helper.dart'; // Importa las funciones para guardar y leer gastos
import 'package:intl/intl.dart'; // Para dar formato a la fecha

// Pantalla para añadir un gasto nuevo o cambiar uno que ya existe
class AddEditExpenseScreen extends StatefulWidget {
  // Este es el gasto que vamos a editar (si es nulo, es un gasto nuevo)
  final Expense? expense;

  // Constructor del widget
  const AddEditExpenseScreen({super.key, this.expense});

  @override
  _AddEditExpenseScreenState createState() => _AddEditExpenseScreenState();
}

// El estado interno de la pantalla (maneja los datos y la interacción)
class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  // Una clave para validar los campos del formulario
  final _formKey = GlobalKey<FormState>();
  // Controladores para obtener el texto de los campos de entrada
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  // La fecha seleccionada para el gasto, por defecto es hoy
  DateTime _selectedDate = DateTime.now();
  // Una herramienta para interactuar con la base de datos
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Verifica si estamos en modo edición (si hay un gasto para editar)
  bool get _isEditing => widget.expense != null;

  // Se ejecuta cuando la pantalla se crea por primera vez
  @override
  void initState() {
    super.initState();
    // Si estamos editando, llena los campos del formulario con los datos del gasto
    if (_isEditing) {
      _descriptionController.text = widget.expense!.description;
      _categoryController.text = widget.expense!.category;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
    }
  }

  // Se ejecuta cuando la pantalla ya no se usa
  @override
  void dispose() {
    // Limpia los controladores de texto para liberar memoria
    _descriptionController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Muestra un calendario para que el usuario elija una fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // La fecha que se muestra al abrir el calendario
      firstDate: DateTime(2000), // La fecha más antigua que se puede elegir
      lastDate: DateTime(2101), // La fecha más nueva que se puede elegir
    );
    // Si se eligió una fecha diferente, actualiza la fecha seleccionada
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Guarda la información del gasto en la base de datos
  Future<void> _saveExpense() async {
    // Si todos los campos del formulario son válidos
    if (_formKey.currentState!.validate()) {
      // Crea un objeto Expense con la información de los campos
      final newExpense = Expense(
        id: _isEditing ? widget.expense!.id : null, // Mantiene el ID si edita, si no, es nuevo
        description: _descriptionController.text,
        category: _categoryController.text,
        amount: double.parse(_amountController.text), // Convierte el texto del monto a número
        date: _selectedDate,
      );

      // Si estamos editando, actualiza el gasto en la base de datos
      if (_isEditing) {
        await _dbHelper.updateExpense(newExpense);
      } else {
        // Si es un gasto nuevo, lo inserta en la base de datos
        await _dbHelper.insertExpense(newExpense);
      }

      // Cierra esta pantalla y regresa a la anterior, indicando que algo cambió (true)
      Navigator.pop(context, true);
    }
  }

  // Dibuja la interfaz visual de esta pantalla
  @override
  Widget build(BuildContext context) {
    // Herramienta para mostrar la fecha en un formato legible
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Scaffold es la estructura básica de la pantalla (barra superior, cuerpo, etc.)
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Gasto' : 'Agregar Nuevo Gasto'), // Título cambia si edita o agrega
        centerTitle: true, // Centra el título en la barra superior
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Espacio alrededor del contenido principal
        child: Form(
          key: _formKey, // Vincula la clave al formulario para validación
          child: ListView( // Permite hacer scroll si el contenido es largo
            children: <Widget>[
              // Campo para escribir la descripción del gasto
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'), // Etiqueta del campo
                validator: (value) { // Regla para validar el campo
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción'; // Mensaje si está vacío
                  }
                  return null; // Si está bien, no hay mensaje de error
                },
              ),
              const SizedBox(height: 12.0), // Espacio vertical
              // Campo para escribir la categoría del gasto
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0), // Espacio vertical
              // Campo para escribir el monto del gasto (solo números)
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.numberWithOptions(decimal: true), // Muestra teclado numérico
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un monto';
                  }
                  if (double.tryParse(value) == null) { // Intenta convertir el texto a número
                    return 'Por favor ingresa un número válido'; // Mensaje si no es un número
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12.0), // Espacio vertical
              // Fila para mostrar la fecha y un botón para cambiarla
              Row(
                children: [
                  Expanded( // Ocupa el espacio disponible
                    child: Text(
                      'Fecha: ${dateFormat.format(_selectedDate)}', // Muestra la fecha seleccionada
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                  TextButton( // Botón de texto para abrir el calendario
                    onPressed: () => _selectDate(context), // Llama a la función para seleccionar fecha
                    child: const Text('Seleccionar Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 24.0), // Espacio vertical
              // Botón para guardar el gasto
              ElevatedButton(
                onPressed: _saveExpense, // Llama a la función para guardar
                child: Text(_isEditing ? 'Guardar Cambios' : 'Agregar Gasto'), // Texto del botón cambia
              ),
            ],
          ),
        ),
      ),
    );
  }
}
