extends Node2D

var lenador_scene = preload("res://Escenas/lenador.tscn")
var timer_spawns: Timer
var tiempo_inicio_ms := 0

# 1. Referencias a la UI (Asegúrate de que los nombres coincidan con tu escena)
@onready var label_semillas = $CanvasLayer/ContenedorJugador/ContadorSemillas
@onready var vida_arbol_ui = $CanvasLayer/ContenedorArbol/VidaArbolUI
@onready var arbol = $arbol_madre
@onready var player = $Player
@onready var game_over_panel = $CanvasLayer/GameOverPanel
@onready var game_over_card = $CanvasLayer/GameOverPanel/CenterContainer/Card
@onready var game_over_label = $CanvasLayer/GameOverPanel/CenterContainer/Card/VBoxContainer/TituloGameOver
@onready var game_over_mensaje = $CanvasLayer/GameOverPanel/CenterContainer/Card/VBoxContainer/Mensaje
@onready var musica: AudioStreamPlayer = $MusicaJuego

var juego_terminado := false

func _ready():
	tiempo_inicio_ms = Time.get_ticks_msec()
	randomize()
	_intentar_musica_juego()

	# Configuración del Timer de enemigos ⏱️
	timer_spawns = Timer.new()
	timer_spawns.wait_time = 3.0
	timer_spawns.autostart = true
	timer_spawns.timeout.connect(_on_timer_timeout)
	add_child(timer_spawns)

	# Inicializar Interfaz del Árbol 🌳
	if arbol and vida_arbol_ui:
		vida_arbol_ui.max_value = arbol.salud_maxima
		vida_arbol_ui.value = arbol.salud_actual
		_actualizar_color_barra_arbol(arbol.salud_actual)
		# Conectamos la señal del árbol
		arbol.vida_cambiada.connect(_actualizar_vida_arbol)
		if arbol.has_signal("destruido"):
			arbol.destruido.connect(_on_arbol_destruido)
	else:
		print("Error: No se encontró el árbol o la barra de vida en la UI")

	if player and player.has_signal("muerto"):
		player.muerto.connect(_on_player_muerto)

	if game_over_panel:
		game_over_panel.visible = false
		game_over_panel.modulate.a = 0.0

	call_deferred("_configurar_pivotes_ui")

func _intentar_musica_juego() -> void:
	MusicaUtil.iniciar(musica, -6.0)

func _on_timer_timeout():
	if juego_terminado:
		return

	var dificultad = _obtener_parametros_dificultad()
	var cantidad_lenadores = dificultad["cantidad"] as int
	var intervalo = dificultad["intervalo"] as float

	if timer_spawns:
		timer_spawns.wait_time = intervalo

	for i in range(cantidad_lenadores):
		var lenador = lenador_scene.instantiate()
		var spawn_pos = _obtener_posicion_spawn_segura()
		lenador.position = spawn_pos
		add_child(lenador)

# Función para que la barra baje cuando el árbol sufra daño
func _actualizar_vida_arbol(nueva_vida):
	if vida_arbol_ui:
		vida_arbol_ui.value = nueva_vida
		_actualizar_color_barra_arbol(nueva_vida)

func _actualizar_color_barra_arbol(vida_actual: float):
	if not vida_arbol_ui or not arbol:
		return

	var porcentaje = (vida_actual / arbol.salud_maxima) * 100.0
	if porcentaje > 70.0:
		vida_arbol_ui.modulate = Color(0.2, 1.0, 0.2) # Verde
	elif porcentaje > 30.0:
		vida_arbol_ui.modulate = Color(1.0, 1.0, 0.2) # Amarillo
	else:
		vida_arbol_ui.modulate = Color(1.0, 0.2, 0.2) # Rojo

func _obtener_parametros_dificultad() -> Dictionary:
	var segundos = (Time.get_ticks_msec() - tiempo_inicio_ms) / 1000.0

	# Facil: 0-60s, Medio: 60-120s, Dificil: 120s+
	if segundos < 60.0:
		return {"cantidad": 1, "intervalo": 3.0}
	elif segundos < 120.0:
		return {"cantidad": 2, "intervalo": 2.2}
	else:
		return {"cantidad": 3, "intervalo": 1.5}

func _obtener_posicion_spawn_segura() -> Vector2:
	var spawn_pos = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))

	if player and spawn_pos.distance_to(player.position) < 300:
		spawn_pos += Vector2(randf_range(300, 500), randf_range(300, 500))

	return spawn_pos

# Función para actualizar el texto de las semillas 🌱
func actualizar_ui_semillas(cantidad):
	if label_semillas:
		label_semillas.text = "Semillas: " + str(cantidad)

func _on_arbol_destruido():
	_terminar_juego("Sin el Árbol Divino, el bosque pierde su corazón.\nLas raíces doradas ya no sostienen la vida.")

func _on_player_muerto():
	_terminar_juego("El Guardián ha caído...\nPero el viento entre las hojas sigue llamándote.")

func _terminar_juego(mensaje: String):
	if juego_terminado:
		return

	juego_terminado = true

	if timer_spawns:
		timer_spawns.stop()

	if player:
		player.set_physics_process(false)
		player.set_process_input(false)

	for enemigo in get_tree().get_nodes_in_group("enemigo"):
		enemigo.set_physics_process(false)
		enemigo.set_process(false)

	if game_over_label:
		game_over_label.text = "GAME OVER"
	if game_over_mensaje:
		game_over_mensaje.text = mensaje + "\n\nVuelve a levantarte: el bosque aún puede florecer."
	if game_over_panel:
		game_over_panel.visible = true
		game_over_panel.modulate.a = 0.0

	if game_over_card:
		game_over_card.scale = Vector2(0.9, 0.9)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(game_over_panel, "modulate:a", 1.0, 0.25)
	if game_over_card:
		tween.tween_property(game_over_card, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_boton_reintentar_pressed():
	get_tree().reload_current_scene()

func _configurar_pivotes_ui():
	if game_over_card:
		game_over_card.pivot_offset = game_over_card.size * 0.5


func _on_musica_juego_finished() -> void:
	$MusicaJuego.play()
	pass # Replace with function body.
