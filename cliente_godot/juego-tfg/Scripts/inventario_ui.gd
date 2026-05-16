extends CanvasLayer

@onready var grid_catalogo = $Margen/DivisionPrincipal/LadoDerecho/CuadriculaCatalogo
@onready var grid_equipo = $Margen/DivisionPrincipal/LadoIzquierdo/CuadriculaEquipo
@onready var http_request_save = $HTTPRequest 

@export var foto_candado: Texture2D

func _ready():
	visible = false
	
	# 1. Conectamos las casillas del catálogo (DERECHA) para EQUIPAR
	for casilla in grid_catalogo.get_children():
		casilla.gui_input.connect(_on_casilla_clic.bind(casilla.name))

	# 2. Conectamos las casillas del equipo (IZQUIERDA) para DESEQUIPAR
	var indice = 0
	for casilla in grid_equipo.get_children():
		casilla.gui_input.connect(_on_casilla_equipo_clic.bind(indice))
		indice += 1

func _input(event):
	if event.is_action_pressed("abrir_inventario"):
		abrir_cerrar_inventario()

func abrir_cerrar_inventario():
	visible = not visible
	get_tree().paused = visible
	if visible:
		actualizar_ui()

func _on_casilla_clic(event: InputEvent, nombre_habilidad: String):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Global.habilidades.has(nombre_habilidad) and Global.habilidades[nombre_habilidad] == true:
			if nombre_habilidad in Global.habilidades_equipadas:
				Global.habilidades_equipadas.erase(nombre_habilidad)
			elif Global.habilidades_equipadas.size() < 4:
				Global.habilidades_equipadas.append(nombre_habilidad)
			else:
				print("¡No tienes más huecos! Desequipa algo primero.")
				
			actualizar_ui()
			guardar_equipamiento_en_nube()

func _on_casilla_equipo_clic(event: InputEvent, indice: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if indice < Global.habilidades_equipadas.size():
			Global.habilidades_equipadas.remove_at(indice)
			actualizar_ui()
			guardar_equipamiento_en_nube()

func actualizar_ui():
	# 1. ACTUALIZAR EL CATÁLOGO (Lado Derecho)
	for casilla in grid_catalogo.get_children():
		var nombre_habilidad = casilla.name 
		var nodo_icono = casilla.get_node("Icono")
		var nodo_animacion = casilla.get_node_or_null("Animacion")
		
		if nombre_habilidad in Global.habilidades_equipadas:
			casilla.modulate = Color(1, 1, 1, 0.5) 
		else:
			casilla.modulate = Color(1, 1, 1, 1) 
		
		# --- SOLUCIÓN DE LOS CANDADOS ---
		var esta_desbloqueada = false
		# Si está en el diccionario y es true, se marca como desbloqueada
		if Global.habilidades.has(nombre_habilidad):
			esta_desbloqueada = Global.habilidades[nombre_habilidad]
			
		if esta_desbloqueada:
			nodo_icono.visible = false
			if nodo_animacion:
				nodo_animacion.visible = true
				nodo_animacion.play()
		else:
			nodo_icono.visible = true
			nodo_icono.texture = foto_candado
			if nodo_animacion:
				nodo_animacion.visible = false
		# --------------------------------

	# 2. ACTUALIZAR EL EQUIPAMIENTO (Lado Izquierdo)
	var casillas_equipo = grid_equipo.get_children()
	
	for casilla in casillas_equipo:
		casilla.get_node("Icono").texture = null 
		var anim = casilla.get_node_or_null("Animacion")
		if anim:
			anim.visible = false 
			anim.stop()
		
	for i in range(Global.habilidades_equipadas.size()):
		var nombre_equipado = Global.habilidades_equipadas[i]
		var casilla_destino = casillas_equipo[i]
		var anim_destino = casilla_destino.get_node_or_null("Animacion")
		
		if anim_destino:
			anim_destino.visible = true
			
			# --- SOLUCIÓN A LAS ANIMACIONES CRUZADAS ---
			# Busca la animación original del lado derecho
			var nodo_original = grid_catalogo.get_node_or_null(nombre_equipado + "/Animacion")
			
			if nodo_original:
				# 1. Le clona todos los frames de la derecha a la izquierda
				anim_destino.sprite_frames = nodo_original.sprite_frames
				# 2. Le dice q reproduzca la misma q esté puesta a la derecha
				anim_destino.play(nodo_original.animation)
			# -------------------------------------------

func guardar_equipamiento_en_nube():
	var url = "http://127.0.0.1:8000/api/jugadores/" + str(Global.jugador_id)
	var lista_texto = ",".join(Global.habilidades_equipadas)
	var datos = {"habilidades_equipadas": lista_texto}
	var json_datos = JSON.stringify(datos)
	var headers = ["Content-Type: application/json"]
	http_request_save.request(url, headers, HTTPClient.METHOD_PUT, json_datos)
