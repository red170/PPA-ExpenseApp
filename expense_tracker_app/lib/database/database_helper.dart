import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart'; // Define cómo se guarda un gasto
import '../models/budget.dart'; // Define cómo se guarda un presupuesto

// Esta clase ayuda a guardar, leer, actualizar y borrar los gastos y presupuestos en la base de datos
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

    // Abre la base de datos. Si no existe, onCreate se llama para crearla.
    return await openDatabase(
      path,
      version: 2, // La versión de la base de datos
      onCreate: _onCreate, // Función para crear las tablas la primera vez
      onUpgrade: _onUpgrade, // Función para actualizar la base de datos si la versión cambia
    );
  }

  // Crea las tablas 'expenses' y 'budgets' en la base de datos.
  Future<void> _onCreate(Database db, int version) async {
    // Crea la tabla de gastos
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
    // Crea la tabla de presupuestos
    await db.execute(
      '''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT UNIQUE, -- La categoría debe ser única para cada presupuesto
        amount REAL
      )
      ''',
    );
  }

  // Actualiza la base de datos si la versión cambia (para añadir nuevas tablas, etc.)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Si la versión anterior es 1 y la nueva es 2, significa que estamos añadiendo la tabla 'budgets'
    if (oldVersion < 2) {
      await db.execute(
        '''
        CREATE TABLE budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT UNIQUE,
          amount REAL
        )
        ''',
      );
    }
    // Si hay futuras versiones, añadir más bloques 'if' aquí
  }

  // --- Métodos para Gastos ---

  // Guarda un nuevo gasto en la base de datos
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    // Inserta el gasto. conflictAlgorithm reemplaza si hay conflicto de ID.
    return await db.insert('expenses', expense.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Obtiene todos los gastos guardados en la base de datos
  // Ahora acepta parámetros opcionales para filtrar por categoría, ordenar y buscar
  Future<List<Expense>> getExpenses({String? categoryFilter, String? orderBy, String? searchQuery}) async {
    Database db = await database;

    // Lista para construir las condiciones WHERE
    List<String> whereParts = [];
    List<dynamic> whereArgs = [];

    // Filtro por categoría
    if (categoryFilter != null && categoryFilter != 'Todas') {
      whereParts.add('category = ?');
      whereArgs.add(categoryFilter);
    }

    // Búsqueda por descripción o categoría
    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereParts.add('(description LIKE ? OR category LIKE ?)');
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    // Combina las partes de la cláusula WHERE
    String? whereClause = whereParts.isEmpty ? null : whereParts.join(' AND ');


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

    // Consulta todos los registros de la tabla 'expenses' con filtro, búsqueda y ordenamiento opcionales.
    List<Map<String, dynamic>> maps = await db.query(
        'expenses',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: order // Aplica el ordenamiento
    );

    // Convierte la lista de Maps a una lista de objetos Expense.
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Obtiene todos los gastos sin filtros ni ordenamiento (útil para exportar)
  Future<List<Expense>> getAllExpensesForExport() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('expenses', orderBy: 'date DESC');
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
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Elimina un gasto de la base de datos.
  Future<int> deleteExpense(int id) async {
    Database db = await database;
    // Elimina el gasto donde el ID coincide.
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Nuevos Métodos para Presupuestos ---

  // Guarda un nuevo presupuesto en la base de datos.
  Future<int> insertBudget(Budget budget) async {
    Database db = await database;
    // Inserta el presupuesto. Si la categoría ya existe, la actualiza.
    return await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Obtiene todos los presupuestos guardados.
  Future<List<Budget>> getBudgets() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('budgets');
    return List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });
  }

  // Actualiza un presupuesto existente.
  Future<int> updateBudget(Budget budget) async {
    Database db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  // Elimina un presupuesto por su ID.
  Future<int> deleteBudget(int id) async {
    Database db = await database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtiene el presupuesto para una categoría específica.
  Future<Budget?> getBudgetByCategory(String category) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'category = ?',
      whereArgs: [category],
    );
    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  // Obtiene el gasto total para una categoría en un mes y año específicos.
  Future<double> getTotalSpentByCategoryAndPeriod(String category, int month, int year) async {
    Database db = await database;
    // Formato de fecha usado en la base de datos es ISO 8601 (YYYY-MM-DDTHH:MM:SS.sss)
    // Filtramos por el año y mes.
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM expenses
      WHERE category = ? AND STRFTIME('%Y', date) = ? AND STRFTIME('%m', date) = ?
    ''', [category, year.toString(), month.toString().padLeft(2, '0')]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as double;
    }
    return 0.0;
  }

  // Obtiene el gasto total para todas las categorías en un mes y año específicos.
  Future<Map<String, double>> getMonthlyCategorySummary(int month, int year) async {
    Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM expenses
      WHERE STRFTIME('%Y', date) = ? AND STRFTIME('%m', date) = ?
      GROUP BY category
    ''', [year.toString(), month.toString().padLeft(2, '0')]);

    Map<String, double> summary = {};
    for (var row in result) {
      summary[row['category']] = row['total'] as double;
    }
    return summary;
  }
}
