extends Area2D

@onready var sprite = $AnimatedSprite2D
# Ahora apuntamos al contenedor en lugar de al texto directamente
@onready var caja_dialogo = $PanelContainer 

func _ready():
	sprite.play("Idle")
	caja_dialogo.visible = false # Ocultamos toda la caja
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Jugador":
		caja_dialogo.visible = true # Mostramos toda la caja

func _on_body_exited(body):
	if body.name == "Jugador":
		caja_dialogo.visible = false # Ocultamos toda la caja
