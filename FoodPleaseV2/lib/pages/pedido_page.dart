import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'login_page.dart';
import 'lista_pedidos_page.dart';
import 'mi_dinero_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/colors.dart';
import '../utils/config.dart';

// ======================================
//         ESTILO GLOBAL (COLORES)
// ======================================

void main() {
  runApp(const MyApp());
}

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
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A0A14),
        brightness: Brightness.dark,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F111A),
          elevation: 3,
        ),
      ),
      home: LoginPage(toggleTheme: cambiarTema),
    );
  }
}

// ======================================
//          PÁGINA PRINCIPAL
// ======================================
class PedidoPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final int meseroId;

  const PedidoPage({
    super.key,
    required this.toggleTheme,
    required this.meseroId,
  });

  @override
  State<PedidoPage> createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController mesaController = TextEditingController();

  List<String> comidasSeleccionadas = ['Pizza'];

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

  // ======================================================
  //                 ESCANEAR QR
  // ======================================================
  Future<void> escanearQR() async {
    try {
      var result = await BarcodeScanner.scan();
      String valor = result.rawContent.trim();

      if (valor.isEmpty) return;
      if (!RegExp(r'^[0-9]+$').hasMatch(valor)) {
        return msg("Código QR inválido");
      }

      setState(() => mesaController.text = valor);
    } catch (e) {
      msg("Error al escanear QR");
    }
  }

  // ======================================================
  void msg(String texto) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // ======================================================
  void actualizarPrecioTotal() {
    int total = comidasSeleccionadas.fold(
        0, (sum, comida) => sum + (precios[comida] ?? 0));
    precioController.text = total.toString();
    setState(() {});
  }

  // ======================================================
  void limpiarCampos() {
    setState(() {
      nombreController.clear();
      mesaController.clear();
      precioController.clear();
      comidasSeleccionadas = ["Pizza"];
    });
    msg("Formulario limpiado");
  }

  // ======================================================
  Future<void> agregarPedido() async {
    // 🔥 Validar nombre
    if (nombreController.text.isEmpty) {
      return msg("Ingrese un nombre");
    }

    // 🔥 Validar mesa
    if (mesaController.text.isEmpty) {
      return msg("Ingrese número de mesa");
    }

    // 🔥 Validación combinada de comida y precio
    if (comidasSeleccionadas.any((c) => c.trim().isEmpty) ||
        precioController.text.isEmpty ||
        double.tryParse(precioController.text) == null ||
        double.parse(precioController.text) <= 0) {
      return msg("Seleccione al menos una comida");
    }

    // Construir URL correcta
    final url = Uri.parse(apiPedido);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "cliente": nombreController.text,
          "comida": comidasSeleccionadas.join(", "),
          "precio": double.parse(precioController.text),
          "fecha": DateTime.now().toIso8601String(),
          "mesa": mesaController.text,
          "mesero_id": widget.meseroId,
        }),
      );

      if (response.statusCode == 200) {
        limpiarCampos();
        msg("Pedido agregado correctamente");
      } else {
        msg("Error al guardar pedido");
      }
    } catch (e) {
      msg("No hay conexión con el servidor");
    }
  }

  // ======================================================
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
            BorderSide(color: oscuro ? cyText : Colors.black, width: 2.5),
      ),
    );
  }

  // ======================================================
  Widget botonNeon(
      Color color, IconData icon, VoidCallback onTap, bool oscuro) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: oscuro ? color : Colors.black, width: 2),
      ),
      child: IconButton(
        icon: Icon(icon, color: oscuro ? color : Colors.black, size: 26),
        onPressed: onTap,
      ),
    );
  }

  // ======================================================
//                        UI
// ======================================================
  @override
  Widget build(BuildContext context) {
    final bool oscuro = Theme.of(context).brightness == Brightness.dark;
    final Color txt = oscuro ? cyText : Colors.black;
    final Color borde = oscuro ? cyBorder : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cybernetic FoodPlease"),
        actions: [
          // ======================================================
          //              BOTÓN CAMBIAR TEMA
          // ======================================================
          IconButton(
            icon: Icon(oscuro ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),

          // ======================================================
          //                  BOTÓN LOG OUT
          // ======================================================
          IconButton(
            icon: Icon(Icons.logout, color: oscuro ? cyRed : Colors.red),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              FocusScope.of(context).unfocus();
              FocusScope.of(context).requestFocus(FocusNode());

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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            FocusScope.of(context).unfocus(), // 🔥 OCULTA TECLADO SIEMPRE

        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              //                  CAMPOS DEL FORMULARIO
              // ======================================================
              Text("NOMBRE DEL CLIENTE",
                  style: TextStyle(color: txt, fontSize: 14)),
              const SizedBox(height: 6),
              TextField(
                controller: nombreController,
                style: TextStyle(color: txt),
                textCapitalization: TextCapitalization
                    .sentences, // Mayúscula inicial automática
                decoration: inputNeon("Ej: Juan Pérez", oscuro),

                onChanged: (value) {
                  if (value.isEmpty) return;

                  // Si el texto termina con un espacio, esperar la siguiente letra
                  if (value.endsWith(" ")) return;

                  // Convertir siempre la primera letra en mayúscula
                  if (value.length == 1) {
                    nombreController.text = value.toUpperCase();
                    nombreController.selection = TextSelection.collapsed(
                        offset: nombreController.text.length);
                    return;
                  }

                  // Detectar si después de un espacio viene una minúscula → convertirla
                  if (value.length >= 2) {
                    String penultimo = value[value.length - 2];
                    String ultimo = value[value.length - 1];

                    if (penultimo == " " && ultimo.toLowerCase() == ultimo) {
                      String nuevoTexto = value.substring(0, value.length - 1) +
                          ultimo.toUpperCase();

                      nombreController.text = nuevoTexto;
                      nombreController.selection =
                          TextSelection.collapsed(offset: nuevoTexto.length);
                    }
                  }
                },
              ),

              const SizedBox(height: 20),

              Text("NÚMERO DE MESA",
                  style: TextStyle(color: txt, fontSize: 14)),
              const SizedBox(height: 6),

              TextField(
                controller: mesaController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: txt),
                decoration: inputNeon("Ej: 12", oscuro).copyWith(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(
                        right: 12), // 👈 mueve el icono a la izquierda
                    child: IconButton(
                      icon: Icon(
                        Icons.qr_code_scanner,
                        color: oscuro ? cyGreen : Colors.black,
                      ),
                      onPressed: escanearQR,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ======================================================
              //                SELECCIÓN DE COMIDAS
              // ======================================================
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
                                    Text("$nombre — \$$precio",
                                        style: TextStyle(color: txt)),
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
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: oscuro ? Colors.redAccent : Colors.black),
                          onPressed: () {
                            if (comidasSeleccionadas.length <= 1) {
                              return msg("Debe haber al menos una comida");
                            }
                            setState(() {
                              comidasSeleccionadas.removeAt(index);
                              actualizarPrecioTotal();
                            });
                          },
                        )
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
                    comidasSeleccionadas.add("Pizza");
                    actualizarPrecioTotal();
                    setState(() {});
                  },
                  oscuro,
                ),
              ),

              const SizedBox(height: 25),

              // ======================================================
              //                  PRECIO TOTAL
              // ======================================================
              Text("PRECIO TOTAL", style: TextStyle(color: txt, fontSize: 14)),
              const SizedBox(height: 6),
              TextField(
                controller: precioController,
                readOnly: true,
                keyboardType: TextInputType.number,
                style: TextStyle(color: txt),
                decoration: inputNeon("Calculado automáticamente", oscuro),
              ),

              const SizedBox(height: 30),

              // ======================================================
              //                     BOTONES
              // ======================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  botonNeon(cyGreen, Icons.check, agregarPedido, oscuro),
                  const SizedBox(width: 12),
                  botonNeon(
                      cyYellow, Icons.cleaning_services, limpiarCampos, oscuro),
                  const SizedBox(width: 12),
                  botonNeon(
                    cyBlue,
                    Icons.list,
                    () {
                      FocusScope.of(context).unfocus();
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListaPedidosPage(
                              toggleTheme: widget.toggleTheme,
                              meseroId: widget.meseroId),
                        ),
                      );
                    },
                    oscuro,
                  ),
                  const SizedBox(width: 12),
                  botonNeon(
                    cyGreen,
                    Icons.attach_money,
                    () {
                      FocusScope.of(context).unfocus();
                      FocusScope.of(context).requestFocus(FocusNode());

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MiDineroPage(
                            toggleTheme: widget.toggleTheme,
                            meseroId: widget.meseroId,
                          ),
                        ),
                      );
                    },
                    oscuro,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ======================================================
              //                     FIRMA
              // ======================================================
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
      ),
    );
  }
}
