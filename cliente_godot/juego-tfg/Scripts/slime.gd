extends Node2D

const speed = 60
var direction = 1
var esta_muerto = false 
@export var escena_fruta: PackedScene

@onready var ray_cast_r: RayCast2D = $RayCastR
@onready var ray_cast_l: RayCast2D = $RayCastL
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_arriba: Area2D = $HitboxArriba
@onready var hitbox_cuerpo: Area2D = $HitboxCuerpo

func _ready() -> void:
	
	
	# Conecto la señal de la hitbox 
	hitbox_arriba.body_entered.connect(_on_hitbox_arriba_body_entered)
	hitbox_cuerpo.body_entered.connect(_on_hitbox_cuerpo_body_entered)
	
func _process(delta: float) -> void:
	if esta_muerto:
		return

	# RAYCAST DERECHO 
	if ray_cast_r.is_colliding():
		var objeto_chocado_r = ray_cast_r.get_collider()
		# Si choca con algo y ese algo NO es el Jugador, cambia de dirección
		if objeto_chocado_r and objeto_chocado_r.name != "Jugador":
			direction = -1
			animated_sprite.flip_h = true

	# RAYCAST IZQUIERDO 
	if ray_cast_l.is_colliding():
		var objeto_chocado_l = ray_cast_l.get_collider()
		
		if objeto_chocado_l and objeto_chocado_l.name != "Jugador":
			direction = 1
			animated_sprite.flip_h = false
			
	position.x += direction * speed * delta



func morir(jugador: Node2D) -> void:
	esta_muerto = true
	
	#Rebote guapo 
	jugador.velocity.y = -250
	
	#Bicho se pone rojo
	animated_sprite.play("dmg")
	soltar_botin()
	
	await animated_sprite.animation_finished
	queue_free()
	
func _on_hitbox_arriba_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" and not esta_muerto:
		#Solo muere si el jugador está cayendo
		if body.velocity.y > 0:
			morir(body)

func _on_hitbox_cuerpo_body_entered(body: Node2D) -> void:
	if body.name == "Jugador" and not esta_muerto:
		
		if body.velocity.y <= 0:
			if body.has_method("recibir_dano"):
				body.recibir_dano(global_position.x)

func soltar_botin():
	if escena_fruta == null:
		print("Error: No has puesto la escena de la fruta en el Inspector del Slime")
		return
		
	var probabilidad = randi() % 100 + 1
	if probabilidad <= 30:
		var nueva_fruta = escena_fruta.instantiate()
		var tipo_fruta = randi() % 3 + 1
		nueva_fruta.configurar_fruta(tipo_fruta)
		nueva_fruta.global_position = global_position
		get_parent().call_deferred("add_child", nueva_fruta)
