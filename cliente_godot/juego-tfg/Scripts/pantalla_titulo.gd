extends Control

@onready var label_pulsar = $LabelPulsar

# Pon aquí la ruta exacta a tu escena de logueo
@export var ruta_login: String = "res://Scenes/menu_principal.tscn"

func _process(_delta):
	# ¡El truco pro!: Usamos una onda senoidal basada en el tiempo del reloj interno
	# Esto hace que la transparencia (alfa) suba y baje suavemente entre 0 y 1
	label_pulsar.modulate.a = abs(sin(Time.get_ticks_msec() * 0.003))

func _input(event):
	# Si detectamos que el jugador ha pulsado algo (teclado, ratón o mando)
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		# Comprobamos que sea el momento de "pulsar hacia abajo" (no cuando suelta la tecla)
		if event.is_pressed():
			print("¡Botón pulsado! Pasando al Login...")
			get_tree().change_scene_to_file(ruta_login)
