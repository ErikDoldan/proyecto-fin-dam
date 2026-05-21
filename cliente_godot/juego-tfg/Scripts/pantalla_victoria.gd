extends CanvasLayer

@onready var label_puntuacion = $VBoxContainer/Puntuacion

func _ready():
	# Nos aseguramos de que el personaje empiece a celebrar nada más aparecer la pantalla
	$AnimacionJugador.play("victoria") 
	
func mostrar_puntuacion(puntos_totales):
	label_puntuacion.text = "Puntuación total: " + str(puntos_totales)

func _on_boton_salir_pressed():
	
	get_tree().change_scene_to_file("res://Scenes/selector_niveles.tscn")
	
