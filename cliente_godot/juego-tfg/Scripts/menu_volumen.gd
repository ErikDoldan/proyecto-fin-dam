extends ColorRect

signal volumen_cerrado

@onready var slider = $SliderVolumen
var bus_master_id = AudioServer.get_bus_index("Master")

func _ready():
	visible = false
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_master_id))

func _on_slider_volumen_value_changed(value):
	var volumen_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_master_id, volumen_db)

func _on_btn_volver_pressed():
	visible = false
	volumen_cerrado.emit()
