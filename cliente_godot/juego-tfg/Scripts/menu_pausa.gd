extends CanvasLayer

@onready var contenedor_principal = $VBoxContainer
@onready var menu_controles = $MenuControles
@onready var menu_volumen = $MenuVolumen
@onready var btn_pantalla = $VBoxContainer/BtnPantalla

func _ready():
	visible = false
	actualizar_texto_pantalla()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		alternar_pausa()

func alternar_pausa():
	var nuevo_estado_pausa = not get_tree().paused
	get_tree().paused = nuevo_estado_pausa
	visible = nuevo_estado_pausa
	
	if not nuevo_estado_pausa:
		menu_controles.visible = false
		menu_volumen.visible = false
		contenedor_principal.visible = true

func _on_btn_continuar_pressed():
	alternar_pausa()

func _on_btn_salir_pressed():
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://Scenes/selector_niveles.tscn")
	MusicaMenus.play()

func _on_btn_controles_pressed():
	contenedor_principal.visible = false
	menu_controles.visible = true

func _on_menu_controles_controles_cerrados():
	contenedor_principal.visible = true
	
func _on_btn_volumen_pressed():
	contenedor_principal.visible = false
	menu_volumen.visible = true

func _on_menu_volumen_volumen_cerrado():
	contenedor_principal.visible = true


func _on_btn_pantalla_pressed():
	if get_tree().root.mode == Window.MODE_WINDOWED:
		get_tree().root.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		get_tree().root.mode = Window.MODE_WINDOWED
		
	actualizar_texto_pantalla()
	
func actualizar_texto_pantalla():
	if get_tree().root.mode == Window.MODE_EXCLUSIVE_FULLSCREEN or get_tree().root.mode == Window.MODE_FULLSCREEN:
		btn_pantalla.text = "Pantalla en modo ventana"
	else:
		btn_pantalla.text = "Pantalla completa"
