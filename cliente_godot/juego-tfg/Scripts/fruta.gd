extends Area2D

# Variables que el Slime cambiará cuando nazca la fruta
var cantidad_curacion = 1
@onready var colision = $CollisionShape2D 

	
func _ready():
	# 1. Desactivamos la colisión nada más nacer
	colision.set_deferred("disabled", true)
	
	# Guardamos la posición exacta en la que estaba el Slime al morir
	var posicion_inicial = position 
	
	# 2. Animación de salto
	var tween = create_tween()
	# Sube 30 píxeles hacia arriba
	tween.tween_property(self, "position", posicion_inicial + Vector2(0, -30), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Vuelve EXACTAMENTE a la posición inicial (el suelo)
	tween.tween_property(self, "position", posicion_inicial, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(0.2)
	
	# 3. Esperamos y activamos
	await get_tree().create_timer(0.5).timeout
	colision.set_deferred("disabled", false)
	
	# 4. Conectamos para cogerla
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Si lo que toca la fruta es el Jugador...
	if body.name == "Jugador":
		
		# Comprobamos si necesita curarse (suponiendo que el máximo es 3)
		if body.vidas < 3:
			body.vidas += cantidad_curacion
			
			# Por si la pera cura 3 y teníamos 2 vidas, que no se pase de 3
			if body.vidas > 3:
				body.vidas = 3 
				
			# Llamamos a la función del jugador para que dibuje los corazones de nuevo
			body.actualizar_corazones()
			
			print("¡Ñam! Curado ", cantidad_curacion, " vidas. Tienes: ", body.vidas)
			
			# La fruta desaparece
			queue_free()
		else:
			print("Ya tienes la vida a tope, no me puedes comer todavía.")
func configurar_fruta(tipo: int):
	# Configuramos cuánta vida cura (1, 2 o 3)
	cantidad_curacion = tipo
	
	# Le decimos al sprite que reproduzca la animación "1", "2" o "3"
	$SpriteAnimado.play(str(tipo))
