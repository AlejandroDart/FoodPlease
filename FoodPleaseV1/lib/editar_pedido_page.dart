import 'package:flutter/material.dart';
import 'database.dart';

// Colores neón globales (solo modo oscuro)
const Color cyText = Color(0xFF00E5FF);
const Color cyBorder = Color(0xFF00BCD4);
const Color cyGreen = Color(0xFF03E676);
const Color cyYellow = Color(0xFFFFD54F);
const Color cyRed = Color(0xFFFF5555);

class EditarPedidoPage extends StatefulWidget {
  final Map<String, dynamic> pedido;
  final VoidCallback toggleTheme;

  const EditarPedidoPage({
    super.key,
    required this.pedido,
    required this.toggleTheme,
  });

  @override
  State<EditarPedidoPage> createState() => _EditarPedidoPageState();
}

class _EditarPedidoPageState extends State<EditarPedidoPage> {
  late TextEditingController nombreController;
  late TextEditingController precioController;
  late TextEditingController mesaController;

  List<String> comidasSeleccionadas = [];

  final Map<String, int> precios = {
    "Pizza": 8000,
    "Hamburguesa": 6500,
    "Completo": 3000,
    "Asado": 9000,
    "Empanadas": 1500,
    "Ensalada": 4500,
    "Papas Fritas": 2500,
  };

  final List<Map<String, String>> opcionesComida = [
    {"nombre": "Pizza", "img": "assets/comidas/pizza.png"},
    {"nombre": "Hamburguesa", "img": "assets/comidas/hamburguesa.png"},
    {"nombre": "Completo", "img": "assets/comidas/completo.png"},
    {"nombre": "Asado", "img": "assets/comidas/asado.png"},
    {"nombre": "Empanadas", "img": "assets/comidas/empanadas.png"},
    {"nombre": "Ensalada", "img": "assets/comidas/ensalada.png"},
    {"nombre": "Papas Fritas", "img": "assets/comidas/papas_fritas.png"},
  ];

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(text: widget.pedido["cliente"]);
    precioController =
        TextEditingController(text: widget.pedido["precio"].toString());
    mesaController = TextEditingController(text: widget.pedido["mesa"]);

    comidasSeleccionadas = widget.pedido["comida"]
        .toString()
        .split(",")
        .map((e) => e.trim())
        .toList();

    if (comidasSeleccionadas.isEmpty) comidasSeleccionadas = ["Pizza"];

    Future.delayed(const Duration(milliseconds: 100), () {
      actualizarPrecioTotal();
    });
  }

  void msg(String t) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  void actualizarPrecioTotal() {
    int total = 0;
    for (var comida in comidasSeleccionadas) {
      total += precios[comida] ?? 0;
    }
    precioController.text = total.toString();
    setState(() {});
  }

  Future<void> guardarCambios() async {
    if (nombreController.text.isEmpty) return msg("Ingrese un nombre");
    if (mesaController.text.isEmpty) return msg("Ingrese número de mesa");

    final id = widget.pedido["id"];
    final cliente = nombreController.text;
    final comidaFinal = comidasSeleccionadas.join(", ");
    final precio = double.parse(precioController.text);
    final mesa = mesaController.text;

    await DBFood.actualizarPedido(id, cliente, comidaFinal, precio, mesa);

    msg("Pedido actualizado");
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  InputDecoration inputNeon(String hint, bool oscuro) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: oscuro ? cyText.withOpacity(0.5) : Colors.black54),
      enabledBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: oscuro ? cyBorder : Colors.black, width: 1.7),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: oscuro ? cyText : Colors.black, width: 2.4),
      ),
    );
  }

  Widget botonNeon(Color color, IconData icon, VoidCallback onTap, bool oscuro,
      {double w = 55}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: w,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: oscuro ? color : Colors.black, width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: oscuro ? color : Colors.black, size: 26),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool oscuro = Theme.of(context).brightness == Brightness.dark;

    final Color texto = oscuro ? cyText : Colors.black;
    final Color borde = oscuro ? cyBorder : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Pedido",
            style: TextStyle(color: texto, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: texto),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon:
                Icon(oscuro ? Icons.light_mode : Icons.dark_mode, color: texto),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NOMBRE
            Text("NOMBRE DEL CLIENTE",
                style: TextStyle(color: texto, letterSpacing: 1)),
            const SizedBox(height: 6),
            TextField(
              controller: nombreController,
              style: TextStyle(color: texto),
              decoration: inputNeon("Ej: Juan Pérez", oscuro),
            ),

            const SizedBox(height: 25),

            // MESA
            Text("NÚMERO DE MESA",
                style: TextStyle(color: texto, letterSpacing: 1)),
            const SizedBox(height: 6),
            TextField(
              controller: mesaController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: texto),
              decoration: inputNeon("Ej: 12", oscuro),
            ),

            const SizedBox(height: 25),

            // COMIDAS
            Text("EDITAR COMIDA(S)",
                style: TextStyle(color: texto, letterSpacing: 1)),
            const SizedBox(height: 6),

            Column(
              children: List.generate(comidasSeleccionadas.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: borde, width: 1.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: comidasSeleccionadas[index],
                          isExpanded: true,
                          dropdownColor:
                              oscuro ? const Color(0xFF0F111A) : Colors.white,
                          style: TextStyle(color: texto),
                          underline: Container(),
                          items: opcionesComida.map((op) {
                            final nombre = op["nombre"]!;
                            final precio = precios[nombre]!;

                            return DropdownMenuItem(
                              value: nombre,
                              child: Row(
                                children: [
                                  Image.asset(op["img"]!,
                                      width: 28, height: 28),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$nombre — \$$precio",
                                    style: TextStyle(color: texto),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (nuevo) {
                            setState(() {
                              comidasSeleccionadas[index] = nuevo!;
                              actualizarPrecioTotal();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.delete,
                            size: 26, color: oscuro ? cyRed : Colors.black),
                        onPressed: () {
                          if (comidasSeleccionadas.length <= 1) {
                            msg("Debe haber al menos una comida");
                            return;
                          }
                          setState(() {
                            comidasSeleccionadas.removeAt(index);
                            actualizarPrecioTotal();
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),

            // BOTÓN AÑADIR
            Center(
              child: botonNeon(
                cyText,
                Icons.add,
                () {
                  if (comidasSeleccionadas.length >= 4) {
                    return msg("Máximo 4 comidas por pedido");
                  }
                  setState(() {
                    comidasSeleccionadas.add("Pizza");
                    actualizarPrecioTotal();
                  });
                },
                oscuro,
              ),
            ),

            const SizedBox(height: 25),

            Text("PRECIO TOTAL",
                style: TextStyle(color: texto, letterSpacing: 1)),
            const SizedBox(height: 6),

            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              readOnly: true,
              style: TextStyle(color: texto),
              decoration: inputNeon("Valor calculado automáticamente", oscuro),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                botonNeon(
                  cyYellow,
                  Icons.close,
                  () => Navigator.pop(context),
                  oscuro,
                  w: 120,
                ),
                const SizedBox(width: 18),
                botonNeon(
                  cyGreen,
                  Icons.check,
                  guardarCambios,
                  oscuro,
                  w: 120,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ⭐ FIRMA — SOLO "Grupo 7" en verde si es oscuro
            Center(
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: texto,
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
                  const SizedBox(height: 4),
                  Text(
                    "Taller de Desarrollo Web y Móvil",
                    style: TextStyle(
                      color: texto,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
