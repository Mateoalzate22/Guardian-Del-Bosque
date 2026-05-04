extends StaticBody2D

# 1. Variables de Salud (El 100% representado por 500 unidades)
var salud_maxima : float = 500.0
var salud_actual : float = 500.0
var dano_por_segundo : float = 25.0 # Ajusta este número para que sea más difícil o fácil

# 2. Referencia a la barra de vida
@onready var barra_vida = $ProgressBar

# 3. Lista para rastrear a los leñadores que están tocando el árbol
var atacantes = []

func _ready():
	# Configuramos la barra al inicio
	barra_vida.max_value = salud_maxima
	barra_vida.value = salud_actual

func _process(delta):
	# Si hay leñadores en la lista, el árbol pierde vida constantemente
	if atacantes.size() > 0:
		perder_vida(dano_por_segundo * atacantes.size() * delta)

func perder_vida(cantidad):
	salud_actual -= cantidad
	barra_vida.value = salud_actual # Actualizamos la barra visualmente
	
	if salud_actual <= 0:
		morir()

func morir():
	print("¡El Árbol Madre ha sido destruido!")
	# Aquí podrías poner una pantalla de Game Over
	queue_free()

# --- Conexión de señales de ZonaDeteccion ---

func _on_zona_deteccion_body_entered(body):
	# Si entra alguien del grupo "lenadores", lo sumamos a la lista de atacantes
	if body.is_in_group("lenadores"):
		if not atacantes.has(body):
			atacantes.append(body)

func _on_zona_deteccion_body_exited(body):
	# Si el leñador se va o es eliminado, lo quitamos de la lista
	if body in atacantes:
		atacantes.erase(body)
