extends Node2D

func _ready():
	$DetonadorPuerta.body_entered.connect(_on_detonador_puerta_entered)

func _on_detonador_puerta_entered(body):
	if body.name == "Jugador":
		print("¡TRAMPA ACTIVADA! El jugador ha entrado.") 
		$PuertaBoss.cerrar_puerta()
		$DetonadorPuerta.queue_free()
