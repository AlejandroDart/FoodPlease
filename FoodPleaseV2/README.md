# 🚀 Cybernetic FoodPlease — Versión 2 (V2)

La **Versión 2 (V2)** de *Cybernetic FoodPlease* es la evolución de la V1, donde el prototipo inicial se transforma en una aplicación mucho más completa, funcional y conectada.  
Aquí se agregan las características que no estaban disponibles en la V1 y se mejora drásticamente la experiencia del usuario.

---

## 🎯 Objetivo de la Versión 2

- Completar la lógica real del sistema de pedidos  
- Incorporar persistencia mediante **API / Base de Datos remota**  
- Agregar funcionalidades avanzadas no presentes en la V1  
- Mejorar la experiencia de usuario y el flujo de interacción  
- Optimizar el diseño y la estructura general del proyecto  

---

## 🌟 Funcionalidades Nuevas de la V2

Estas características **NO estaban presentes en la V1** y se agregan en esta versión:

### ✅ **1. Pantalla de Login (Ahora incluida en V2)**
Permite que cada mesero inicie sesión para registrar pedidos personalizados.

### ✅ **2. Contador de cantidad por comida**
Ahora cada ítem del pedido puede tener cantidades dinámicas (1, 2, 3, etc.).

### ✅ **3. Conexión con API real**
La app ahora guarda datos en un servidor mediante:
- POST (crear pedido)
- GET (listar pedidos)
- PUT (editar pedido)
- DELETE (eliminar pedido)

### ✅ **4. Página “Mi Dinero”**
Permite ver cuánto dinero generó el mesero según sus ventas registradas.

### ✅ **5. Escaneo de QR para número de mesa**
Usa la cámara del teléfono para detectar automáticamente la mesa del cliente.

### ✅ **6. Validaciones avanzadas**
- Campos obligatorios  
- Formato correcto de mesa  
- Impedir valores inválidos  
- Precios siempre calculados automáticamente  

### ✅ **7. Ocultar teclado al tocar fuera**
Mejora enorme en la usabilidad en móviles.

### ✅ **8. Experiencia visual mejorada**
- Dropdown corregidos  
- Overflow solucionado  
- Diseño mucho más consistente  

### 🖤 **9. Modo Oscuro Completo y Persistente**
En V2 el tema oscuro se guarda en memoria mediante `SharedPreferences`.

---

## 📋 Funcionalidades Totales en V2

- Pantalla de Login con validación  
- Crear, editar y eliminar pedidos conectados a API  
- Cálculo automático del total según cantidad  
- Límite de 4 comidas por pedido  
- Escaneo QR  
- Modo oscuro persistente  
- Página Mi Dinero  
- Navegación completa entre pantallas  
- Animaciones en botones  
- Manejo profesional de estados y validaciones  

---

## 📂 Estructura del Proyecto (V2)

´´´
/lib
├── pages/
│ ├── login_page.dart
│ ├── pedido_page.dart
│ ├── lista_pedidos_page.dart
│ ├── editar_pedido_page.dart
│ └── mi_dinero_page.dart
├── utils/
│ ├── colors.dart
│ └── config.dart
└── main.dart
´´´

---

## 🛠️ Tecnologías Utilizadas en V2

- Flutter 3.x  
- Dart  
- Material Design 3  
- SharedPreferences  
- HTTP (API REST)  
- barcode_scan2  
- Animaciones con AnimatedContainer  

---

## 🚀 Instalación y Ejecución

### 1️⃣ Clonar repositorio

```bash
git clone https://github.com/AlejandroDart/ComidaPleaseV2.git
cd ComidaPleaseV2
