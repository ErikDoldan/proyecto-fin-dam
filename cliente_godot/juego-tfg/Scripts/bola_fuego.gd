extends Area2D

var velocidad = 400.0
var direccion = 1 # 1 es derecha, -1 es izquierda

func _ready():
	# Conectamos las colisiones y el detector de pantalla
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta):
	# Movemos la bola hacia adelante
	position.x += velocidad * direccion * delta

func _on_body_entered(body):
	# Si toca al jugador, la ignoramos (para no suicidarte con tu propio fuego)
	if body.name == "Jugador":
		return
		
	# ¡Aquí luego meteremos el código para hacer daño a los enemigos!
	print("¡Pum! La bola chocó contra: ", body.name)
	
	# Al chocar contra cualquier otra cosa (pared, suelo, enemigo), se destruye
	queue_free()

func _on_screen_exited():
	# Si la bola sale de la pantalla, se borra sola
	queue_free()
