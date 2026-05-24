extends Control

@onready var label_info = $InfoJugador
@onready var http_request = $HTTPRequest
@onready var tarjeta_1 = $ContenedorNiveles/TarjetaNivel1 
@onready var tarjeta_2 = $ContenedorNiveles/TarjetaNivel2
@onready var tarjeta_3 = $ContenedorNiveles/TarjetaNivel3
@onready var tarjeta_4 = $ContenedorNiveles/TarjetaNivel4
@onready var http_borrar = $HTTPBorrar
@onready var dialogo_borrar = $DialogoBorrar
@onready var btn_pantalla =$BtnPantalla

func _ready():
	actualizar_texto_pantalla()
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
	var url = "https://erikdoldan.pythonanywhere.com/api/jugadores/" + str(Global.jugador_id)
	http_request.request(url, [], HTTPClient.METHOD_GET)

func _on_http_request_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var respuesta_json = JSON.parse_string(body.get_string_from_utf8())
		var nombre = respuesta_json.get("nombre", "Desconocido")
		var puntos = respuesta_json.get("puntuacion", 0)
		Global.puntuacion_actual = puntos
		
		# --- LEE EL NIVEL DESBLOQUEADO DESDE DJANGO ---
		Global.nivel_desbloqueado = respuesta_json.get("nivel_desbloqueado", 1)
		
		Global.habilidades["doble_salto"] = respuesta_json.get("tiene_doble_salto", false)
		Global.habilidades["dash"] = respuesta_json.get("tiene_dash", false)
		Global.habilidades["fuego"] = respuesta_json.get("tiene_fuego", false)
		Global.habilidades["escudo"] = respuesta_json.get("tiene_escudo", false)
		Global.habilidades["planeador"] = respuesta_json.get("tiene_planeador", false)
		Global.habilidades["agua"] = respuesta_json.get("tiene_agua", false)

		
		
		var equipadas_desde_db = respuesta_json.get("habilidades_equipadas", "")
		if equipadas_desde_db != "":
			Global.habilidades_equipadas = Array(equipadas_desde_db.split(","))
		else:
			Global.habilidades_equipadas = []
		
		
		label_info.text = "Bienvenido, " + str(nombre) + "\nPuntuación Total: " + str(puntos)
		
		# --- ACTUALIZA LOS CANDADOS 
		bloquear_nivel(tarjeta_1, 1)
		bloquear_nivel(tarjeta_2, 2)
		bloquear_nivel(tarjeta_3, 3)
		bloquear_nivel(tarjeta_4, 4)
	else:
		label_info.text = "Error de conexión. Código: " + str(response_code)
func _on_boton_nivel_1_pressed():
	MusicaMenus.stop()
	get_tree().change_scene_to_file("res://Scenes/nivel_1.tscn") 	

func _on_boton_nivel_2_pressed():
	MusicaMenus.stop()
	get_tree().change_scene_to_file("res://Scenes/nivel_2.tscn")

func _on_boton_nivel_3_pressed():
	MusicaMenus.stop()
	get_tree().change_scene_to_file("res://Scenes/nivel_3.tscn")

func _on_boton_nivel_4_pressed():
	MusicaMenus.stop()
	get_tree().change_scene_to_file("res://Scenes/nivel_4.tscn")

	
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
	# 1. Le dice el tamaño exacto en píxeles 
	dialogo_borrar.size = Vector2i(500, 250)
	
	
	dialogo_borrar.popup_centered()


func _on_dialogo_borrar_confirmed():
	print("Confirmado. Solicitando borrado de la cuenta a Django...")
	
	var url = "https://erikdoldan.pythonanywhere.com/api/jugadores/" + str(Global.jugador_id)
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

func _on_boton_ver_controles_pressed():
	$MenuControles.visible = true

func _on_boton_ver_volumen_pressed():
	$MenuVolumen.visible = true
	
func _on_boton_entrar_pressed() -> void:
	pass 
	
func _on_btn_pantalla_pressed():
	if get_tree().root.mode == Window.MODE_WINDOWED:
		get_tree().root.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		get_tree().root.mode = Window.MODE_WINDOWED
		
	actualizar_texto_pantalla()
	
func actualizar_texto_pantalla():
	if get_tree().root.mode == Window.MODE_EXCLUSIVE_FULLSCREEN or get_tree().root.mode == Window.MODE_FULLSCREEN:
		btn_pantalla.text = "Pantalla en modo ventana"
	else:
		btn_pantalla.text = "Pantalla completa"


func _on_btn_salir_pressed() -> void:
	get_tree().quit()
