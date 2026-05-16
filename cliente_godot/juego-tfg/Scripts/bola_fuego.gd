extends CharacterBody2D

var velocidad_x = 350.0 # Velocidad a la que avanza
var fuerza_rebote = -200.0 # Cuánto salta al tocar el suelo
var direccion = 1 

var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")
	
var peso_bola = 2

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta):
	# 3. Le aplicamos el peso extra a la gravedad
	velocity.y += gravedad * peso_bola * delta

	velocity.x = velocidad_x * direccion
	move_and_slide()

	if is_on_floor():
		velocity.y = fuerza_rebote

	if is_on_wall():
		queue_free()

func _on_screen_exited():
	queue_free() # Se borra al salir de la pantalla
