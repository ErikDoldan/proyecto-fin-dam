extends Area2D

@onready var http_request = $HTTPRequest
@onready var animated_sprite = $AnimatedSprite2D
@onready var cartel_victoria = $CanvasLayer/PanelContainer

var jugador_tocado = null
var cofre_abierto = false
var esperando_cierre = false # Nueva bandera para detectar la pulsación del botón

func _ready():
	cartel_victoria.visible = false
	animated_sprite.play("cerrado")
	body_entered.connect(_on_body_entered)
	http_request.request_completed.connect(_on_request_completed)

func _on_body_entered(body):
	if body.name == "Jugador" and not cofre_abierto:
		cofre_abierto = true
		jugador_tocado = body
		
		# 1. Congelamos al jugador
		jugador_tocado.esta_congelado = true
		
		# 2. Animación de apertura
		animated_sprite.play("abrir")
		await animated_sprite.animation_finished
		
		# 3. Mostramos cartel y activamos la espera de botón
		cartel_victoria.visible = true
		esperando_cierre = true
		
		# 4. Enviamos a Django (esto ocurre en segundo plano)
		enviar_a_django()

func _input(event):
	# Si el cartel está puesto y el jugador pulsa "Aceptar" (Espacio/Enter)
	if esperando_cierre and event.is_action_pressed("ui_accept"):
		cerrar_mensaje()

func cerrar_mensaje():
	esperando_cierre = false
	cartel_victoria.visible = false
	
	# Descongelamos al jugador para que pueda seguir su aventura
	if jugador_tocado:
		jugador_tocado.esta_congelado = false

func enviar_a_django():
	var url_django = "http://127.0.0.1:8000/api/jugadores/" + str(Global.jugador_id)
	
	var datos = {"tiene_doble_salto": true}
	var json_datos = JSON.stringify(datos)
	var headers = ["Content-Type: application/json"]
	
	http_request.request(url_django, headers, HTTPClient.METHOD_PUT, json_datos)

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		if jugador_tocado:
			jugador_tocado.tiene_doble_salto = true
		print("¡200 OK! Django ha guardado el doble salto.")
	else:
		# Si falla, esto nos dirá exactamente por qué
		print("⚠️ ERROR al guardar el poder. Código de Django: ", response_code)
		print("Respuesta: ", body.get_string_from_utf8())
