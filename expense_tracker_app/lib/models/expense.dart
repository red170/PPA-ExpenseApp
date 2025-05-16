// Define la estructura de un gasto.
class Expense {
  int? id; // ID único para la base de datos
  String description; // Descripción del gasto
  String category; // Categoría del gasto
  double amount; // Monto del gasto
  DateTime date; // Fecha del gasto

  // Constructor para crear una instancia de Expense.
  Expense({
    this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });

  // Convierte un objeto Expense a un Map. Útil para insertar en la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(), // Almacena la fecha como String ISO 8601
    };
  }

  // Crea un objeto Expense a partir de un Map. Útil para leer desde la base de datos.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']), // Convierte el String ISO 8601 de vuelta a DateTime
    );
  }
}
