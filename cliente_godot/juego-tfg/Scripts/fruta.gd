extends Area2D

var cantidad_curacion = 1
@onready var colision = $CollisionShape2D 

func _ready():
	
	colision.set_deferred("disabled", true)
	
	var posicion_inicial = position 
	
	# Animación de salto
	var tween = create_tween()
	# Sube 30 píxeles hacia arriba
	tween.tween_property(self, "position", posicion_inicial + Vector2(0, -30), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Vuelve a la posición inicial
	tween.tween_property(self, "position", posicion_inicial, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(0.2)
	
	
	await get_tree().create_timer(0.5).timeout
	colision.set_deferred("disabled", false)
	
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Si lo que toca la fruta es el Jugador
	if body.name == "Jugador":
		
		# Comprueba si necesita curarse 
		if body.vidas < 3:
			body.vidas += cantidad_curacion
			
			# Por si la pera cura 3 y teníamos 2 vidas, que no se pase de 3
			if body.vidas > 3:
				body.vidas = 3 
				
			# Función del jugador para que dibuje los corazones de nuevo
			body.actualizar_corazones()
			
			print("¡Ñam! Curado ", cantidad_curacion, " vidas. Tienes: ", body.vidas)
			
			# La fruta desaparece
			queue_free()
		else:
			print("Ya tienes la vida a tope, no me puedes comer todavía.")
func configurar_fruta(tipo: int):
	
	cantidad_curacion = tipo
	$SpriteAnimado.play(str(tipo))
