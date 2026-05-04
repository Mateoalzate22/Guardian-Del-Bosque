extends StaticBody2D

# 1. Definimos los estados de crecimiento 📈
enum Estado {SEMILLA, FLOR, ARBOL}
var estado_actual = Estado.SEMILLA
var salud = 3 

@onready var sprite = $Sprite2D
@onready var timer = $CrecimientoTimer

# 2. Coordenadas de las regiones 🖼️
var region_semilla = Rect2(114.7, 408.7, 236.9, 145.2)
var region_flor = Rect2(450.6, 249.1, 368.6, 399.0)
var region_arbol = Rect2(830.4, 27.2, 533.0, 616.0)

func _ready():
	# Aseguramos que el sprite use regiones
	if sprite:
		sprite.region_enabled = true
		actualizar_apariencia()
	
	# Configuramos y arrancamos el temporizador
	if timer:
		timer.wait_time = 3.0
		timer.one_shot = false # Para que se repita hasta llegar a árbol
		timer.start()

func actualizar_apariencia():
	if not sprite: return
	
	match estado_actual:
		Estado.SEMILLA:
			sprite.region_rect = region_semilla
		Estado.FLOR:
			sprite.region_rect = region_flor
		Estado.ARBOL:
			sprite.region_rect = region_arbol

func _on_crecimiento_timer_timeout():
	if estado_actual == Estado.SEMILLA:
		estado_actual = Estado.FLOR
		actualizar_apariencia()
		print("¡Ha crecido una flor! 🌸")
	elif estado_actual == Estado.FLOR:
		estado_actual = Estado.ARBOL
		actualizar_apariencia()
		add_to_group("objetivos_leñadores")
		timer.stop() # Ya no crece más
		print("¡Árbol adulto listo! 🌳")

func recibir_hachazo():
	salud -= 1
	print("Vida del árbol: ", salud)
	if salud <= 0:
		remove_from_group("objetivos_leñadores")
		queue_free()
