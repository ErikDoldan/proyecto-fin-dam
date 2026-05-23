extends Area2D

@onready var http_request = $HTTPRequest
@onready var sonido = $SonidoMoneda
@onready var sprite = $AnimatedSprite2D
@onready var colision = $CollisionShape2D

var recogida = false # Evita que se envíe 7 veces si te quedas encima

func _ready():
	body_entered.connect(_on_body_entered)
	http_request.request_completed.connect(_on_http_request_request_completed)

func _on_body_entered(body):
	if body.name == "Jugador" and not recogida:
		recogida = true 
		
		# --- EFECTO INMEDIATO PARA EL JUGADOR ---
		sonido.play() 
		sprite.visible = false 
		colision.set_deferred("disabled", true) 
		
		enviar_puntuacion_servidor()

func enviar_puntuacion_servidor():
	if Global.jugador_id == -1:
		print("Error: No hay ID de jugador")
		recogida = false 
		return

	Global.puntuacion_actual += 100 
	
	var datos = {"puntuacion": Global.puntuacion_actual}
	var json_datos = JSON.stringify(datos)
	var cabeceras = ["Content-Type: application/json"]
	
	var url = "http://127.0.0.1:8000/api/jugadores/" + str(Global.jugador_id) 
	
	http_request.request(url, cabeceras, HTTPClient.METHOD_PUT, json_datos)
	print("Enviando PUT a Django con el total de: ", Global.puntuacion_actual)
	
func _on_http_request_request_completed(_result, response_code, _headers, _body):
	print("Respuesta de Django recibida. Código: ", response_code)
	if response_code == 200:
		print("Moneda guardada en BD. Desapareciendo...")
		
		# --- EVITA QUE EL SONIDO SE CORTE ---
		if sonido.playing:
			await sonido.finished
			
		queue_free() 
	else:
		print("Error en el servidor, permitiendo reintento.")
		sprite.visible = true
		colision.set_deferred("disabled", false)
		recogida = false
