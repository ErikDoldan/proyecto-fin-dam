extends CharacterBody2D

# Referencia al nodo de animación
# Asegúrate de que el nombre coincida con el de tu escena ($AnimatedSprite2D)
@onready var sprite = $AnimatedSprite2D
var vidas = 3
var recibiendo_dano = false 
var tiene_doble_salto = false
const VELOCIDAD = 150.0
const FUERZA_SALTO = -300.0 
const MULTIPLICADOR_GRAVEDAD = 1.2 
var esta_congelado = false

var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var contenedor_corazones = $UI/HBoxContainer

func _physics_process(delta):
	if esta_congelado:
		return
	if recibiendo_dano:
		if not is_on_floor():
			velocity.y += gravedad * MULTIPLICADOR_GRAVEDAD * delta
		move_and_slide()
		return
		
	if not is_on_floor():
		velocity.y += gravedad * MULTIPLICADOR_GRAVEDAD * delta

	# 2. SALTAR
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = FUERZA_SALTO

	# 3. MOVERSE A LOS LADOS
	var direccion = Input.get_axis("ui_left", "ui_right")
	
	if direccion != 0:
		velocity.x = direccion * VELOCIDAD
		# Invertir el sprite según la dirección
		sprite.flip_h = (direccion < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD)

	# 4. GESTIÓN DE ANIMACIONES
	actualizar_animaciones(direccion)

	# 5. APLICAR MOVIMIENTO
	move_and_slide()

func actualizar_animaciones(direccion):
	if not is_on_floor():
		# Si está en el aire, reproducimos Jump
		sprite.play("Jump")
	else:
		if direccion != 0:
			# Si se mueve en el suelo, reproducimos Run
			sprite.play("Run")
		else:
			# Si está quieto en el suelo, reproducimos Idle
			sprite.play("Idle")
func recibir_dano(posicion_x_enemigo):
	if recibiendo_dano:
		return 
	vidas -= 1
	recibiendo_dano = true
	print("Auch! Vidas restantes: ", vidas) 
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
			
	# BONUS: ¿Qué pasa si llegamos a 0 vidas?
	# Si llegamos a 0 vidas y aún no hemos desactivado el jugador, morimos
	if vidas <= 0 and is_physics_processing():
		morir_definitivamente()
	
func morir_definitivamente():
	# 1. Desactivamos las físicas para que no pueda moverse ni saltar más
	set_physics_process(false)
	
	# 2. Le damos un saltito dramático hacia arriba (opcional pero queda genial)
	# Como desactivamos las físicas, usamos un Tween para moverlo
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -50), 0.3)
	tween.tween_property(self, "position", position + Vector2(0, 500), 1.0).set_delay(0.3)
	
	# 3. Reproducimos la animación (si tienes una de morir ponla aquí, sino usamos dmg)
	sprite.play("dmg")
	
	# 4. Esperamos 1.5 segundos para que el jugador asimile la derrota
	await get_tree().create_timer(1.5).timeout
	
	# 5. ¡Reiniciamos el nivel actual por completo!
	get_tree().reload_current_scene()
