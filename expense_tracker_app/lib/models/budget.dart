// Define cómo se ve un presupuesto.
class Budget {
  int? id; // ID único para la base de datos (opcional, se auto-genera)
  String category; // La categoría a la que aplica este presupuesto
  double amount; // El monto del presupuesto para esa categoría

  // Constructor para crear una instancia de Budget.
  Budget({
    this.id,
    required this.category,
    required this.amount,
  });

  // Convierte un objeto Budget a un Map. Útil para insertar en la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
    };
  }

  // Crea un objeto Budget a partir de un Map. Útil para leer desde la base de datos.
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
    );
  }
}