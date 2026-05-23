extends Area2D

var cantidad_curacion = 1
@onready var colision = $CollisionShape2D 
@onready var sonido = $Sonido


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
	if body.name == "Jugador":
		if body.vidas < 3:
			body.vidas += cantidad_curacion
			if body.vidas > 3:
				body.vidas = 3 
				
			body.actualizar_corazones()
			print("¡Ñam! Curado ", cantidad_curacion, " vidas. Tienes: ", body.vidas)
			
			$SpriteAnimado.visible = false
			colision.set_deferred("disabled", true)
			sonido.play()
			await sonido.finished
			queue_free()
		else:
			print("Ya tienes la vida a tope, no me puedes comer todavía.")
			
func configurar_fruta(tipo: int):
	
	cantidad_curacion = tipo
	$SpriteAnimado.play(str(tipo))
