extends Area2D

@onready var http_request = $HTTPRequest
@onready var animated_sprite = $AnimatedSprite2D
@onready var cartel_victoria = $CanvasLayer/PanelContainer

var jugador_tocado = null
var cofre_abierto = false
var esperando_cierre = false 

func _ready():
	# IMPORTANTE: Al empezar, el cartel SIEMPRE debe estar oculto
	cartel_victoria.visible = false
	esperando_cierre = false
	
	# Comprobamos en el NUEVO DICCIONARIO si el jugador ya tenía el poder
	if Global.habilidades.has("doble_salto") and Global.habilidades["doble_salto"] == true:
		cofre_abierto = true
		animated_sprite.play("abrir") # Aparece abierto pero NO muestra cartel
	else:
		cofre_abierto = false
		animated_sprite.play("cerrado")
	
	body_entered.connect(_on_body_entered)
	http_request.request_completed.connect(_on_request_completed)

func _on_body_entered(body):
	# Solo se activa si es el Jugador Y el cofre está cerrado
	if body.name == "Jugador" and not cofre_abierto:
		cofre_abierto = true
		jugador_tocado = body
		
		jugador_tocado.esta_congelado = true
		animated_sprite.play("abrir")
		await animated_sprite.animation_finished
		
		# Solo mostramos el cartel y esperamos botón AQUÍ
		cartel_victoria.visible = true
		esperando_cierre = true
		
		enviar_a_django()

func _input(event):
	if esperando_cierre and event.is_action_pressed("ui_accept"):
		cerrar_mensaje()

func cerrar_mensaje():
	esperando_cierre = false
	cartel_victoria.visible = false
	if jugador_tocado:
		jugador_tocado.esta_congelado = false

func enviar_a_django():
	# ¡ARREGLADO!: Le quitamos el + "/" del final para que coincida exactamente con Django
	var url_django = "http://127.0.0.1:8000/api/jugadores/" + str(Global.jugador_id)
	
	var datos = {"tiene_doble_salto": true}
	var json_datos = JSON.stringify(datos)
	var headers = ["Content-Type: application/json"]
	http_request.request(url_django, headers, HTTPClient.METHOD_PUT, json_datos)

func _on_request_completed(_result, response_code, _headers, body):
	# Ahora sí comprobamos si sale bien o si falla
	if response_code == 200:
		print("¡Cofre guardado en Django 200 OK!")
		
		# 1. Lo marcamos como desbloqueado en el catálogo general
		Global.habilidades["doble_salto"] = true
		
		# 2. Como aún no hay menú, te lo equipamos automáticamente para que lo uses ya
		if not "doble_salto" in Global.habilidades_equipadas:
			Global.habilidades_equipadas.append("doble_salto")
			
	else:
		print("⚠️ ERROR EN EL COFRE. Código: ", response_code)
		if body:
			print("Detalles: ", body.get_string_from_utf8())
