import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database.dart';
import 'lista_pedidos_page.dart';

void main() {
  runApp(const MyApp());
}

// ======================================
//      APLICACIÓN PRINCIPAL
// ======================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    cargarTema();
  }

  Future<void> cargarTema() async {
    final prefs = await SharedPreferences.getInstance();
    final oscuro = prefs.getBool("modoOscuro") ?? true;

    setState(() {
      themeMode = oscuro ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> cambiarTema() async {
    final prefs = await SharedPreferences.getInstance();
    final activarOscuro = themeMode == ThemeMode.light;

    await prefs.setBool("modoOscuro", activarOscuro);

    setState(() {
      themeMode = activarOscuro ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cybernetic FoodPlease",
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F0F4),
        brightness: Brightness.light,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 3,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A0A14),
        brightness: Brightness.dark,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F111A),
          elevation: 3,
          titleTextStyle: TextStyle(
            color: Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          iconTheme: IconThemeData(color: Color(0xFF00E5FF)),
        ),
      ),
      home: PedidoPage(toggleTheme: cambiarTema),
    );
  }
}

// ======================================
//         ESTILO GLOBAL
// ======================================
Color cyText = const Color(0xFF00E5FF);
Color cyBorder = const Color(0xFF00BCD4);
Color cyGreen = const Color(0xFF03E676);
Color cyYellow = const Color(0xFFFFD54F);
Color cyBlue = const Color(0xFF1976D2);

// ======================================
//          PÁGINA PRINCIPAL
// ======================================
class PedidoPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const PedidoPage({super.key, required this.toggleTheme});

  @override
  State<PedidoPage> createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController mesaController = TextEditingController();

  List<String> comidasSeleccionadas = ['Pizza'];

  // 💰 PRECIOS
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

  void msg(String texto) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // SUMA AUTOMÁTICA
  void actualizarPrecioTotal() {
    int total = 0;
    for (var comida in comidasSeleccionadas) {
      total += precios[comida] ?? 0;
    }
    precioController.text = total.toString();
    setState(() {});
  }

  void limpiarCampos() {
    setState(() {
      nombreController.clear();
      precioController.clear();
      mesaController.clear();
      comidasSeleccionadas = ["Pizza"];
    });

    msg("Formulario limpiado");
  }

  Future<void> agregarPedido() async {
    if (nombreController.text.isEmpty) return msg("Ingrese un nombre");
    if (mesaController.text.isEmpty) return msg("Ingrese número de mesa");

    if (precioController.text.isEmpty ||
        double.tryParse(precioController.text) == null) {
      return msg("Error calculando precio total");
    }

    await DBFood.agregarPedido(
      nombreController.text,
      comidasSeleccionadas.join(", "),
      double.parse(precioController.text),
      mesaController.text,
    );

    limpiarCampos();
    msg("Pedido guardado");
  }

  InputDecoration inputNeon(String hint, bool oscuro) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: oscuro ? cyText.withOpacity(0.5) : Colors.black54,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: oscuro ? cyBorder : Colors.black,
          width: 1.7,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: oscuro ? cyText : Colors.black,
          width: 2.5,
        ),
      ),
    );
  }

  Widget botonNeon(Color color, IconData icon, VoidCallback onTap, bool oscuro) {
    final borderColor = oscuro ? color : Colors.black;
    final iconColor = oscuro ? color : Colors.black;

    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 26),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool oscuro = Theme.of(context).brightness == Brightness.dark;

    final Color txt = oscuro ? cyText : Colors.black;
    final Color borde = oscuro ? cyBorder : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cybernetic FoodPlease"),
        actions: [
          IconButton(
            icon: Icon(oscuro ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CLIENTE
            Text("NOMBRE DEL CLIENTE", style: TextStyle(color: txt, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: nombreController,
              style: TextStyle(color: txt),
              decoration: inputNeon("Ej: Juan Pérez", oscuro),
            ),

            const SizedBox(height: 20),

            // MESA
            Text("NÚMERO DE MESA", style: TextStyle(color: txt, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: mesaController,
              style: TextStyle(color: txt),
              keyboardType: TextInputType.number,
              decoration: inputNeon("Ej: 12", oscuro),
            ),

            const SizedBox(height: 25),

            // COMIDAS
            Text("SELECCIONA LA(S) COMIDA(S)",
                style: TextStyle(color: txt, fontSize: 14)),
            const SizedBox(height: 6),

            Column(
              children: List.generate(comidasSeleccionadas.length, (index) {
                return Container(
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
                          style: TextStyle(color: txt),
                          underline: Container(),
                          items: opcionesComida.map((op) {
                            final nombre = op["nombre"]!;
                            final int precio = precios[nombre]!;
                            return DropdownMenuItem(
                              value: nombre,
                              child: Row(
                                children: [
                                  Image.asset(op["img"]!,
                                      width: 25, height: 25),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$nombre  —  \$$precio",
                                    style: TextStyle(color: txt),
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
                        icon: Icon(
                          Icons.delete,
                          color: oscuro ? Colors.redAccent : Colors.black,
                          size: 26,
                        ),
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

            Center(
              child: botonNeon(
                cyText,
                Icons.add,
                () {
                  if (comidasSeleccionadas.length >= 4) {
                    return msg("Máximo permitido: 4 comidas");
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

            // PRECIO
            Text("PRECIO TOTAL", style: TextStyle(color: txt, fontSize: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              readOnly: true,
              style: TextStyle(color: txt),
              decoration: inputNeon("Calculado automáticamente", oscuro),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                botonNeon(cyGreen, Icons.check, agregarPedido, oscuro),
                const SizedBox(width: 12),
                botonNeon(cyYellow, Icons.cleaning_services, limpiarCampos, oscuro),
                const SizedBox(width: 12),
                botonNeon(cyBlue, Icons.list, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ListaPedidosPage(toggleTheme: widget.toggleTheme),
                    ),
                  );
                }, oscuro),
              ],
            ),

            const SizedBox(height: 40),

            // ==========================================
            //            FIRMA FINAL GRUPO 7 😎
            // ==========================================
            Center(
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
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
                  const SizedBox(height: 4),
                  Text(
                    "Taller de Desarrollo Web y Móvil",
                    style: TextStyle(
                      color: txt,
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
