extends Control

# Referencias a nuestros nodos exactos de la imagen
@onready var input_nombre = $InputNombre
@onready var input_password = $InputPassword
@onready var http_request = $PeticionLogin

# Esta función se ejecuta al pulsar el botón "Jugar" (Login)
func _on_boton_jugar_pressed():
	enviar_peticion("login")

# Esta función se ejecuta al pulsar el botón "Registro"
func _on_boton_registro_pressed():
	enviar_peticion("registro")

# Centralizamos la lógica de enviar datos
func enviar_peticion(tipo_accion: String):
	var nombre_jugador = input_nombre.text.strip_edges()
	var password_jugador = input_password.text.strip_edges()
	
	if nombre_jugador == "" or password_jugador == "":
		print("El nombre y la contraseña no pueden estar vacíos")
		return

	# 1. Preparamos los datos incluyendo la contraseña y la acción
	var datos = {
		"nombre": nombre_jugador,
		"contrasena": password_jugador,
		"accion": tipo_accion
	}
	
	var json_datos = JSON.stringify(datos)
	var cabeceras = ["Content-Type: application/json"]
	
	var url = "http://127.0.0.1:8000/api/jugadores"
	http_request.request(url, cabeceras, HTTPClient.METHOD_POST, json_datos)
	
	print("Enviando petición a Django... Acción: ", tipo_accion)

# Esta función se ejecuta cuando Django responde
func _on_peticion_login_request_completed(_result, response_code, _headers, body):
	# Si todo va bien (200 OK para Login, 201 Created para Registro)
	if response_code == 201 or response_code == 200:
		var respuesta = JSON.parse_string(body.get_string_from_utf8())
		var equipadas_desde_db = respuesta.get("habilidades_equipadas", "")
		
		Global.set_jugador_id(respuesta["jugador_id"])
		
		Global.puntuacion_actual = respuesta.get("puntuacion", 0)
		Global.nivel_desbloqueado = respuesta.get("nivel_desbloqueado", 1)
		
		var poder_obtenido = respuesta.get("tiene_doble_salto", false)
		Global.habilidades["doble_salto"] = poder_obtenido
		
		if equipadas_desde_db != "":
			Global.habilidades_equipadas = Array(equipadas_desde_db.split(","))
		else:
			Global.habilidades_equipadas = []
			
		# Autoequipa la habilidad si la tiene
		if poder_obtenido and not "doble_salto" in Global.habilidades_equipadas:
			Global.habilidades_equipadas.append("doble_salto")
		
		print("¡Acceso concedido! Puntos: ", Global.puntuacion_actual, " | Doble Salto: ", Global.habilidades["doble_salto"])
		
		# Vamos al selector de niveles
		get_tree().change_scene_to_file("res://Scenes/selector_niveles.tscn")
		
	# Si hay un error (Contraseña incorrecta, nombre ya usado, etc.)
	else:
		var error_mensaje = body.get_string_from_utf8()
		
		# Intentamos leer el JSON para mostrar un mensaje limpio
		var error_json = JSON.parse_string(error_mensaje)
		if error_json and error_json.has("error"):
			print("Error: ", error_json["error"])
			# Aquí podrías usar uno de tus nodos Label para mostrar el error en pantalla:
			# $Label2.text = error_json["error"] 
		else:
			print("Error en el servidor. Código: ", response_code, " Detalles: ", error_mensaje)
