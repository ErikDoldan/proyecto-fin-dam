extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	# Comprobamos si el que cae es el jugador
	if body.name == "Jugador":
		print("El jugador se ha caído. Reiniciando...")
		get_tree().reload_current_scene() # O la función que uses tú para quitar vida/reiniciar
		
	# Si cae cualquier OTRA cosa (como un enemigo o una bola de fuego)...
	else:
		# ...simplemente lo borramos de la existencia para que no caiga infinitamente
		body.queue_free()
func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	
