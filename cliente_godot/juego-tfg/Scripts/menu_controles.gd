extends ColorRect

signal controles_cerrados

func _ready():
	# Por defecto, este menú siempre empieza oculto cuando arranca el juego
	visible = false

func _on_btn_volver_pressed():
	# Se oculta a sí mismo
	visible = false
	# Avisa al mundo de que se ha cerrado
	controles_cerrados.emit()
