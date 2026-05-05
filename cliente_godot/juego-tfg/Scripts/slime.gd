extends Node2D

const speed = 60
var direction = 1
var esta_muerto = false 

@onready var ray_cast_r: RayCast2D = $RayCastR
@onready var ray_cast_l: RayCast2D = $RayCastL
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_arriba: Area2D = $HitboxArriba

func _ready() -> void:
	
	
	# Conecto la señal de la hitbox 
	hitbox_arriba.body_entered.connect(_on_hitbox_arriba_body_entered)

func _process(delta: float) -> void:
	# Si el bicho está muerto, fuera
	if esta_muerto:
		return

	if ray_cast_r.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_l.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
		
	position.x += direction * speed * delta

func _on_hitbox_arriba_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" and not esta_muerto:
		morir(body)

func morir(jugador: Node2D) -> void:
	esta_muerto = true
	
	#Rebote guapo 
	jugador.velocity.y = -250
	
	#Bicho se pone rojo
	animated_sprite.play("dmg")
	
	await animated_sprite.animation_finished
	
	# Borro al bicho 
	queue_free()
