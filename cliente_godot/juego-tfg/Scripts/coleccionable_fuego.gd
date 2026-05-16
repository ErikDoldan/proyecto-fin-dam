extends Area2D

@onready var http_request = $HTTPRequest
@onready var animated_sprite = $AnimatedSprite2D
@onready var cartel_victoria = $CanvasLayer/PanelContainer

var jugador_tocado = null
var cofre_abierto = false
var esperando_cierre = false 

func _ready():
	cartel_victoria.visible = false
	esperando_cierre = false
	
	# Comprobamos si ya tiene el fuego
	if Global.habilidades.has("fuego") and Global.habilidades["fuego"] == true:
		cofre_abierto = true
		animated_sprite.play("abrir") 
	else:
		cofre_abierto = false
		animated_sprite.play("cerrado")
	
	# Aseguramos la conexión de la petición HTTP
	if not http_request.request_completed.is_connected(_on_request_completed):
		http_request.request_completed.connect(_on_request_completed)

func _on_body_entered(body):
	if body.name == "Jugador" and not cofre_abierto:
		cofre_abierto = true
		jugador_tocado = body
		
		jugador_tocado.esta_congelado = true
		animated_sprite.play("abrir")
		await animated_sprite.animation_finished
		
		cartel_victoria.visible = true
		esperando_cierre = true
		
		# Desbloqueamos y autoequipamos en Godot antes de enviar a Django
		Global.habilidades["fuego"] = true
		if not "fuego" in Global.habilidades_equipadas and Global.habilidades_equipadas.size() < 4:
			Global.habilidades_equipadas.append("fuego")
			
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
	var url_django = "http://127.0.0.1:8000/api/jugadores/" + str(Global.jugador_id)
	
	var lista_texto = ",".join(Global.habilidades_equipadas)
	# ¡Añadimos el tiene_fuego: true para que Django se entere!
	var datos = {
		"habilidades_equipadas": lista_texto,
		"tiene_fuego": true
	}
	
	var json_datos = JSON.stringify(datos)
	var headers = ["Content-Type: application/json"]
	http_request.request(url_django, headers, HTTPClient.METHOD_PUT, json_datos)

func _on_request_completed(_result, response_code, _headers, _body):
	if response_code == 200:
		print("¡Cofre Fuego guardado en Django 200 OK!")
	else:
		print("⚠️ ERROR EN EL COFRE FUEGO. Código: ", response_code)
