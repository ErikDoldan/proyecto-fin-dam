extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Jugador":
	
		if body.has_method("recibir_dano"):
	
			body.recibir_dano(global_position.x)
