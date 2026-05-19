extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# 1 El que cae es el jugador
	if body.name == "Jugador":
		if body.has_method("recibir_dano"):
			body.recibir_dano(global_position.x)
			
	#2 Si el que cae es un enemigo 
	elif body.has_method("sufrir_dano"):
		# Torton para que muera en el acto
		body.sufrir_dano(99, global_position.x)
