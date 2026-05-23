extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	# El que cae es el jugador
	if body.name == "Jugador":
		print("El jugador se ha caído. Reiniciando...")
		get_tree().call_deferred("reload_current_scene")
		
	# Si cae cualquier otra cosa 
	else:
		
		body.queue_free.call_deferred()
func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	
