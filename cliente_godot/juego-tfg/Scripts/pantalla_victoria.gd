extends CanvasLayer

@onready var label_puntuacion = $VBoxContainer/Puntuacion
@onready var sonido_vic = $SonidoVictoria

func _ready():
	# El personaje empiece a celebrar nada más aparecer la pantalla
	$AnclaAnimacion/AnimacionJugador.play("victoria")	
	sonido_vic.play()
	
func mostrar_puntuacion(puntos_totales):
	label_puntuacion.text = "Puntuación total: " + str(puntos_totales)

func _on_boton_salir_pressed():
	MusicaMenus.play()
	get_tree().change_scene_to_file("res://Scenes/selector_niveles.tscn")
	
