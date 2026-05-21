extends StaticBody2D

@onready var anim_player = $AnimationPlayer

func _ready():

	visible = false

func cerrar_puerta():
	
	visible = true
	
	anim_player.play("caer")
