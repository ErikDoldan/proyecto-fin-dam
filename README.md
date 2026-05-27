# 🎮 Arkomine - The Crystal Chronicles

![Godot Engine](https://img.shields.io/badge/Godot_4.x-478cbf?style=for-the-badge&logo=godot-engine&logoColor=white)
![GDScript](https://img.shields.io/badge/GDScript-478cbf?style=for-the-badge&logo=godot-engine&logoColor=white)
![Django](https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)

**Arkomine** es un juego de plataformas 2D con tintes de *Metroidvania* donde la experiencia de juego individual se fusiona con la persistencia de datos en la nube. Todo el progreso del jugador, sus estadísticas y su inventario se guardan y consultan en tiempo real mediante una API REST.

Este proyecto ha sido desarrollado como Trabajo de Fin de Grado (TFG), dividiendo la arquitectura en un **Cliente (Godot Engine)** y un **Servidor (Django)**.

---

## ✨ Características Principales

### 🕹️ Cliente (Godot)
- **Físicas y Control Custom:** Gravedad, saltos, colisiones y vectores calculados a mano en GDScript para un control ultra-fluido (sin depender de físicas automáticas erráticas).
- **Habilidades Dinámicas:** Mecánicas que alteran el entorno y el movimiento (Doble Salto, Dash con cooldowns por corrutinas, Planeador, Fragmentos de Agua/Fuego).
- **Inventario Inteligente:** Interfaz gráfica auto-escalable que se comunica con el servidor para clonar y renderizar únicamente los poderes que el jugador ha desbloqueado.
- **Gestor de Audio en Background:** Patrón Singleton (Autoload) para que la música no se corte al cambiar de nivel o morir.

### ⚙️ Servidor (Django API REST)
- **Arquitectura Limpia:** Backend que actúa puramente como fachada REST (JSON) sin renderizado de plantillas HTML.
- **Seguridad:** Sistema de login y registro unificado. Las contraseñas se almacenan mediante hashing (`make_password`) en la base de datos.
- **Patrón DTO & Rendimiento:** Base de datos relacional (SQLite3) optimizada con campos booleanos en la tabla principal para escupir respuestas JSON ultra-rápidas, evitando saturar el juego.
- **Protección Anti-Spam:** El cliente cancela peticiones HTTP encoladas (`cancel_request()`) para evitar caídas del servidor si el jugador hace clics muy rápido.

---

## 🏗️ Arquitectura de la Base de Datos

El sistema utiliza una relación **Muchos a Muchos (N:N)**:
1. **Jugador:** Almacena credenciales, progreso (puntuación, nivel) y el estado booleano de las habilidades (para respuestas REST rápidas).
2. **Item:** El catálogo estático de habilidades y objetos del juego.
3. **Inventario:** Tabla intermedia que relaciona al jugador con el ítem y guarda cantidades reales (preparado para ítems consumibles).

---

## 🚀 Instalación y Despliegue Local

Si quieres probar el proyecto en tu propia máquina, necesitas configurar tanto el servidor como el cliente.

### 1. Levantar el Servidor (Django)
1. Clona el repositorio:
   ```bash
   git clone [https://github.com/TU_USUARIO/TU_REPOSITORIO.git](https://github.com/TU_USUARIO/TU_REPOSITORIO.git)

2. Ve a la carpeta del backend y crea un entorno virtual (recomendado):
   ```bash
   python -m venv env
   source env/bin/activate  # En Windows: env\Scripts\activate
   ```
3. Instala las dependencias:
   ```bash
   pip install django
   ```
4. Aplica las migraciones a la base de datos:
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```
5. Arranca el servidor local:
   ```bash
   python manage.py runserver
   ```
   *(Por defecto, la API estará escuchando en `http://127.0.0.1:8000/api/`)*

### 2. Ejecutar el Cliente (Godot)
1. Descarga e instala [Godot Engine 4.x](https://godotengine.org/).
2. Abre Godot y dale a **Importar**.
3. Busca el archivo `project.godot` dentro de la carpeta del frontend del repositorio.
4. *Nota de configuración:* Si corres el servidor en local, asegúrate de cambiar la variable global de las URLs en Godot (de `pythonanywhere.com` a `localhost`).
5. ¡Dale al botón de **Play (F5)** y a jugar!

---

## 🎮 Controles Básicos

- **A / D o Flechas:** Moverse izquierda/derecha.
- **Espacio:** Saltar (y doble salto si está equipado).
- **I:** Abrir/Cerrar menú de Inventario.
- **Shift / Botón asignado:** Dash (esquiva rápida).
- **Click Izquierdo / Tecla asignada:** Disparar Bola de Fuego (si está equipada).

---

## 📡 Documentación de la API (Endpoints)

La comunicación cliente-servidor se realiza a través de las siguientes rutas principales:

- `GET /api/items/` ➔ Devuelve el catálogo de objetos del juego.
- `POST /api/jugadores/` ➔ Gestiona el Login y el Registro dependiendo del parámetro "accion".
- `GET /api/jugadores/{id}/` ➔ Devuelve todo el progreso y estado del inventario de un jugador.
- `PUT /api/jugadores/{id}/` ➔ Actualiza el progreso y equipamiento en la base de datos.
- `DELETE /api/jugadores/{id}/` ➔ Elimina la cuenta permanentemente.

---

## 👨‍💻 Autor
Desarrollado con 🩵 y muchísimos litros de café por **[Erik Doldán Iglesias]** para el Trabajo de Fin de Grado.

