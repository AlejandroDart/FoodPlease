import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBFood {
  static Database? _db;

  // ======================================================
  // ABRIR / CREAR BASE DE DATOS
  // ======================================================
  static Future<Database> getDB() async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'foodplease.db');

    _db = await openDatabase(
      path,
      version: 3, // 👈 Versión actual con mesa incluida
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE pedidos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente TEXT NOT NULL,
            comida TEXT NOT NULL,
            precio REAL NOT NULL,
            fecha TEXT NOT NULL,
            mesa TEXT NOT NULL      -- 👈 NUEVO CAMPO (mesa)
          )
        """);
      },

      // Actualizaciones automáticas
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE pedidos ADD COLUMN precio REAL;");
          await db.execute("ALTER TABLE pedidos ADD COLUMN fecha TEXT;");
        }
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE pedidos ADD COLUMN mesa TEXT;");
        }
      },
    );

    return _db!;
  }

  // ======================================================
  // INSERTAR PEDIDO
  // ======================================================
  static Future<void> agregarPedido(
    String cliente,
    String comida,
    double precio,
    String mesa,
  ) async {
    final db = await getDB();

    String fechaAhora = DateTime.now().toIso8601String();

    await db.insert("pedidos", {
      "cliente": cliente,
      "comida": comida,
      "precio": precio,
      "fecha": fechaAhora,
      "mesa": mesa, // 👈 Guardado
    });
  }

  // ======================================================
  // OBTENER LISTA DE PEDIDOS
  // ======================================================
  static Future<List<Map<String, dynamic>>> obtenerPedidos() async {
    final db = await getDB();
    return db.query(
      "pedidos",
      orderBy: "id DESC",
    );
  }

  // ======================================================
  // ELIMINAR PEDIDO
  // ======================================================
  static Future<void> eliminarPedido(int id) async {
    final db = await getDB();
    await db.delete("pedidos", where: "id = ?", whereArgs: [id]);
  }

  // ======================================================
  // ACTUALIZAR PEDIDO
  // ======================================================
  static Future<void> actualizarPedido(
    int id,
    String cliente,
    String comida,
    double precio,
    String mesa,
  ) async {
    final db = await getDB();

    await db.update(
      "pedidos",
      {
        "cliente": cliente,
        "comida": comida,
        "precio": precio,
        "mesa": mesa, // 👈 Actualizado
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
