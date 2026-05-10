extends Node

var jugador_id: int = -1
var puntuacion_actual: int = 0

# 1. EL CATÁLOGO COMPLETO (8 Habilidades)
# True = Desbloqueada (Color) | False = Bloqueada (Candado)
var habilidades = {
	"doble_salto": false,
	"dash": false, # Ejemplo de habilidad futura
	"ataque_fuego": false,
	"gancho": false,
	"escudo": false,
	"super_velocidad": false,
	"planeador": false,
	"buceo": false
}

# 2. LAS 4 CASILLAS DE EQUIPAMIENTO
# Aquí guardaremos los nombres de las habilidades que el jugador decida equiparse
# Ejemplo de cómo se verá por dentro: ["doble_salto", "dash"]
var habilidades_equipadas = [] 

# 3. CONSUMIBLES (Opcional por ahora, pero lo dejamos preparado)
var consumibles = {
	"pocion_vida": 0
}

func set_jugador_id(id: int):
	jugador_id = id
	print("Global: ID de jugador guardado: ", jugador_id)
