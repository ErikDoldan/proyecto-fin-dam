extends Area2D

@onready var http_request = $HTTPRequest
@export var ruta_siguiente_nivel: String = "res://Scenes/selector_niveles.tscn"

func _ready():
	body_entered.connect(_on_body_entered)
	http_request.request_completed.connect(_on_request_completed)

func _on_body_entered(body):
	if body.name == "Jugador":
		print("¡Nivel superado! Guardando en la nube...")
		
		# Congela al jugador 
		body.esta_congelado = true 
		
		# Guarda Django
		enviar_guardado_a_django()

func enviar_guardado_a_django():
	var url = "http://127.0.0.1:8000/api/jugadores/" + str(Global.jugador_id)
	
	if Global.nivel_desbloqueado < 2:
		Global.nivel_desbloqueado = 2
		
	var lista_texto = ",".join(Global.habilidades_equipadas)
	var datos = {
		"puntuacion": Global.puntuacion_actual,
		"habilidades_equipadas": lista_texto,
		"nivel_desbloqueado": Global.nivel_desbloqueado 
	}
	
	var json_datos = JSON.stringify(datos)
	var headers = ["Content-Type: application/json"]
	http_request.request(url, headers, HTTPClient.METHOD_PUT, json_datos)
	
func _on_request_completed(_result, response_code, _headers, _body):
	if response_code == 200:
		print("Partida guardada con éxito. Volviendo al selector...")
		get_tree().change_scene_to_file(ruta_siguiente_nivel)
	else:
		print("Error al guardar. Código: ", response_code)
