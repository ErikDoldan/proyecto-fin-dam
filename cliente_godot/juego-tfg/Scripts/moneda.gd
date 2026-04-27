extends Area2D

@onready var http_request = $HTTPRequest

# Simulamos que el jugador actual es el ID 3 (esto lo haremos dinámico luego)
var jugador_id = 3 
var puntos_a_sumar = 100

func _ready():
	# Conectamos la señal de que algo ha entrado en la moneda
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Comprobamos si lo que ha entrado es el Jugador
	if body.name == "Jugador":
		enviar_puntuacion_servidor()

func enviar_puntuacion_servidor():
	# 1. Preparamos el JSON (Requirement: Intercambio JSON)
	var datos = {"puntuacion": puntos_a_sumar}
	var json_datos = JSON.stringify(datos)
	var cabeceras = ["Content-Type: application/json"]
	
	# 2. URL con Path Param (Requirement: Parámetros en ruta)
	var url = "http://127.0.0.1:8000/api/jugadores/" + str(jugador_id)
	
	# 3. Enviamos el PUT (Requirement: Petición HTTP PUT)
	http_request.request(url, cabeceras, HTTPClient.METHOD_PUT, json_datos)
	print("Moneda recogida. Actualizando servidor...")

func _on_http_request_request_completed(_result, response_code, _headers, _body):
	if response_code == 200:
		print("Servidor actualizado con éxito.")
		queue_free() # La moneda desaparece del juego solo si el servidor confirma
	else:
		print("Error al guardar puntos. Código: ", response_code)
