extends Control

@onready var label_pulsar = $LabelPulsar

@export var ruta_login: String = "res://Scenes/menu_principal.tscn"

func _process(_delta):
	
	#EXPLICACION DE CHATI PARA PORQUE LAS LETRES TIENEN EFECTO GUAPO
	# ¡El truco pro!: Usamos una onda senoidal basada en el tiempo del reloj interno
	# Esto hace que la transparencia (alfa) suba y baje suavemente entre 0 y 1
	label_pulsar.modulate.a = abs(sin(Time.get_ticks_msec() * 0.003))

func _input(event):
	
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.is_pressed():
			print("¡Botón pulsado! Pasando al Login...")
			get_tree().change_scene_to_file(ruta_login)
