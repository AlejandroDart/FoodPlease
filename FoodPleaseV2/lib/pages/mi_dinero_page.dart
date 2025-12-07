import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import '../utils/colors.dart';
import '../utils/config.dart';

class MiDineroPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final int meseroId;

  const MiDineroPage({
    super.key,
    required this.toggleTheme,
    required this.meseroId,
  });

  @override
  State<MiDineroPage> createState() => _MiDineroPageState();
}

class _MiDineroPageState extends State<MiDineroPage> {
  double propina = 0;
  double total = 0;
  int cantidadConfirmados = 0;

  @override
  void initState() {
    super.initState();
    calcularPropina();
  }

// ========================================================
//        CALCULAR PROPINA Y TOTAL DESDE LA API
// ========================================================
  Future<void> calcularPropina() async {
    try {
      final url = Uri.parse("$apiPedidos/${widget.meseroId}");
      final resp = await http.get(url).timeout(const Duration(seconds: 5));

      if (resp.statusCode != 200) {
        // Mensaje cuando el servidor responde con error
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).clearSnackBars();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error de conexión con el servidor")),
        );
        return;
      }

      final List<dynamic> pedidos = jsonDecode(resp.body);

      double suma = 0;
      int confirmados = 0;

      for (var p in pedidos) {
        if (p["estado"] == "confirmado") {
          suma += (p["precio"] as num).toDouble();
          confirmados++;
        }
      }

      setState(() {
        total = suma;
        propina = suma * 0.10; // 10%
        cantidadConfirmados = confirmados;
      });
    } catch (e) {
      // Error al conectar (sin wifi, servidor caído, timeout, etc.)
      // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        
        const SnackBar(content: Text("Error de conexión con el servidor")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool oscuro = Theme.of(context).brightness == Brightness.dark;
    final Color txt = oscuro ? cyText : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Dinero 💰"),
        actions: [
          // Cambiar tema
          IconButton(
            icon: Icon(oscuro ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),

          // ===========================
          //        BOTÓN LOGOUT
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Propina mínima del mesero (10%)",
              style: TextStyle(
                color: txt,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // Propina grande
            Text(
              "\$${propina.toStringAsFixed(0)}",
              style: TextStyle(
                color: oscuro ? cyGreen : Colors.green.shade700,
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // Total ventas confirmadas
            Text(
              "Ventas confirmadas: \$${total.toStringAsFixed(0)}",
              style: TextStyle(
                color: txt.withOpacity(0.8),
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            // Cantidad de pedidos
            Text(
              "Pedidos confirmados: $cantidadConfirmados",
              style: TextStyle(
                color: txt.withOpacity(0.8),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
