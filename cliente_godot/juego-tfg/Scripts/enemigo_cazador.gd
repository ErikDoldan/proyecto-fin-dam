extends CharacterBody2D

# --- ESTADÍSTICAS ---
var vida_maxima = 3
var vida_actual = 3
var velocidad = 100.0
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- CONTROL DE ESTADO ---
var jugador_objetivo = null
var esta_muerto = false
var esta_atacando = false   # <--- NUEVO
var recibiendo_dano = false # <--- NUEVO

@onready var sprite = $AnimatedSprite2D
@onready var barra_vida = $ProgressBar

func _ready():
	vida_actual = vida_maxima
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual
	
	$RangoVision.body_entered.connect(_on_rango_vision_entered)
	$RangoVision.body_exited.connect(_on_rango_vision_exited)
	$ZonaAtaque.body_entered.connect(_on_zona_ataque_entered)

func _physics_process(delta):
	# Aplicamos gravedad siempre para que no se quede flotando si le pegas en el aire
	if not is_on_floor():
		velocity.y += gravedad * delta

	# Si está haciendo una animación importante, se frena y no persigue [cite: 2]
	if esta_muerto or esta_atacando or recibiendo_dano:
		velocity.x = move_toward(velocity.x, 0, velocidad)
		move_and_slide()
		return
		
	# Lógica normal de persecución
	if jugador_objetivo != null:
		var direccion = sign(jugador_objetivo.global_position.x - global_position.x)
		velocity.x = direccion * velocidad
		
		if direccion != 0:
			sprite.flip_h = (direccion < 0)
			
		sprite.play("Walk") # <--- CAMBIADO
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)
		sprite.play("Idle") # <--- CAMBIADO

	move_and_slide()

# --- DETECCIÓN DEL JUGADOR (AGGRO) ---
func _on_rango_vision_entered(body):
	if body.name == "Jugador":
		jugador_objetivo = body

func _on_rango_vision_exited(body):
	if body.name == "Jugador":
		jugador_objetivo = null 

# --- HACER DAÑO AL JUGADOR ---
func _on_zona_ataque_entered(body):
	if esta_muerto or esta_atacando or recibiendo_dano:
		return
		
	if body.name == "Jugador" and body.has_method("recibir_dano"):
		esta_atacando = true
		sprite.play("Ataque") # <--- CAMBIADO
		
		# Hace daño al instante (o puedes mover esto debajo del await si quieres que el daño aplique al final del zarpazo)
		body.recibir_dano(global_position.x)
		
		# Esperamos a que termine la animación de ataque para volver a moverse
		await sprite.animation_finished
		esta_atacando = false

# --- RECIBIR DAÑO (De las bolas de fuego) ---
func sufrir_dano(cantidad: int, posicion_x_ataque: float):
	if esta_muerto:
		return
		
	vida_actual -= cantidad
	barra_vida.value = vida_actual
	
	var dir_empuje = sign(global_position.x - posicion_x_ataque)
	velocity.x = dir_empuje * 200
	velocity.y = -150
	
	if vida_actual <= 0:
		morir()
	else:
		recibiendo_dano = true
		sprite.play("Damage") # <--- CAMBIADO
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout # [cite: 4]
		sprite.modulate = Color.WHITE
		
		# Aseguramos que termine la animación antes de que vuelva a caminar
		if sprite.is_playing() and sprite.animation == "Damage":
			await sprite.animation_finished
			
		recibiendo_dano = false

func morir():
	esta_muerto = true
	barra_vida.visible = false
	
	# --- NUEVO: Apagamos la gravedad y el movimiento para que no se caigan ---
	set_physics_process(false) 
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	# (OJO: El arquero no tiene ZonaAtaque, así que esa línea solo la tendrán el oso, orco y cazador)
	if has_node("ZonaAtaque/CollisionShape2D"):
		$ZonaAtaque/CollisionShape2D.set_deferred("disabled", true)
	
	sprite.play("Death") 
	await sprite.animation_finished
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5) 
	await tween.finished
	queue_free()
