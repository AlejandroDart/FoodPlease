import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'pedido_page.dart';
import '../utils/colors.dart';
import '../utils/config.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const LoginPage({super.key, required this.toggleTheme});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool ocultar = true;
  bool cargando = false;
  bool recordar = false;

  @override
  void initState() {
    super.initState();
    cargarSesion();
  }

  // =======================================
  //        CARGAR SESIÓN GUARDADA
  // =======================================
  Future<void> cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    final guardado = prefs.getBool("recordar") ?? false;

    if (!guardado) return;

    final user = prefs.getString("user") ?? "";
    final pass = prefs.getString("pass") ?? "";

    if (user.isEmpty || pass.isEmpty) return;

    setState(() {
      userController.text = user;
      passController.text = pass;
      recordar = true;
    });

    Future.delayed(const Duration(milliseconds: 300), validarLogin);
  }

  Future<void> guardarSesion(String user, String pass) async {
    final prefs = await SharedPreferences.getInstance();

    if (recordar) {
      await prefs.setBool("recordar", true);
      await prefs.setString("user", user);
      await prefs.setString("pass", pass);
    } else {
      await prefs.remove("recordar");
      await prefs.remove("user");
      await prefs.remove("pass");
    }
  }

  void msg(String texto) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  InputDecoration inputNeon(String hint, bool oscuro) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: oscuro ? cyText.withOpacity(0.5) : Colors.black45),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: oscuro ? cyBorder : Colors.black,
          width: 1.7,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: oscuro ? cyText : Colors.black,
          width: 2.4,
        ),
      ),
    );
  }

  // =======================================
  //           VALIDAR LOGIN
  // =======================================
  Future<void> validarLogin() async {
    final user = userController.text.trim();
    final pass = passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      return msg("Ingrese usuario y contraseña");
    }

    setState(() => cargando = true);

    try {
      final respuesta = await http.post(
        Uri.parse(apiLogin),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user": user,
          "password": pass,
        }),
      );

      final data = jsonDecode(respuesta.body);

      if (respuesta.statusCode == 200 && data["status"] == "ok") {
        await guardarSesion(user, pass);

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (_) => PedidoPage(
              toggleTheme: widget.toggleTheme,
              meseroId: data["mesero_id"],
            ),
          ),
        );
      } else {
        msg("Usuario o contraseña incorrectos");
      }
    } catch (e) {
      msg("Error de conexión con el servidor");
    }

    setState(() => cargando = false);
  }

  // =======================================
  //              UI LOGIN
  // =======================================
  @override
  Widget build(BuildContext context) {
    final bool oscuro = Theme.of(context).brightness == Brightness.dark;
    final Color txt = oscuro ? cyText : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cybernetic - Iniciar Sesión", // ← ← ← TITULO CAMBIADO AQUÍ ✔
        ),
        actions: [
          IconButton(
            icon: Icon(oscuro ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          )
        ],
      ),

      // 🔥 Envuelve toda la pantalla para ocultar el teclado
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),

        child: Center(
          child: TickerMode(          // 💡 FIX DE ANIMACIÓN PARA EL ERROR elapsedInSeconds
            enabled: mounted,         // evita animaciones cuando la página ya no existe
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 120, color: txt),

                  const SizedBox(height: 20),

                  Text(
                    "Bienvenido Mesero",
                    style: TextStyle(
                      color: txt,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: userController,
                    style: TextStyle(color: txt),
                    decoration: inputNeon("Usuario", oscuro),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: passController,
                    obscureText: ocultar,
                    style: TextStyle(color: txt),
                    decoration: inputNeon("Contraseña", oscuro).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          ocultar ? Icons.visibility : Icons.visibility_off,
                          color: oscuro ? cyGreen : Colors.black,
                        ),
                        onPressed: () =>
                            setState(() => ocultar = !ocultar),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: recordar,
                        activeColor: cyGreen,
                        onChanged: (v) =>
                            setState(() => recordar = v!),
                      ),
                      Text("Recordar sesión",
                          style: TextStyle(color: txt, fontSize: 16)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: cargando ? null : validarLogin,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: oscuro ? cyGreen : Colors.black, width: 2),
                      ),
                      child: cargando
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: oscuro ? cyGreen : Colors.black,
                              ),
                            )
                          : Text(
                              "Ingresar",
                              style: TextStyle(
                                color: oscuro ? cyGreen : Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
