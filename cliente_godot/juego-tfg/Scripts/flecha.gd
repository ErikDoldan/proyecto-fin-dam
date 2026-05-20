extends Area2D

var velocidad = 250.0
var direccion = Vector2.RIGHT

func _ready():
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _process(delta):
	
	position += direccion * velocidad * delta

func _on_body_entered(body):
	if body.name == "Jugador" and body.has_method("recibir_dano"):
		body.recibir_dano(global_position.x)
		queue_free()
	elif body is TileMap:
		queue_free()

func _on_screen_exited():
	queue_free()
