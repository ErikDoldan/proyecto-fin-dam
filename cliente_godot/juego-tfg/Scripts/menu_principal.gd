extends Control

# Referencias a nodos
@onready var input_nombre = $InputNombre
@onready var input_password = $InputPassword
@onready var http_request = $PeticionLogin
@onready var label_error = $LabelError

func _on_boton_jugar_pressed():
	enviar_peticion("login")


func _on_boton_registro_pressed():
	enviar_peticion("registro")


func enviar_peticion(tipo_accion: String):
	# Limpia el mensaje de error cada vez que intenta de nuevo
	label_error.text = "" 
	
	var nombre_jugador = input_nombre.text.strip_edges()
	var password_jugador = input_password.text.strip_edges()
	
	if nombre_jugador == "" or password_jugador == "":
		label_error.text = "El nombre y la contraseña no pueden estar vacíos."
		return

	# 1. Prepara los datos
	var datos = {
		"nombre": nombre_jugador,
		"contrasena": password_jugador,
		"accion": tipo_accion
	}
	
	var json_datos = JSON.stringify(datos)
	var cabeceras = ["Content-Type: application/json"]
	
	var url = "http://127.0.0.1:8000/api/jugadores"
	http_request.request(url, cabeceras, HTTPClient.METHOD_POST, json_datos)

# Esta función se ejecuta cuando Django responde
func _on_peticion_login_request_completed(_result, response_code, _headers, body):
	
	if response_code == 201 or response_code == 200:
		var respuesta = JSON.parse_string(body.get_string_from_utf8())
		var equipadas_desde_db = respuesta.get("habilidades_equipadas", "")
		
		Global.set_jugador_id(respuesta["jugador_id"])
		
		Global.puntuacion_actual = respuesta.get("puntuacion", 0)
		Global.nivel_desbloqueado = respuesta.get("nivel_desbloqueado", 1)
		
		var poder_obtenido = respuesta.get("tiene_doble_salto", false)
		Global.habilidades["doble_salto"] = poder_obtenido
		
		var dash_obtenido = respuesta.get("tiene_dash", false)
		Global.habilidades["dash"] = dash_obtenido
		
		var fuego_obtenido = respuesta.get("tiene_fuego",false)
		Global.habilidades["fuego"] = fuego_obtenido
		
		var escudo_obtenido = respuesta.get("tiene_escudo",false)
		Global.habilidades["escudo"]=escudo_obtenido
		
		var planeador_obtenido = respuesta.get("tiene_planeador",false)
		Global.habilidades["planeador"]=planeador_obtenido
		
		var agua_obtenido = respuesta.get("tiene_agua",false)
		Global.habilidades["agua"]=agua_obtenido
		
		if equipadas_desde_db != "":
			Global.habilidades_equipadas = Array(equipadas_desde_db.split(","))
		else:
			Global.habilidades_equipadas = []
			
		# Autoequipa la habilidad si la tiene
		if poder_obtenido and not "doble_salto" in Global.habilidades_equipadas:
			Global.habilidades_equipadas.append("doble_salto")
		
		# Vamos al selector de niveles
		get_tree().change_scene_to_file("res://Scenes/selector_niveles.tscn")
		
	else:
		var error_mensaje = body.get_string_from_utf8()
		var error_json = JSON.parse_string(error_mensaje)
		
		if error_json and error_json.has("error"):
			label_error.text = error_json["error"]
		else:
			# Si el servidor está apagado o falla de otra forma
			label_error.text = "Error de conexión con el servidor."
