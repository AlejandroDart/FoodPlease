# 🍽️ Cybernetic FoodPlease — Aplicación Móvil (Flutter)

**Cybernetic FoodPlease** es una aplicación móvil desarrollada en **Flutter** que permite gestionar pedidos de comida en un restaurante mediante un sistema de meseros.  
El proyecto incluye:

- 🧾 Registro y edición de pedidos  
- 📱 Escaneo de códigos QR para asignar mesas  
- 🌙 Modo oscuro / claro  
- 💵 Control del dinero generado por cada mesero  
- 🔄 Conexión con API propia en Python + SQLite  

Este repositorio corresponde a la **versión V1/V2** del proyecto académico desarrollado por **Grupo 7**.

---

## 📌 Características Principales

- **Autenticación de meseros**
- **Crear, editar y eliminar pedidos**
- **Contador de cantidades por comida**
- **Interfaz dinámica con modo oscuro**
- **Listas de pedidos actualizadas en tiempo real**
- **Visualización del total generado por mesero**
- **Backend Python API REST**

---

## 🛠️ Tecnologías Utilizadas

### **Frontend (App móvil)**
- Flutter 3.x
- Dart
- Material Design 3
- SharedPreferences
- barcode_scan2
- HTTP package  

### **Backend**
- Python 3
- Flask / FastAPI (según versión)
- SQLite database (`foodplease.db`)

---

## 📂 Estructura del Proyecto
```
├── lib/
│ ├── pages/
│ │ ├── editar_pedido_page.dart
│ │ ├── lista_pedidos_page.dart
│ │ ├── login_page.dart
│ │ ├── mi_dinero_page.dart
│ │ └── pedido_page.dart
│ ├── utils/
│ │ ├── colors.dart
│ │ └── config.dart
│
├── backend/
│ ├── api_foodplease.py
│ └── foodplease.db
│
├── README.md
└── pubspec.yaml
```
##

