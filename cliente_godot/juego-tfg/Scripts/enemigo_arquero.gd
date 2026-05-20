extends CharacterBody2D

# --- ESTADÍSTICAS ---
var vida_maxima = 3
var vida_actual = 3
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")


var jugador_objetivo = null
var esta_muerto = false
var esta_atacando = false
var recibiendo_dano = false
var puede_disparar = true
var tiempo_recarga = 1.5 # Segundos de espera entre cada flecha


const FLECHA = preload("res://Scenes/flecha.tscn") 

@onready var sprite = $AnimatedSprite2D
@onready var barra_vida = $ProgressBar

func _ready():
	vida_actual = vida_maxima
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual
	
	$RangoVision.body_entered.connect(_on_rango_vision_entered)
	$RangoVision.body_exited.connect(_on_rango_vision_exited)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta

	# Si le pegan o muere, se queda quieto
	if esta_muerto or recibiendo_dano:
		velocity.x = 0
		move_and_slide()
		return
		
	# --- LÓGICA DEL ARQUERO ---
	if jugador_objetivo != null:
		
		var direccion = sign(jugador_objetivo.global_position.x - global_position.x)
		if direccion != 0:
			sprite.flip_h = (direccion < 0)
			
	
		if puede_disparar and not esta_atacando:
			iniciar_ataque()
	else:
		
		if not esta_atacando:
			sprite.play("Idle")

	velocity.x = 0
	move_and_slide()


func iniciar_ataque():
	esta_atacando = true
	puede_disparar = false
	sprite.play("Ataque")
	
	# Esperamos 0.4s para que la flecha salga justo cuando estira la cuerda en la animación
	await get_tree().create_timer(0.4).timeout 
	
	if not esta_muerto and not recibiendo_dano and jugador_objetivo != null:
		disparar_flecha()
		
	await sprite.animation_finished
	esta_atacando = false
	
	# Tiempo de enfriamiento antes de volver a disparar
	await get_tree().create_timer(tiempo_recarga).timeout
	puede_disparar = true

func disparar_flecha():
	
	if jugador_objetivo == null:
		return
		
	var nueva_flecha = FLECHA.instantiate()
	
	var objetivo_pos = jugador_objetivo.global_position + Vector2(0, -10)
	var direccion_hacia_jugador = (objetivo_pos - self.global_position).normalized()
	
	nueva_flecha.direccion = direccion_hacia_jugador
	
	nueva_flecha.rotation = direccion_hacia_jugador.angle()
	
	nueva_flecha.global_position = self.global_position + (direccion_hacia_jugador * 20)
	
	get_parent().add_child(nueva_flecha)
# --- DETECCIÓN DEL JUGADOR ---
func _on_rango_vision_entered(body):
	if body.name == "Jugador":
		jugador_objetivo = body

func _on_rango_vision_exited(body):
	if body.name == "Jugador":
		jugador_objetivo = null 

# --- RECIBIR DAÑO ---
func sufrir_dano(cantidad: int, posicion_x_ataque: float):
	if esta_muerto:
		return
		
	vida_actual -= cantidad
	barra_vida.value = vida_actual
	
	if vida_actual <= 0:
		morir()
	else:
		recibiendo_dano = true
		esta_atacando = false # Si le pegas, le cortas el ataque
		sprite.play("Damage")
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.2).timeout
		sprite.modulate = Color.WHITE
		
		if sprite.is_playing() and sprite.animation == "Damage":
			await sprite.animation_finished
			
		recibiendo_dano = false

func morir():
	esta_muerto = true
	barra_vida.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	sprite.play("Death")
	await sprite.animation_finished
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5) 
	await tween.finished
	queue_free()
