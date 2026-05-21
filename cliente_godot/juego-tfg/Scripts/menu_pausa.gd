extends CanvasLayer

@onready var contenedor_principal = $VBoxContainer
@onready var menu_controles = $MenuControles

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		alternar_pausa()

func alternar_pausa():
	var nuevo_estado_pausa = not get_tree().paused
	get_tree().paused = nuevo_estado_pausa
	visible = nuevo_estado_pausa
	
	if not nuevo_estado_pausa:
		menu_controles.visible = false
		contenedor_principal.visible = true

func _on_btn_continuar_pressed():
	alternar_pausa()

func _on_btn_salir_pressed():
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://Scenes/selector_niveles.tscn")

func _on_btn_controles_pressed():
	contenedor_principal.visible = false
	menu_controles.visible = true

func _on_menu_controles_controles_cerrados():
	contenedor_principal.visible = true
