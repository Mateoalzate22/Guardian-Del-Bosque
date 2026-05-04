extends CharacterBody2D

const VELOCIDAD = 100.0
var salud = 2

# 1. Verifica que la carpeta se llame "Escenas" con E mayúscula como pusiste abajo
var semilla_escena = preload("res://Escenas/semilla.tscn")

@onready var nav_agent = $NavigationAgent2D
@onready var jugador = get_node("../Player")
@onready var animacion = $AnimationPlayer

func _physics_process(_delta):
	var objetivo = buscar_objetivo_prioritario()
	
	if objetivo:
		nav_agent.target_position = objetivo.global_position
		var siguiente_punto = nav_agent.get_next_path_position()
		var direccion = (siguiente_punto - global_position).normalized()
		
		velocity = direccion * VELOCIDAD
		move_and_slide()
		
		if direccion != Vector2.ZERO:
			actualizar_animacion(direccion)
		else:
			animacion.stop()
		
		if global_position.distance_to(objetivo.global_position) < 40:
			atacar_objetivo(objetivo)

func buscar_objetivo_prioritario():
	var objetivos = []

	if jugador and is_instance_valid(jugador):
		var jugador_muerto = jugador.get("esta_muerto")
		if not jugador_muerto:
			objetivos.append(jugador)

	var divino = get_tree().get_first_node_in_group("arbol_divino")
	if divino and is_instance_valid(divino):
		objetivos.append(divino)

	for arbol in get_tree().get_nodes_in_group("objetivos_leñadores"):
		if arbol and is_instance_valid(arbol):
			objetivos.append(arbol)

	if objetivos.is_empty():
		return null

	var mas_cercano = objetivos[0]
	for objetivo in objetivos:
		if global_position.distance_to(objetivo.global_position) < global_position.distance_to(mas_cercano.global_position):
			mas_cercano = objetivo

	return mas_cercano

func atacar_objetivo(obj):
	if obj == jugador:
		if jugador and jugador.has_method("recibir_dano"):
			jugador.recibir_dano(0.1)
	elif obj.has_method("recibir_hachazo"):
		obj.recibir_hachazo()

func actualizar_animacion(dir):
	if abs(dir.x) > abs(dir.y):
		if dir.x < 0: animacion.play("caminar_izquierda")
		else: animacion.play("caminar_derecha")
	else:
		if dir.y < 0: animacion.play("caminar_arriba")
		else: animacion.play("caminar_abajo")

func recibir_dano(cantidad):
	salud -= cantidad
	if salud <= 0:
		soltar_semilla()
		queue_free()

func soltar_semilla():
	if semilla_escena:
		var instancia = semilla_escena.instantiate()
		get_tree().current_scene.add_child(instancia)
		instancia.global_position = global_position
		instancia.scale = Vector2(1, 1)
		print("Semilla soltada correctamente en el mundo")
