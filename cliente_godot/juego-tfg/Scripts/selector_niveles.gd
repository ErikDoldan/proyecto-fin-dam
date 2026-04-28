extends Control

# Apuntamos al nuevo Label que acabas de crear
@onready var label_info = $InfoJugador
@onready var http_request = $HTTPRequest

func _ready():
	pedir_datos_jugador()
	
	if not http_request.request_completed.is_connected(_on_http_request_request_completed):
		http_request.request_completed.connect(_on_http_request_request_completed)

func pedir_datos_jugador():
	if Global.jugador_id == -1:
		label_info.text = "Error: Jugador no logueado"
		return
		
	label_info.text = "Cargando datos..."
	
	var url = "http://127.0.0.1:8000/api/jugadores/" + str(Global.jugador_id)
	http_request.request(url, [], HTTPClient.METHOD_GET)

func _on_http_request_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var respuesta_json = JSON.parse_string(body.get_string_from_utf8())
		var nombre = respuesta_json.get("nombre", "Desconocido")
		var puntos = respuesta_json.get("puntuacion", 0)
		
		label_info.text = "Bienvenido, " + str(nombre) + "\nPuntuación Total: " + str(puntos)
	else:
		label_info.text = "Error de conexión. Código: " + str(response_code)

func _on_boton_nivel_1_pressed():
	get_tree().change_scene_to_file("res://Scenes/nivel_1.tscn") 	
