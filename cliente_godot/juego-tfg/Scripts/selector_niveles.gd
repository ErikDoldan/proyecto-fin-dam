extends Control

@onready var label_info = $InfoJugador
@onready var http_request = $HTTPRequest
@onready var tarjeta_1 = $ContenedorNiveles/TarjetaNivel1 # <- Añadimos la 1
@onready var tarjeta_2 = $ContenedorNiveles/TarjetaNivel2
@onready var tarjeta_3 = $ContenedorNiveles/TarjetaNivel3
@onready var tarjeta_4 = $ContenedorNiveles/TarjetaNivel4
@onready var http_borrar = $HTTPBorrar
@onready var dialogo_borrar = $DialogoBorrar

func _ready():
	pedir_datos_jugador()
	if not http_request.request_completed.is_connected(_on_http_request_request_completed):
		http_request.request_completed.connect(_on_http_request_request_completed)
		
	if not http_borrar.request_completed.is_connected(_on_borrar_completado):
		http_borrar.request_completed.connect(_on_borrar_completado)


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
		
		# --- LEE EL NIVEL DESBLOQUEADO DESDE DJANGO ---
		Global.nivel_desbloqueado = respuesta_json.get("nivel_desbloqueado", 1)
		
		# --- ¡LO NUEVO QUE FALTABA AQUÍ! ---
		Global.habilidades["doble_salto"] = respuesta_json.get("tiene_doble_salto", false)
		Global.habilidades["dash"] = respuesta_json.get("tiene_dash", false)
		Global.habilidades["fuego"] = respuesta_json.get("tiene_fuego", false)
		Global.habilidades["escudo"] = respuesta_json.get("tiene_escudo", false)
		
		
		
		var equipadas_desde_db = respuesta_json.get("habilidades_equipadas", "")
		if equipadas_desde_db != "":
			Global.habilidades_equipadas = Array(equipadas_desde_db.split(","))
		else:
			Global.habilidades_equipadas = []
		# -----------------------------------
		
		label_info.text = "Bienvenido, " + str(nombre) + "\nPuntuación Total: " + str(puntos)
		
		# --- ACTUALIZA LOS CANDADOS 
		bloquear_nivel(tarjeta_1, 1)
		bloquear_nivel(tarjeta_2, 2)
		bloquear_nivel(tarjeta_3, 3)
		bloquear_nivel(tarjeta_4, 4)
	else:
		label_info.text = "Error de conexión. Código: " + str(response_code)
func _on_boton_nivel_1_pressed():
	get_tree().change_scene_to_file("res://Scenes/nivel_1.tscn") 	

func _on_boton_nivel_2_pressed():
	get_tree().change_scene_to_file("res://Scenes/nivel_2.tscn")

func bloquear_nivel(tarjeta: VBoxContainer, numero_nivel: int):
	var boton = tarjeta.get_node("BotonEntrar")
	var capa_oscura = tarjeta.get_node("MarcoFoto/CapaBloqueo")
	var candado = tarjeta.get_node("MarcoFoto/IconoCandado")
	
	if Global.nivel_desbloqueado >= numero_nivel:
		boton.disabled = false
		capa_oscura.visible = false
		candado.visible = false
	else:
		boton.disabled = true
		capa_oscura.visible = true
		candado.visible = true


func _on_boton_borrar_pressed():
	# 1. Le decimos el tamaño exacto en píxeles (OJO: en Godot 4 se usa Vector2i con la 'i' de Integer)
	dialogo_borrar.size = Vector2i(500, 250)
	
	# 2. La centramos en la pantalla y la abrimos
	dialogo_borrar.popup_centered()


func _on_dialogo_borrar_confirmed():
	print("Confirmado. Solicitando borrado de la cuenta a Django...")
	
	var url = "http://127.0.0.1:8000/api/jugadores/" + str(Global.jugador_id)
	http_borrar.request(url, [], HTTPClient.METHOD_DELETE)

func _on_borrar_completado(_result, response_code, _headers, _body):
	if response_code == 200:
		print("¡Cuenta aniquilada! Volviendo al inicio...")
		
		Global.jugador_id = -1 
		Global.nivel_desbloqueado = 1
		Global.habilidades_equipadas = []
		
		get_tree().change_scene_to_file("res://Scenes/pantalla_titulo.tscn")
	else:
		print("Error al borrar cuenta. Código: ", response_code)
