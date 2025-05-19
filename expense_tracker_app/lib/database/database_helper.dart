import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart'; // Define cómo se guarda un gasto

// Esta clase ayuda a guardar, leer, actualizar y borrar los gastos en la base de datos
class DatabaseHelper {
  // Crea una única instancia de esta clase (para no tener varias conexiones a la base de datos)
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  // Una variable para guardar la conexión a la base de datos
  static Database? _database;

  // Constructor privado para asegurar que solo se cree una instancia
  DatabaseHelper._internal();

  // Permite obtener la única instancia de esta clase desde cualquier parte
  factory DatabaseHelper() {
    return _instance;
  }

  // Obtiene la base de datos. Si no está abierta, la abre primero.
  Future<Database> get database async {
    if (_database != null) {
      return _database!; // Si ya está abierta, la devuelve
    }
    _database = await _initDatabase(); // Si no, la inicializa
    return _database!;
  }

  // Configura y abre la base de datos en el teléfono
  Future<Database> _initDatabase() async {
    // Encuentra dónde se pueden guardar bases de datos en el teléfono
    String documentsPath = await getDatabasesPath();
    // Crea la ruta completa al archivo de la base de datos
    String path = join(documentsPath, 'expenses.db');

    // Abre el archivo de la base de datos. Si no existe, llama a _onCreate para crearla.
    return await openDatabase(
      path,
      version: 1, // La versión de la base de datos
      onCreate: _onCreate, // Función para crear las tablas la primera vez
    );
  }

  // Crea la tabla 'expenses' (gastos) en la base de datos
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Un número único para cada gasto
        description TEXT, -- La descripción del gasto (texto)
        category TEXT, -- La categoría del gasto (texto)
        amount REAL, -- El monto del gasto (número con decimales)
        date TEXT -- La fecha del gasto (guardada como texto)
      )
      ''',
    );
  }

  // Guarda un nuevo gasto en la base de datos
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    // Inserta el gasto. Si ya existe uno con el mismo ID, lo reemplaza.
    return await db.insert('expenses', expense.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Obtiene todos los gastos guardados en la base de datos
  // Ahora acepta parámetros opcionales para filtrar por categoría y ordenar
  Future<List<Expense>> getExpenses({String? categoryFilter, String? orderBy}) async {
    Database db = await database;

    // Construye la cláusula WHERE si se proporciona un filtro de categoría
    String? whereClause;
    List<dynamic>? whereArgs;
    if (categoryFilter != null && categoryFilter != 'Todas') { // 'Todas' es una opción para no filtrar
      whereClause = 'category = ?';
      whereArgs = [categoryFilter];
    }

    // Define el ordenamiento por defecto si no se especifica uno
    String? order;
    if (orderBy == 'Monto Asc') {
      order = 'amount ASC';
    } else if (orderBy == 'Monto Desc') {
      order = 'amount DESC';
    } else if (orderBy == 'Descripción Asc') {
      order = 'description ASC';
    } else if (orderBy == 'Descripción Desc') {
      order = 'description DESC';
    } else { // Ordenar por fecha descendente por defecto o si se elige 'Fecha Desc'
      order = 'date DESC';
    }


    // Consulta todos los registros de la tabla 'expenses' con filtro y ordenamiento opcionales.
    List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: order // Aplica el ordenamiento
    );

    // Convierte los resultados de la base de datos a una lista de objetos Expense
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Actualiza la información de un gasto que ya existe
  Future<int> updateExpense(Expense expense) async {
    Database db = await database;
    // Busca el gasto por su ID y actualiza sus datos
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?', // Busca el gasto con este ID
      whereArgs: [expense.id], // El valor del ID a buscar
    );
  }

  // Borra un gasto de la base de datos usando su ID
  Future<int> deleteExpense(int id) async {
    Database db = await database;
    // Borra el gasto con el ID especificado
    return await db.delete(
      'expenses',
      where: 'id = ?', // Busca el gasto con este ID
      whereArgs: [id], // El valor del ID a borrar
    );
  }
}
