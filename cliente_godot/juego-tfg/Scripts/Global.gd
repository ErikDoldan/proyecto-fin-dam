extends Node

# Aquí guardaremos el ID que nos devuelva Django al empezar
var jugador_id: int = -1
var puntuacion_actual: int = 0
var tiene_doble_salto: bool = false
# Función para actualizar el ID desde el MenuPrincipal
func set_jugador_id(id: int):
	jugador_id = id
	print("Global: ID de jugador guardado: ", jugador_id)
