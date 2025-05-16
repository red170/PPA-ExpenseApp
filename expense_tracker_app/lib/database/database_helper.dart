import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart'; // Importa el modelo de gasto

// Clase para manejar las operaciones de la base de datos.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Constructor interno privado para el singleton.
  DatabaseHelper._internal();

  // Factory constructor para obtener la única instancia de la clase.
  factory DatabaseHelper() {
    return _instance;
  }

  // Getter para la instancia de la base de datos. Si no existe, la inicializa.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base de datos.
  Future<Database> _initDatabase() async {
    // Obtiene la ruta del directorio de documentos de la aplicación.
    String documentsPath = await getDatabasesPath();
    // Une la ruta del directorio con el nombre de la base de datos.
    String path = join(documentsPath, 'expenses.db');

    // Abre la base de datos. Si no existe, onCreate se llama para crearla.
    return await openDatabase(
      path,
      version: 1, // Versión de la base de datos
      onCreate: _onCreate, // Función para crear la base de datos si no existe
    );
  }

  // Crea la tabla de gastos en la base de datos.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        category TEXT,
        amount REAL,
        date TEXT
      )
      ''',
    );
  }

  // Inserta un nuevo gasto en la base de datos.
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    // Inserta el gasto como un Map. conflictAlgorithm reemplaza si hay conflicto de ID.
    return await db.insert('expenses', expense.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Recupera todos los gastos de la base de datos.
  Future<List<Expense>> getExpenses() async {
    Database db = await database;
    // Consulta todos los registros de la tabla 'expenses'.
    List<Map<String, dynamic>> maps = await db.query('expenses', orderBy: 'date DESC'); // Ordena por fecha descendente

    // Convierte la lista de Maps a una lista de objetos Expense.
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Actualiza un gasto existente en la base de datos.
  Future<int> updateExpense(Expense expense) async {
    Database db = await database;
    // Actualiza el gasto donde el ID coincide.
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?', // Cláusula WHERE para identificar el gasto a actualizar
      whereArgs: [expense.id], // Argumentos para la cláusula WHERE
    );
  }

  // Elimina un gasto de la base de datos.
  Future<int> deleteExpense(int id) async {
    Database db = await database;
    // Elimina el gasto donde el ID coincide.
    return await db.delete(
      'expenses',
      where: 'id = ?', // Cláusula WHERE para identificar el gasto a eliminar
      whereArgs: [id], // Argumentos para la cláusula WHERE
    );
  }
}
