import 'package:flutter/material.dart';
import 'database.dart';
import 'package:intl/intl.dart';
import 'editar_pedido_page.dart';

// COLORES NEÓN SOLO PARA MODO OSCURO
const Color cyText = Color(0xFF00E5FF);
const Color cyBorder = Color(0xFF00BCD4);
const Color cyRed = Color(0xFFFF5555);
const Color cyEdit = Color(0xFF00E5FF);
const Color cyGreen = Color(0xFF03E676); // verde para cliente, mesa y firma

class ListaPedidosPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const ListaPedidosPage({super.key, required this.toggleTheme});

  @override
  State<ListaPedidosPage> createState() => _ListaPedidosPageState();
}

class _ListaPedidosPageState extends State<ListaPedidosPage> {
  List<Map<String, dynamic>> pedidos = [];

  final NumberFormat formatter = NumberFormat('#,###', 'es_CL');

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
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    pedidos = await DBFood.obtenerPedidos();
    setState(() {});
  }

  Future<void> confirmarEliminacion(int id) async {
    final bool oscuro = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: oscuro ? const Color(0xFF0F111A) : Colors.white,
          title: Text(
            "Confirmar eliminación",
            style: TextStyle(color: oscuro ? cyText : Colors.black),
          ),
          content: Text(
            "¿Seguro que deseas eliminar este pedido?",
            style: TextStyle(color: oscuro ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              child: Text("Cancelar",
                  style: TextStyle(color: oscuro ? Colors.white : Colors.black)),
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

  Future<void> eliminarPedido(int id) async {
    await DBFood.eliminarPedido(id);
    await cargarDatos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pedido eliminado")),
    );
  }

  Widget buildLeadingIcon(String comidaTexto, bool oscuro) {
    List<String> lista = comidaTexto.split(",").map((e) => e.trim()).toList();

    if (lista.length > 1) {
      return Icon(Icons.restaurant_menu,
          size: 45, color: oscuro ? cyText : Colors.black);
    }

    final String comida = lista.first;
    final ruta = imagenesComida[comida];

    if (ruta == null) {
      return Icon(Icons.fastfood,
          size: 45, color: oscuro ? cyText : Colors.black);
    }

    return Image.asset(ruta, width: 50, height: 50);
  }

  @override
  Widget build(BuildContext context) {
    final bool oscuro = Theme.of(context).brightness == Brightness.dark;
    final Color txt = oscuro ? cyText : Colors.black;
    final Color borde = oscuro ? cyBorder : Colors.black;

    return Theme(
      data: Theme.of(context),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: Container(
          key: ValueKey(oscuro), // fuerza el rebuild con animación
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Listado de Pedidos"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(oscuro ? Icons.light_mode : Icons.dark_mode),
                  onPressed: widget.toggleTheme,
                )
              ],
            ),

            body: Column(
              children: [
                Expanded(
                  child: pedidos.isEmpty
                      ? Center(
                          child: Text(
                            "No hay pedidos",
                            style: TextStyle(color: txt, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: pedidos.length,
                          itemBuilder: (_, index) {
                            final item = pedidos[index];
                            final fecha = DateTime.parse(item["fecha"]);
                            final String comidas = item["comida"];
                            final String precioFormateado =
                                "\$${formatter.format(item["precio"])}";

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: oscuro
                                    ? const Color(0xFF0F111A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borde, width: 1.7),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLeadingIcon(comidas, oscuro),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Cliente: ",
                                                style: TextStyle(
                                                    color: txt,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: item['cliente'],
                                                style: TextStyle(
                                                  color: oscuro
                                                      ? cyGreen
                                                      : Colors.black,
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
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              TextSpan(
                                                text: item["mesa"],
                                                style: TextStyle(
                                                  color: oscuro
                                                      ? cyGreen
                                                      : Colors.black,
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
                                              color:
                                                  txt.withOpacity(0.7)),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: oscuro
                                                ? cyEdit
                                                : Colors.blue),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  EditarPedidoPage(
                                                pedido: item,
                                                toggleTheme:
                                                    widget.toggleTheme,
                                              ),
                                            ),
                                          ).then((_) => cargarDatos());
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: oscuro
                                                ? cyRed
                                                : Colors.red),
                                        onPressed: () =>
                                            confirmarEliminacion(
                                                item["id"]),
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

                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: txt,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    children: [
                      const TextSpan(text: "Desarrollado por "),
                      TextSpan(
                        text: "Grupo 7",
                        style: TextStyle(
                          color: oscuro ? cyGreen : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: " 😎"),
                    ],
                  ),
                ),

                Text("Taller de Desarrollo Web y Móvil",
                    style: TextStyle(
                        color: txt, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
