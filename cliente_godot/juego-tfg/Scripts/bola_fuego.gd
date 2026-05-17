extends CharacterBody2D

var velocidad_x = 350.0 # Velocidad a la que avanza
var fuerza_rebote = -200.0 # Cuánto salta al tocar el suelo
var direccion = 1 

var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")
var ha_explotado = false
var peso_bola = 2

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta):

	if ha_explotado:
		return
		
	velocity.y += gravedad * peso_bola * delta

	velocity.x = velocidad_x * direccion
	move_and_slide()

	# --- NUEVO: DETECTAR CHOQUES CONTRA ENEMIGOS ---
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto_chocado = colision.get_collider()
		
		# Verificamos si el objeto con el que chocamos tiene la función de daño
		if objeto_chocado and objeto_chocado.has_method("sufrir_dano"):
			objeto_chocado.sufrir_dano(1, global_position.x)
			explotar() # La bola explota al darle al enemigo
			return # Cortamos aquí para que no siga calculando físicas
	# -----------------------------------------------

	if is_on_floor():
		velocity.y = fuerza_rebote

	if is_on_wall():
		explotar()
		
func explotar():
	ha_explotado = true
	
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false
	$CPUParticles2D.emitting = false 
	$Explosion.emitting = true
	
	await get_tree().create_timer(0.5).timeout
	queue_free()
	
func _on_screen_exited():
	queue_free() # Se borra al salir de la pantalla
