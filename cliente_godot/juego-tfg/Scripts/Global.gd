extends Node

var jugador_id: int = -1
var puntuacion_actual: int = 0
var nivel_desbloqueado: int = 1
	

var habilidades = {
	"doble_salto": false,
	"dash": false, 
	"ataque_fuego": false,
	"gancho": false,
	"escudo": false,
	"super_velocidad": false,
	"planeador": false,
	"buceo": false
}



var habilidades_equipadas = [] 


var consumibles = {
	"pocion_vida": 0
}

func set_jugador_id(id: int):
	jugador_id = id
	print("Global: ID de jugador guardado: ", jugador_id)
