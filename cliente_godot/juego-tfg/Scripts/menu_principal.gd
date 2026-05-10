extends Control

# Referencias a nuestros nodos
@onready var input_nombre = $InputNombre
@onready var http_request = $PeticionLogin

# Esta función se ejecuta al pulsar el botón "Jugar"
func _on_boton_jugar_pressed():
	var nombre_jugador = input_nombre.text
	
	if nombre_jugador.strip_edges() == "":
		print("El nombre no puede estar vacío")
		return

	# 1. Preparamos los datos
	var datos = {
		"nombre": nombre_jugador
	}
	
	var json_datos = JSON.stringify(datos)
	var cabeceras = ["Content-Type: application/json"]
	
	var url = "http://127.0.0.1:8000/api/jugadores"
	http_request.request(url, cabeceras, HTTPClient.METHOD_POST, json_datos)
	
	print("Enviando petición a Django...")

# Esta función se ejecuta cuando Django nos responde
func _on_peticion_login_request_completed(_result, response_code, _headers, body):
	if response_code == 201 or response_code == 200:
		var respuesta = JSON.parse_string(body.get_string_from_utf8())
		var equipadas_desde_db = respuesta.get("habilidades_equipadas", "")
		
		# Guardamos el ID real que viene de Django
		Global.set_jugador_id(respuesta["jugador_id"])
		
		# Cargamos la puntuación
		Global.puntuacion_actual = respuesta.get("puntuacion", 0)
		Global.nivel_desbloqueado = respuesta.get("nivel_desbloqueado", 1)
		
		# Cargamos el poder desde Django y lo guardamos en el NUEVO DICCIONARIO
		var poder_obtenido = respuesta.get("tiene_doble_salto", false)
		Global.habilidades["doble_salto"] = poder_obtenido
		
		if equipadas_desde_db != "":
			# Convertimos el texto "doble_salto,dash" en una lista real ["doble_salto", "dash"]
			Global.habilidades_equipadas = Array(equipadas_desde_db.split(","))
		else:
			Global.habilidades_equipadas = []
		# Auto-equipamos la habilidad si la tiene
		if poder_obtenido and not "doble_salto" in Global.habilidades_equipadas:
			Global.habilidades_equipadas.append("doble_salto")
		
		print("¡Login con éxito! Puntos: ", Global.puntuacion_actual, " | Doble Salto: ", Global.habilidades["doble_salto"])
		
		get_tree().change_scene_to_file("res://Scenes/selector_niveles.tscn")
	else:
		var error_mensaje = body.get_string_from_utf8()
		print("Error en el servidor. Código: ", response_code, " Detalles: ", error_mensaje)
