extends CharacterBody2D

# Hemos aumentado la velocidad y el salto para que sea más dinámico
const VELOCIDAD = 400.0
const FUERZA_SALTO = -650.0 
const MULTIPLICADOR_GRAVEDAD = 2.5 # ¡La clave para que no flote!

var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# 1. APLICAR GRAVEDAD (Ahora multiplicada para caer más rápido)
	if not is_on_floor():
		velocity.y += gravedad * MULTIPLICADOR_GRAVEDAD * delta

	# 2. SALTAR
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = FUERZA_SALTO

	# 3. MOVERSE A LOS LADOS
	var direccion = Input.get_axis("ui_left", "ui_right")
	
	if direccion != 0:
		velocity.x = direccion * VELOCIDAD
	else:
		velocity.x = move_toward(velocity.x, 0, VELOCIDAD)

	# 4. APLICAR MOVIMIENTO
	move_and_slide()
