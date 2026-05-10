extends CanvasLayer

@onready var grid_catalogo = $Margen/DivisionPrincipal/LadoDerecho/CuadriculaCatalogo
@onready var grid_equipo = $Margen/DivisionPrincipal/LadoIzquierdo/CuadriculaEquipo

@export var foto_candado: Texture2D
@export var foto_viento: Texture2D

func _ready():
	visible = false
	
	# Conectamos las casillas del catálogo para que "escuchen" los clics del ratón
	for casilla in grid_catalogo.get_children():
		# Le pasamos el nombre de la casilla (ej: "doble_salto") a la función del clic
		casilla.gui_input.connect(_on_casilla_clic.bind(casilla.name))

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

func actualizar_ui():
	# 1. ACTUALIZAR EL CATÁLOGO (Lado Derecho)
	for casilla in grid_catalogo.get_children():
		var nombre_habilidad = casilla.name 
		var nodo_icono = casilla.get_node("Icono")
		var nodo_animacion = casilla.get_node_or_null("Animacion")
		
		# Para darle un toque visual: si está equipada, la hacemos un poco transparente en el catálogo
		if nombre_habilidad in Global.habilidades_equipadas:
			casilla.modulate = Color(1, 1, 1, 0.5) # Semitransparente
		else:
			casilla.modulate = Color(1, 1, 1, 1) # Color normal
		
		if Global.habilidades.has(nombre_habilidad):
			var esta_desbloqueada = Global.habilidades[nombre_habilidad]
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

	# 2. ACTUALIZAR EL EQUIPAMIENTO (Lado Izquierdo)
	var casillas_equipo = grid_equipo.get_children()
	
	# Primero, vaciamos los 4 huecos por completo (ocultamos todo)
	for casilla in casillas_equipo:
		casilla.get_node("Icono").texture = null # Quitamos foto estática
		var anim = casilla.get_node_or_null("Animacion")
		if anim:
			anim.visible = false # Ocultamos la animación
		
	# Luego, rellenamos de izquierda a derecha con lo que haya en la "mochila"
	for i in range(Global.habilidades_equipadas.size()):
		var nombre_equipado = Global.habilidades_equipadas[i]
		var casilla_destino = casillas_equipo[i]
		var icono_destino = casilla_destino.get_node("Icono")
		var anim_destino = casilla_destino.get_node_or_null("Animacion")
		
		# Según el nombre, encendemos su animación
		if nombre_equipado == "doble_salto":
			if anim_destino:
				anim_destino.visible = true
				anim_destino.play()
			else:
				icono_destino.texture = foto_viento # Por si acaso
@onready var http_request_save = $HTTPRequest # Asegúrate de que el nombre coincida

func guardar_equipamiento_en_nube():
	var url = "http://127.0.0.1:8000/api/jugadores/" + str(Global.jugador_id)
	
	# Convertimos nuestra lista ["a", "b"] en texto "a,b" para Django
	var lista_texto = ",".join(Global.habilidades_equipadas)
	
	var datos = {
		"habilidades_equipadas": lista_texto
	}
	
	var json_datos = JSON.stringify(datos)
	var headers = ["Content-Type: application/json"]
	http_request_save.request(url, headers, HTTPClient.METHOD_PUT, json_datos)
	print("Enviando equipamiento a la nube...")
