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
	
	
	if Global.habilidades.has("doble_salto") and Global.habilidades["doble_salto"] == true:
		cofre_abierto = true
		animated_sprite.play("abrir") 
	else:
		cofre_abierto = false
		animated_sprite.play("cerrado")
	
	body_entered.connect(_on_body_entered)
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
		
		
		Global.habilidades["doble_salto"] = true
		if not "doble_salto" in Global.habilidades_equipadas and Global.habilidades_equipadas.size() < 4:
			Global.habilidades_equipadas.append("doble_salto")
		
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
	var datos = {
		"tiene_doble_salto": true,
		"habilidades_equipadas": lista_texto
	}
	
	var json_datos = JSON.stringify(datos)
	var headers = ["Content-Type: application/json"]
	http_request.request(url_django, headers, HTTPClient.METHOD_PUT, json_datos)
	
func _on_request_completed(_result, response_code, _headers, body):
	
	if response_code == 200:
		print("¡Cofre guardado en Django 200 OK!")
		
		
		Global.habilidades["doble_salto"] = true
		
		
		if not "doble_salto" in Global.habilidades_equipadas:
			Global.habilidades_equipadas.append("doble_salto")
			
	else:
		print("⚠️ ERROR EN EL COFRE. Código: ", response_code)
		if body:
			print("Detalles: ", body.get_string_from_utf8())
