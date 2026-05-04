extends CharacterBody2D

const VELOCIDAD = 200.0
signal muerto

var vida_maxima = 100.0
var vida_actual = 100.0
var semillas = 0
var ultima_direccion = Vector2.DOWN
var esta_muerto = false

var poder_escena = preload("res://Escenas/poder.tscn")
var arbol_plantable_escena = preload("res://Escenas/arbol_plantable.tscn")

@onready var animacion = $AnimationPlayer
@onready var barra_vida = $"../CanvasLayer/ContenedorJugador/ProgressBar" # Suponemos que esta es la barra de vida del jugador

func _ready():
	if barra_vida:
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida_actual
		actualizar_color_barra()

func _physics_process(_delta):
	var direccion = Vector2.ZERO
	if Input.is_action_pressed("ui_right"): direccion.x += 1
	if Input.is_action_pressed("ui_left"): direccion.x -= 1
	if Input.is_action_pressed("ui_down"): direccion.y += 1
	if Input.is_action_pressed("ui_up"): direccion.y -= 1
		
	direccion = direccion.normalized()
	velocity = direccion * VELOCIDAD
	move_and_slide()
	
	if direccion != Vector2.ZERO:
		ultima_direccion = direccion
		if abs(direccion.x) > abs(direccion.y):
			if direccion.x < 0: animacion.play("caminar_izquierda")
			else: animacion.play("caminar_derecha")
		else:
			if direccion.y < 0: animacion.play("caminar_arriba")
			else: animacion.play("caminar_abajo")
	else:
		if not animacion.current_animation == "curarse":
			animacion.stop()

	# Acciones usando just_pressed para evitar ejecución múltiple
	if Input.is_action_just_pressed("ui_accept"): # Barra espaciadora
		disparar()

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_Q:
			curarse()
		elif event.physical_keycode == KEY_S:
			sembrar()
		elif event.physical_keycode == KEY_A:
			# En caso de recolección manual
			pass

func recolectar_item(_item):
	if esta_muerto:
		return
	semillas += 1
	actualizar_ui_semillas()
	print("Semilla recogida. Total: ", semillas)

func disparar():
	if esta_muerto:
		return
	if poder_escena:
		var poder = poder_escena.instantiate()
		get_tree().current_scene.add_child(poder)
		poder.global_position = global_position
		poder.direccion = ultima_direccion

func sembrar():
	if esta_muerto:
		return
	if semillas > 0 and arbol_plantable_escena:
		semillas -= 1
		actualizar_ui_semillas()
		var arbol = arbol_plantable_escena.instantiate()
		get_tree().current_scene.add_child(arbol)
		arbol.global_position = global_position
		print("Árbol plantado")

func curarse():
	if esta_muerto:
		return
	var arbol = get_node_or_null("../arbol_madre")
	if arbol and global_position.distance_to(arbol.global_position) < 300:
		if vida_actual < vida_maxima:
			vida_actual = min(vida_actual + 20, vida_maxima)
			if barra_vida:
				barra_vida.value = vida_actual
			actualizar_color_barra()
			animacion.play("curarse")
			print("Curado por el Árbol Madre")
	else:
		print("Debes estar cerca del Árbol Madre para curarte")

func actualizar_ui_semillas():
	var mundo = get_node_or_null("..")
	if mundo and mundo.has_method("actualizar_ui_semillas"):
		mundo.actualizar_ui_semillas(semillas)
	else:
		var label = get_node_or_null("../CanvasLayer/ContenedorJugador/ContadorSemillas")
		if label:
			label.text = "Semillas: " + str(semillas)

func actualizar_color_barra():
	if barra_vida:
		if vida_actual > 70:
			barra_vida.modulate = Color(0.2, 1.0, 0.2) # Verde
		elif vida_actual > 30:
			barra_vida.modulate = Color(1.0, 1.0, 0.2) # Amarillo
		else:
			barra_vida.modulate = Color(1.0, 0.2, 0.2) # Rojo

func recibir_dano(cantidad: float):
	if esta_muerto:
		return

	vida_actual = max(vida_actual - cantidad, 0.0)
	if barra_vida:
		barra_vida.value = vida_actual
	actualizar_color_barra()

	if vida_actual <= 0.0:
		morir()

func morir():
	if esta_muerto:
		return

	esta_muerto = true
	set_physics_process(false)
	set_process_input(false)
	velocity = Vector2.ZERO
	animacion.stop()
	muerto.emit()
