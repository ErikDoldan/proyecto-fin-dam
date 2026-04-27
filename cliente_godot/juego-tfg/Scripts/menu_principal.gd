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

	# 1. Preparamos los datos en formato diccionario (equivalente a JSON)
	var datos = {
		"nombre": nombre_jugador
	}
	
	# 2. Convertimos el diccionario a un string JSON (Requisito del proyecto)
	var json_datos = JSON.stringify(datos)
	
	# 3. Configuramos las cabeceras para avisar a Django de que enviamos JSON
	var cabeceras = ["Content-Type: application/json"]
	
	# 4. Enviamos la petición POST al servidor local
	var url = "http://127.0.0.1:8000/api/jugadores"
	http_request.request(url, cabeceras, HTTPClient.METHOD_POST, json_datos)
	
	print("Enviando petición a Django...")

# Esta función se ejecuta cuando Django nos responde
func _on_peticion_login_request_completed(_result, response_code, _headers, body):
	if response_code == 201 or response_code == 200:
		var respuesta = JSON.parse_string(body.get_string_from_utf8())
		
		# ¡PASO CLAVE!: Guardamos el ID real que viene de Django en el Global
		Global.set_jugador_id(respuesta["jugador_id"])
		
		get_tree().change_scene_to_file("res://Scenes/SelectorNiveles.tscn")
	else:
		var error_mensaje = body.get_string_from_utf8()
		print("Error en el servidor. Código: ", response_code, " Detalles: ", error_mensaje)
