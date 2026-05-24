extends CharacterBody2D

# --- ESTADÍSTICAS DEL BOSS ---
var vida_maxima = 30 
var vida_actual = 30
var velocidad = 80.0
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- ESTADOS ---
var jugador_objetivo = null
var esta_muerto = false
var esta_atacando = false
var recibiendo_dano = false
var puede_atacar = true
var tiempo_recarga_ataque = 2.0 # Segundos de descanso entre ataques

const BOLA_FUEGO_BOSS = preload("res://Scenes/bola_fuego_boss.tscn")
const PANTALLA_VICTORIA = preload("res://Scenes/pantalla_victoria.tscn")

# --- NODOS ---
@onready var sprite = $AnimatedSprite2D
@onready var ui_boss = $UI_Boss 
@onready var barra_vida = $UI_Boss/ContenedorBoss/ProgressBar
@onready var punto_disparo = $PuntoDisparo


@onready var colision_melee = $HitboxMelee/CollisionShape2D
@onready var colision_llamarada = $HitboxLlamarada/CollisionShape2D
@onready var colision_onda = $HitboxOndaChoque/CollisionShape2D

#Sonidos
@onready var sonido_pupa = $SonidoPupa
@onready var sonido_muerto = $SonidoDeath
@onready var sonido_ataque = $SonidoAtack1
@onready var sonido_salto = $SonidoSalto
@onready var sonido_spell = $SonidoSpell
@onready var sonido_llamarada = $SonidoLlamarada


func _ready():
	
	ui_boss.visible = false #La barra de vida es invisible hasta que entres a la zona 
	vida_actual = vida_maxima
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
	
	# Las hitbox de hostias empiezan desactivadas
	colision_melee.set_deferred("disabled", true)
	colision_llamarada.set_deferred("disabled", true)
	colision_onda.set_deferred("disabled", true)
	
	
	$RangoVision.body_entered.connect(_on_rango_vision_entered)
	$RangoVision.body_exited.connect(_on_rango_vision_exited)
	
	
	$HitboxMelee.body_entered.connect(_on_hitbox_body_entered)
	$HitboxLlamarada.body_entered.connect(_on_hitbox_body_entered)
	$HitboxOndaChoque.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta

	if esta_muerto or esta_atacando or recibiendo_dano:
		velocity.x = 0
		move_and_slide()
		return

	if jugador_objetivo != null:
		# Mirar al jugador
		var direccion_x = sign(jugador_objetivo.global_position.x - global_position.x)
		if direccion_x != 0:
			sprite.flip_h = (direccion_x > 0)
			
			# Como el boss mira a la Izquierda por defecto (escala = 1),
			# para que pegue a la derecha (direccion = 1) tenemos que ponerle escala = -1
			var escala_hitboxes = -direccion_x
			
			
			punto_disparo.position.x = abs(punto_disparo.position.x) * direccion_x 
			
			
			$HitboxMelee.scale.x = escala_hitboxes
			$HitboxLlamarada.scale.x = escala_hitboxes
			$HitboxOndaChoque.scale.x = escala_hitboxes
			
		var distancia = global_position.distance_to(jugador_objetivo.global_position)
		
		# Decidir qué hacer según la distancia
		if puede_atacar:
			decidir_ataque(distancia)
		else:
			# Si no puede atacar, camina hacia el jugador
			if distancia > 40: # No se pega demasiado
				velocity.x = direccion_x * velocidad
				sprite.play("Walk")
			else:
				velocity.x = 0
				sprite.play("Idle")
	else:
		velocity.x = 0
		if not esta_atacando and not recibiendo_dano:
			sprite.play("Idle")

	move_and_slide()
	
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto_chocado = colision.get_collider()
		if objeto_chocado and objeto_chocado.name == "Jugador" and objeto_chocado.has_method("recibir_dano"):
			objeto_chocado.recibir_dano(global_position.x)
			
			
# --- INTELIGENCIA DEL BOSS ---

func decidir_ataque(distancia):
	esta_atacando = true
	puede_atacar = false
	velocity.x = 0
	
	if distancia < 60.0:
		# Si estás pegado, elige 50/50 entre darte un zarpazo o saltarte encima
		if randf() > 0.5:
			await ataque_melee()
		else:
			await ataque_salto()
	elif distancia < 150.0:
		# A media distancia usa la llamarada
		await ataque_llamarada()
	else:
		# A larga distancia SOLO tira hechizos
		await ataque_spell()
			
	esta_atacando = false
	
	# Tiempo de descanso tras atacar
	await get_tree().create_timer(tiempo_recarga_ataque).timeout
	puede_atacar = true

# --- LOS 4 ATAQUES ---
func ataque_melee():
	sprite.play("Attack")
	await get_tree().create_timer(1).timeout 
	sonido_ataque.play()
	colision_melee.set_deferred("disabled", false)
	await get_tree().create_timer(0.2).timeout
	colision_melee.set_deferred("disabled", true)
	await sprite.animation_finished

func ataque_llamarada():
	sprite.play("AtackRange")
	sonido_llamarada.play()
	await get_tree().create_timer(0.8).timeout 
	colision_llamarada.set_deferred("disabled", false)
	await get_tree().create_timer(0.3).timeout
	colision_llamarada.set_deferred("disabled", true)
	await sprite.animation_finished

func ataque_salto():
	sprite.play("JumpAtack")
	await get_tree().create_timer(1.3).timeout 
	sonido_salto.play()
	colision_onda.set_deferred("disabled", false)
	
	await get_tree().create_timer(0.2).timeout
	colision_onda.set_deferred("disabled", true)
	await sprite.animation_finished

func ataque_spell():
	sprite.play("Spell")
	await get_tree().create_timer(0.5).timeout 
	sonido_spell.play()
	if jugador_objetivo != null and not esta_muerto:
		
		for i in range(3):
			if esta_muerto or jugador_objetivo == null:
				break
			sonido_spell.play()	
			var nueva_bola = BOLA_FUEGO_BOSS.instantiate()
			var dir_hacia_jugador = (jugador_objetivo.global_position - punto_disparo.global_position).normalized()
			
			nueva_bola.velocidad = 400.0 
			nueva_bola.direccion = dir_hacia_jugador
			nueva_bola.rotation = dir_hacia_jugador.angle()
			nueva_bola.global_position = punto_disparo.global_position
			get_parent().add_child(nueva_bola)
			
			
			await get_tree().create_timer(0.15).timeout 

	await get_tree().create_timer(0.2).timeout
	
# --- DAÑO A JUGADOR ---
func _on_hitbox_body_entered(body):
	if body.name == "Jugador" and body.has_method("recibir_dano"):
		body.recibir_dano(global_position.x)

# --- DETECCIÓN ---
func _on_rango_vision_entered(body):
	if body.name == "Jugador":
		jugador_objetivo = body
		ui_boss.visible = true #A la que entro en el rango se activa para zurrarnos
func _on_rango_vision_exited(body):
	if body.name == "Jugador":
		jugador_objetivo = null

# --- RECIBIR DAÑO ---
@warning_ignore("unused_parameter")
func sufrir_dano(cantidad: int, posicion_x_ataque: float):
	if esta_muerto: return
	
	vida_actual -= cantidad
	if barra_vida: barra_vida.value = vida_actual
	
	if vida_actual <= 0:
		morir()
	else:
	
		sprite.modulate = Color.RED
		sonido_pupa.play()
		await get_tree().create_timer(0.2).timeout
		sprite.modulate = Color.WHITE

func morir():
	esta_muerto = true
	ui_boss.visible = false
	if barra_vida: barra_vida.visible = false
	
	# --- ¡AQUÍ ESTÁ LA MAGIA! ---
	
	set_physics_process(false) 
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	sprite.play("Death") 
	sonido_muerto.play()
	await sprite.animation_finished
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
	await tween.finished
	# ---Pantalla de victoria ---
	
	await get_tree().create_timer(2.0).timeout
	
	var victoria = PANTALLA_VICTORIA.instantiate()
	
	get_parent().add_child(victoria)
	
	victoria.mostrar_puntuacion(Global.puntuacion_actual) 
	
	queue_free()
