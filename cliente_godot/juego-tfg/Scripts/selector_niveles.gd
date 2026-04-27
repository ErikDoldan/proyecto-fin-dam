extends Control


func _ready():
	# Demostramos que el Singleton funciona:
	# Si tuviéramos el nombre en Global, lo pondríamos aquí
	print("Selector de Niveles cargado para el jugador ID: ", Global.jugador_id)

func _on_boton_nivel_1_pressed():
	# Ahora sí, esta es la forma limpia de ir al nivel
	get_tree().change_scene_to_file("res://Scenes/nivel_1.tscn")
