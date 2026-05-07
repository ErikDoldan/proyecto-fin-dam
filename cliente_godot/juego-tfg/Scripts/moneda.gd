extends Area2D

@onready var http_request = $HTTPRequest
var recogida = false # Evita que se envíe 7 veces si te quedas encima

func _ready():
	body_entered.connect(_on_body_entered)
	# CONECTAMOS POR CÓDIGO (por si acaso no lo hiciste en el editor)
	http_request.request_completed.connect(_on_http_request_request_completed)

func _on_body_entered(body):
	# Si lo que entra es el Jugador y aún no la hemos procesado
	if body.name == "Jugador" and not recogida:
		recogida = true # Bloqueamos futuras entradas
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
	
func _on_http_request_request_completed(result, response_code, headers, body):
	print("Respuesta de Django recibida. Código: ", response_code)
	if response_code == 200:
		print("Moneda guardada en BD. Desapareciendo...")
		queue_free() # AHORA SÍ: La moneda se borra
	else:
		print("Error en el servidor, permitiendo reintento.")
		recogida = false # Si el servidor falló, permitimos volver a intentarlo 	
