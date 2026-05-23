extends Node

@onready var sonido_click = $SonidoClick

func _ready():
	get_tree().node_added.connect(_conectar_boton_automatico)

func _conectar_boton_automatico(nodo: Node):
	
	if nodo is Button:
		
		if not nodo.pressed.is_connected(_reproducir_click):
		
			nodo.pressed.connect(_reproducir_click)

func _reproducir_click():
	sonido_click.play()
