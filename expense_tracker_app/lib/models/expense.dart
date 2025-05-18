import 'package:flutter/material.dart'; // Importa elementos básicos de Flutter

// Define cómo se ve un gasto individual
class Expense {
  int? id; // Un número único para identificar el gasto (puede ser nulo al crear uno nuevo)
  String description; // Qué es el gasto (ej: "Café")
  String category; // A qué pertenece el gasto (ej: "Comida")
  double amount; // Cuánto costó el gasto (un número con decimales)
  DateTime date; // Cuándo se hizo el gasto (fecha y hora)

  // Constructor para crear un objeto Expense
  Expense({
    this.id, // El ID es opcional al crear
    required this.description, // La descripción es obligatoria
    required this.category, // La categoría es obligatoria
    required this.amount, // El monto es obligatorio
    required this.date, // La fecha es obligatoria
  });

  // Convierte este objeto Expense a un formato que la base de datos entiende (un Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(), // Guarda la fecha como texto estándar
    };
  }

  // Crea un objeto Expense a partir de datos que vienen de la base de datos (un Map)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']), // Convierte el texto de la fecha de vuelta a fecha
    );
  }
}
