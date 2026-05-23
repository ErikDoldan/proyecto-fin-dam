extends CharacterBody2D

# Referencia al nodo de animación
@onready var sprite = $AnimatedSprite2D
var vidas = 3
var recibiendo_dano = false 
var ha_gastado_doble_salto = false
const VELOCIDAD = 150.0
var velocidad_agua = 250.0
const FUERZA_SALTO = -300.0 
const MULTIPLICADOR_GRAVEDAD = 1.2 
var esta_congelado = false
var velocidad_dash = 300.0 
var esta_dasheando = false
var puede_dashear = true
const BOLA_FUEGO = preload("res://Scenes/bola_fuego.tscn")
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")
var puede_disparar = true

#SONIDOOOS
@onready var sonido_fuego = $SonidoFuego
@onready var sonido_salto = $SonidoSalto
@onready var sonido_dash = $SonidoDash
@onready var sonido_pupa = $SonidoPupa
@onready var sonido_escudo = $SonidoEscudo

@onready var contenedor_corazones = $UI/HBoxContainer

@onready var burbuja_escudo = $BurbujaEscudo
@onready var corazon_escudo = $UI/HBoxContainer/CorazonEscudo
var escudo_roto = false
var tiempo_regeneracion = 10.0

func _ready():
	pass

func _physics_process(delta):
	if esta_congelado:
		return
	
	var tiene_escudo = "escudo" in Global.habilidades_equipadas
	
	if tiene_escudo and not escudo_roto:
		burbuja_escudo.visible = true
		corazon_escudo.visible = true
	else:
		burbuja_escudo.visible = false
		corazon_escudo.visible = false
	
	
	if Input.is_action_just_pressed("disparar") and "fuego" in Global.habilidades_equipadas and puede_disparar:
		disparar_fuego()
		
	if recibiendo_dano:
		if not is_on_floor():
			velocity.y += gravedad * MULTIPLICADOR_GRAVEDAD * delta
		move_and_slide()
		return
		
	if esta_dasheando:
		velocity.y = 0 
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("dash") and "dash" in Global.habilidades_equipadas and puede_dashear:
		iniciar_dash()
		move_and_slide() 
		return 
			
	# 1. GRAVEDAD
	if not is_on_floor():
		velocity.y += gravedad * delta 
		
		if "planeador" in Global.habilidades_equipadas and Input.is_action_pressed("saltar") and velocity.y > 0:
			
			
			velocity.y = min(velocity.y, 50.0) 
			
			
			$ParticulasPlaneo.emitting = true
			
		else:
			
			$ParticulasPlaneo.emitting = false
			
	else:
		
		$ParticulasPlaneo.emitting = false
		
	# 2. RECARGAR DOBLE SALTO
	if is_on_floor():
		ha_gastado_doble_salto = false

	# 3. SALTAR Y DOBLE SALTO
	if Input.is_action_just_pressed("saltar"):
		if is_on_floor():
			# Salto normal desde el suelo
			velocity.y = FUERZA_SALTO
			sonido_salto.play()
		
		elif "doble_salto" in Global.habilidades_equipadas and not ha_gastado_doble_salto:
			# Doble salto en el aire
			velocity.y = FUERZA_SALTO
			ha_gastado_doble_salto = true
			
			sprite.play("Jump2")
			sonido_salto.play()
	# 4. MOVERSE A LOS LADOS
	var direccion = Input.get_axis("mover_izq","mover_der")
	
	# --- FRAGMENTO DEL AGUA ---
	var velocidad_actual = VELOCIDAD
	if "agua" in Global.habilidades_equipadas:
		velocidad_actual = velocidad_agua
	# ----------------------------------
	
	if direccion != 0:
		velocity.x = direccion * velocidad_actual 
		# Invertir el sprite según la dirección
		sprite.flip_h = (direccion < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad_actual) 

	# 5. GESTIÓN DE ANIMACIONES
	actualizar_animaciones(direccion)

	# 6. APLICAR MOVIMIENTO
	move_and_slide()


func actualizar_animaciones(direccion):
	# Si está haciendo la pirueta del doble salto, esperamos a que termine
	if sprite.animation == "Jump2" and sprite.is_playing():
		return

	if not is_on_floor():
		# Animación de salto normal si no es Jump2
		sprite.play("Jump")
	else:
		if direccion != 0:
			sprite.play("Run")
		else:
			sprite.play("Idle")


func recibir_dano(posicion_x_enemigo):
	if recibiendo_dano:
		return 
	
	recibiendo_dano = true
	
	if "escudo" in Global.habilidades_equipadas and not escudo_roto:
		romper_escudo(posicion_x_enemigo)
		return
		
	sonido_pupa.play()
	vidas -= 1
	print("Vidas restantes: ", vidas) 
	actualizar_corazones()
	
	var direccion_empuje = 1
	if global_position.x < posicion_x_enemigo:
		direccion_empuje = -1
		
	velocity.x = direccion_empuje * 150 
	velocity.y = -200 
	
	sprite.play("Hit")
	
	await get_tree().create_timer(0.4).timeout
	
	recibiendo_dano = false
	
	
func actualizar_corazones():
	var array_corazones = contenedor_corazones.get_children()
	
	for i in range(array_corazones.size()):
		if i < vidas:
			array_corazones[i].visible = true
		else:
			array_corazones[i].visible = false
			
	if vidas <= 0 and is_physics_processing():
		morir_definitivamente()
	
	
func morir_definitivamente():
	set_physics_process(false)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -50), 0.3)
	tween.tween_property(self, "position", position + Vector2(0, 500), 1.0).set_delay(0.3)
	
	sprite.play("Death")
	
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()

func iniciar_dash():
	esta_dasheando = true
	puede_dashear = false

	
	var direccion_x = 1
	if sprite.flip_h: 
		direccion_x = -1
	
	velocity.x = direccion_x * velocidad_dash

	# animación de dash
	# sprite.play("Dash")
	sonido_dash.play()
	
	# El dash dura solo 0.2 segundos
	await get_tree().create_timer(0.2).timeout
	esta_dasheando = false
	
	# Tiempo de espera antes de poder volver a usarlo (1 segundo)
	await get_tree().create_timer(0.5).timeout
	puede_dashear = true

func disparar_fuego():
	puede_disparar = false
	var nueva_bola = BOLA_FUEGO.instantiate()
	sonido_fuego.play()
	
	var direccion_x = 1
	if sprite.flip_h:
		direccion_x = -1
		# Actualizado para usar Sprite2D normal
		nueva_bola.get_node("Sprite2D").flip_h = true 
	
	nueva_bola.direccion = direccion_x
	nueva_bola.global_position = self.global_position + Vector2(20 * direccion_x, 0)
	
	# Para q la bola que ignore las colisiones con el jugador.
	# Así evito empujarme a mi mismo o atascarme al disparar.
	nueva_bola.add_collision_exception_with(self)
	
	get_parent().add_child(nueva_bola)
	await get_tree().create_timer(0.3).timeout
	puede_disparar = true
	
func romper_escudo(posicion_x_enemigo):
	escudo_roto = true
	
	
	sonido_escudo.play()
	
	# Me empuja un poquito para que el golpe se sienta real, pero sin hacer animación de daño grave
	var direccion_empuje = 1
	if global_position.x < posicion_x_enemigo:
		direccion_empuje = -1
		
	velocity.x = direccion_empuje * 150 
	velocity.y = -150 
	
	# Vuelvo a ser vulnerable
	await get_tree().create_timer(0.2).timeout
	recibiendo_dano = false
	
	# Inicia la regeneración del escudo en la sombra
	await get_tree().create_timer(tiempo_regeneracion).timeout
	escudo_roto = false
	print("¡Escudo regenerado!")
