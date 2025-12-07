from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
import os
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Crear ruta absoluta para evitar errores
DB_NAME = os.path.join(os.path.dirname(os.path.abspath(__file__)), "foodplease.db")

# ======================================================
#        CREAR BASE DE DATOS SI NO EXISTE
# ======================================================
def iniciar_bd():
    primera_vez = not os.path.exists(DB_NAME)

    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()

    # Tabla de meseros
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS meseros (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
        );
    """)

    # Usuario inicial
    if primera_vez:
        cursor.execute("""
            INSERT INTO meseros (usuario, password)
            VALUES ("mesero1", "mesero1");
        """)
        print("✔ Usuario inicial 'mesero1' creado")

    # Tabla de pedidos
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS pedidos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente TEXT NOT NULL,
            comida TEXT NOT NULL,
            precio REAL NOT NULL,
            fecha TEXT NOT NULL,
            mesa TEXT NOT NULL,
            estado TEXT NOT NULL DEFAULT 'pendiente',
            mesero_id INTEGER NOT NULL,
            FOREIGN KEY (mesero_id) REFERENCES meseros(id)
        );
    """)

    conn.commit()

    # ======================================================
    #   SI NO HAY PEDIDOS, CREAR UNO POR DEFECTO
    # ======================================================
    cursor.execute("SELECT COUNT(*) as total FROM pedidos")
    total = cursor.fetchone()[0]

    if total == 0:
        print("✔ No hay pedidos. Creando pedido inicial...")

        # obtener id del mesero1
        cursor.execute("SELECT id FROM meseros WHERE usuario = 'mesero1'")
        mesero = cursor.fetchone()

        if not mesero:
            # por seguridad, crear usuario nuevamente si no existe
            cursor.execute("INSERT INTO meseros (usuario, password) VALUES ('mesero1', 'mesero1')")
            conn.commit()
            cursor.execute("SELECT id FROM meseros WHERE usuario = 'mesero1'")
            mesero = cursor.fetchone()

        mesero_id = mesero[0]

        cursor.execute("""
            INSERT INTO pedidos (cliente, comida, precio, fecha, mesa, estado, mesero_id)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (
            "Cliente Ejemplo",
            "Pizza, Papas Fritas",
            10500,
            datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "1",
            "pendiente",
            mesero_id
        ))

        print("✔ Pedido inicial creado")

    conn.commit()
    conn.close()
    print("✔ Base de datos lista")


# Ejecutar al iniciar
iniciar_bd()


# ======================================================
#              CONEXIÓN A LA BD
# ======================================================
def get_db():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    return conn


# ======================================================
#                     LOGIN
# ======================================================
@app.route("/login", methods=["POST"])
def login():
    data = request.json
    user = data.get("user")
    password = data.get("password")

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, usuario FROM meseros
        WHERE usuario = ? AND password = ?
    """, (user, password))

    mesero = cursor.fetchone()

    if mesero:
        return jsonify({
            "status": "ok",
            "mesero_id": mesero["id"],
            "usuario": mesero["usuario"]
        })

    return jsonify({"status": "error", "message": "Credenciales incorrectas"}), 401


# ======================================================
#            OBTENER PEDIDOS DEL MESERO
# ======================================================
@app.route("/pedidos/<int:mesero_id>", methods=["GET"])
def obtener_pedidos(mesero_id):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT * FROM pedidos
        WHERE mesero_id = ?
        ORDER BY id DESC
    """, (mesero_id,))

    pedidos = [dict(row) for row in cursor.fetchall()]

    return jsonify(pedidos)


# ======================================================
#                 AGREGAR PEDIDO
# ======================================================
@app.route("/pedido", methods=["POST"])
def agregar_pedido():
    data = request.json

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO pedidos (cliente, comida, precio, fecha, mesa, estado, mesero_id)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (
        data["cliente"],
        data["comida"],
        data["precio"],
        data["fecha"],
        data["mesa"],
        data.get("estado", "pendiente"),
        data["mesero_id"]
    ))

    conn.commit()
    return jsonify({"status": "ok", "message": "Pedido agregado"})


# ======================================================
#                 ACTUALIZAR PEDIDO
# ======================================================
@app.route("/pedido/<int:id>", methods=["PUT"])
def actualizar_pedido(id):
    data = request.json

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE pedidos
        SET cliente = ?, comida = ?, precio = ?, mesa = ?
        WHERE id = ?
    """, (
        data["cliente"],
        data["comida"],
        data["precio"],
        data["mesa"],
        id
    ))

    conn.commit()

    return jsonify({"status": "ok", "message": "Pedido actualizado"})


# ======================================================
#                 CONFIRMAR PEDIDO
# ======================================================
@app.route("/pedido/<int:id>/confirmar", methods=["PUT"])
def confirmar_pedido(id):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE pedidos
        SET estado = 'confirmado'
        WHERE id = ?
    """, (id,))

    conn.commit()

    return jsonify({"status": "ok"})


# ======================================================
#                 ELIMINAR PEDIDO
# ======================================================
@app.route("/pedido/<int:id>", methods=["DELETE"])
def eliminar_pedido(id):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("DELETE FROM pedidos WHERE id = ?", (id,))
    conn.commit()

    return jsonify({"status": "ok", "message": "Pedido eliminado"})


# ======================================================
#          ARRANCAR SERVIDOR
# ======================================================
if __name__ == "__main__":
    print("🚀 API FoodPlease corriendo en: http://0.0.0.0:5000")
    app.run(host="0.0.0.0", port=5000)
