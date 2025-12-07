import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'editar_pedido_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import '../utils/colors.dart';
import '../utils/config.dart';

class ListaPedidosPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final int meseroId;

  const ListaPedidosPage({
    super.key,
    required this.toggleTheme,
    required this.meseroId,
  });

  @override
  State<ListaPedidosPage> createState() => _ListaPedidosPageState();
}

class _ListaPedidosPageState extends State<ListaPedidosPage> {
  List<Map<String, dynamic>> pedidos = [];

  final NumberFormat formatter = NumberFormat('#,###', 'es_CL');

  String filtro = "todos"; // FILTRO GUARDADO LOCALMENTE

  // ------------------------
  // LISTA FILTRADA
  // ------------------------
  List<Map<String, dynamic>> get pedidosFiltrados {
    if (filtro == "todos") return pedidos;
    return pedidos
        .where((p) => (p["estado"] ?? "pendiente") == filtro)
        .toList();
  }

  final Map<String, String> imagenesComida = {
    "Pizza": "assets/comidas/pizza.png",
    "Hamburguesa": "assets/comidas/hamburguesa.png",
    "Completo": "assets/comidas/completo.png",
    "Asado": "assets/comidas/asado.png",
    "Empanadas": "assets/comidas/empanadas.png",
    "Ensalada": "assets/comidas/ensalada.png",
    "Papas Fritas": "assets/comidas/papas_fritas.png",
  };

  @override
  void initState() {
    super.initState();
    cargarFiltro().then((_) => cargarDatos());
  }

  // =====================================================
  //   FILTRO PERSISTENTE
  // =====================================================
  Future<void> guardarFiltro() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("filtroPedidos", filtro);
  }

  Future<void> cargarFiltro() async {
    final prefs = await SharedPreferences.getInstance();
    filtro = prefs.getString("filtroPedidos") ?? "todos";
    setState(() {});
  }

// =====================================================
//     CARGAR PEDIDOS DESDE LA API
// =====================================================
  Future<void> cargarDatos() async {
    try {
      
      final url = Uri.parse("$apiPedidos/${widget.meseroId}");
      final resp = await http.get(url).timeout(const Duration(seconds: 5));

      if (resp.statusCode == 200) {
        pedidos = List<Map<String, dynamic>>.from(jsonDecode(resp.body));
      } else {
        pedidos = [];
        // Mensaje si el servidor responde con error
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error de conexión con el servidor")),
        );
      }

      setState(() {});
    } catch (e) {
      // Error al conectar (timeout, servidor caído, IP incorrecta, etc.)
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con el servidor")),
      );

      pedidos = [];
      setState(() {});
    }
  }

  // =====================================================
  //   CONFIRMAR ELIMINACIÓN
  // =====================================================
  Future<void> confirmarEliminacion(int id) async {
    final bool oscuro = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: oscuro ? const Color(0xFF0F111A) : Colors.white,
          title: Text("Confirmar eliminación",
              style: TextStyle(color: oscuro ? cyText : Colors.black)),
          content: Text("¿Seguro que deseas eliminar este pedido?",
              style:
                  TextStyle(color: oscuro ? Colors.white70 : Colors.black87)),
          actions: [
            TextButton(
              child: Text("Cancelar",
                  style:
                      TextStyle(color: oscuro ? Colors.white : Colors.black)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Eliminar",
                  style: TextStyle(color: oscuro ? cyRed : Colors.red)),
              onPressed: () async {
                Navigator.pop(context);
                await eliminarPedido(id);
              },
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  //     ELIMINAR PEDIDO DESDE API
  // =====================================================
  Future<void> eliminarPedido(int id) async {
    final resp = await http.delete(Uri.parse("$apiPedido/$id"));

    if (resp.statusCode == 200) {
      cargarDatos();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pedido eliminado")),
      );
    }
  }

  // =====================================================
  //     CONFIRMAR PEDIDO DESDE API
  // =====================================================
  Future<void> confirmarPedido(int id) async {
    final resp = await http.put(Uri.parse("$apiPedido/$id/confirmar"));

    if (resp.statusCode == 200) {
      cargarDatos();
    }
  }

  // =====================================================
  //     ICONO SEGÚN COMIDA
  // =====================================================
  Widget buildLeadingIcon(String comidas, bool oscuro) {
    List<String> lista = comidas.split(",").map((e) => e.trim()).toList();

    if (lista.length > 1) {
      return Icon(Icons.restaurant_menu,
          size: 45, color: oscuro ? cyText : Colors.black);
    }

    final ruta = imagenesComida[lista.first];

    if (ruta == null) {
      return Icon(Icons.fastfood,
          size: 45, color: oscuro ? cyText : Colors.black);
    }

    return Image.asset(ruta, width: 50, height: 50);
  }

  // =====================================================
  //      BOTÓN DE FILTRO
  // =====================================================
  Widget filtroBoton(String value, String titulo, bool oscuro) {
    final bool activo = filtro == value;

    return GestureDetector(
      onTap: () async {
        setState(() => filtro = value);
        await guardarFiltro();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: activo
              ? (oscuro ? cyGreen.withOpacity(0.2) : Colors.green.shade100)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: activo
                ? (oscuro ? cyGreen : Colors.green)
                : (oscuro ? cyBorder : Colors.black),
            width: 1.7,
          ),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            color: activo
                ? (oscuro ? cyGreen : Colors.green.shade900)
                : (oscuro ? cyText : Colors.black),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

// =====================================================
//      INTERFAZ
// =====================================================
  @override
  Widget build(BuildContext context) {
    final bool oscuro = Theme.of(context).brightness == Brightness.dark;
    final Color txt = oscuro ? cyText : Colors.black;
    final Color borde = oscuro ? cyBorder : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Listado de Pedidos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Cambiar tema
          IconButton(
            icon: Icon(oscuro ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),

          // ===========================
          //       BOTÓN LOGOUT
          // ===========================
          IconButton(
            icon: Icon(
              Icons.logout,
              color: oscuro ? Colors.redAccent : Colors.red,
            ),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.pushAndRemoveUntil(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(
                  builder: (_) => LoginPage(toggleTheme: widget.toggleTheme),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // FILTROS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              filtroBoton("todos", "Todos", oscuro),
              filtroBoton("pendiente", "Pendientes", oscuro),
              filtroBoton("confirmado", "Confirmados", oscuro),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: pedidosFiltrados.isEmpty
                ? Center(
                    child: Text("No hay pedidos",
                        style: TextStyle(color: txt, fontSize: 16)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: pedidosFiltrados.length,
                    itemBuilder: (_, index) {
                      final item = pedidosFiltrados[index];

                      final fecha = DateTime.parse(item["fecha"]);
                      final comidas = item["comida"];
                      final precioFormateado =
                          "\$${formatter.format(item["precio"])}";

                      final estado = item["estado"] ?? "pendiente";
                      final bool confirmado =
                          estado.toLowerCase() == "confirmado";

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              oscuro ? const Color(0xFF0F111A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: confirmado ? cyGreen : borde,
                            width: 1.7,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLeadingIcon(comidas, oscuro),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Cliente: ",
                                          style: TextStyle(
                                              color: txt,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: item["cliente"],
                                          style: TextStyle(
                                            color: confirmado
                                                ? cyGreen
                                                : (oscuro
                                                    ? cyGreen
                                                    : Colors.black),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text: "Mesa: ",
                                            style: TextStyle(
                                                color: txt,
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                          text: item["mesa"],
                                          style: TextStyle(
                                            color: confirmado
                                                ? cyGreen
                                                : (oscuro
                                                    ? cyGreen
                                                    : Colors.black),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Comidas: $comidas",
                                      style: TextStyle(color: txt)),
                                  Text("Precio: $precioFormateado",
                                      style: TextStyle(color: txt)),
                                  Text(
                                    "Fecha: ${fecha.day}/${fecha.month}/${fecha.year}",
                                    style: TextStyle(
                                      color: txt.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Estado: ${confirmado ? "✔ Confirmado" : "Pendiente"}",
                                    style: TextStyle(
                                      color: confirmado ? cyGreen : cyRed,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                if (!confirmado)
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: oscuro ? cyText : Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditarPedidoPage(
                                            pedido: item,
                                            toggleTheme: widget.toggleTheme,
                                            meseroId: widget.meseroId,
                                          ),
                                        ),
                                      ).then((_) => cargarDatos());
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: oscuro ? cyRed : Colors.red,
                                  ),
                                  onPressed: () =>
                                      confirmarEliminacion(item["id"]),
                                ),
                                if (!confirmado)
                                  IconButton(
                                    icon: const Icon(Icons.receipt_long,
                                        color: Colors.amber),
                                    onPressed: () =>
                                        confirmarPedido(item["id"]),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
