import 'package:flutter/material.dart';
import '../models/expense.dart'; // Define cómo se guarda un gasto
import '../database/database_helper.dart'; // Para manejar la base de datos
import 'package:intl/intl.dart'; // Para dar formato a la fecha

// Lista de categorías predefinidas
// Puedes añadir o modificar estas categorías según necesites
const List<String> categories = [
  'Comida',
  'Transporte',
  'Entretenimiento',
  'Hogar',
  'Compras',
  'Salud',
  'Educación',
  'Viajes',
  'Otros',
];


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
  final TextEditingController _amountController = TextEditingController();
  // Variable para guardar la categoría seleccionada
  String? _selectedCategory; // Ahora es String? y puede ser nulo inicialmente
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
    // Si estamos editando, llena los campos del formulario con los datos del gasto.
    // También selecciona la categoría si existe en la lista predefinida.
    if (_isEditing) {
      _descriptionController.text = widget.expense!.description;
      // Asegura que la categoría del gasto exista en la lista predefinida, si no, usa nulo.
      _selectedCategory = categories.contains(widget.expense!.category)
          ? widget.expense!.category
          : null; // Si la categoría guardada no está en la lista, no se selecciona ninguna
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
    } else {
      // Si es un gasto nuevo, selecciona la primera categoría por defecto si la lista no está vacía.
      if (categories.isNotEmpty) {
        _selectedCategory = categories.first;
      }
    }
  }

  @override
  void dispose() {
    // Limpia los controladores de texto para liberar memoria
    _descriptionController.dispose();
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
    // Valida el formulario y asegura que se haya seleccionado una categoría
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      // Crea un objeto Expense con la información de los campos
      final newExpense = Expense(
        id: _isEditing ? widget.expense!.id : null, // Mantiene el ID si edita, si no, es nuevo
        description: _descriptionController.text,
        category: _selectedCategory!, // Usa la categoría seleccionada del Dropdown
        amount: double.parse(_amountController.text), // Convierte el texto del monto a número
        date: _selectedDate, // Usa la fecha seleccionada
      );

      if (_isEditing) {
        await _dbHelper.updateExpense(newExpense); // Si estamos editando, actualiza
      } else {
        await _dbHelper.insertExpense(newExpense); // Si es nuevo, inserta
      }

      // Cierra esta pantalla y regresa a la anterior, indicando que algo cambió (true)
      Navigator.pop(context, true);
    } else if (_selectedCategory == null) {
      // Muestra un mensaje si no se ha seleccionado una categoría
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una categoría')),
      );
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
              // Campo para seleccionar la categoría (Dropdown)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoría'),
                value: _selectedCategory, // El valor seleccionado actualmente
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue; // Actualiza la categoría seleccionada
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una categoría'; // Validación: debe seleccionar una categoría
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
