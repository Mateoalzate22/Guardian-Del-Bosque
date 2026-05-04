extends Control

@onready var ambiente_visual: Control = $AmbienteHojas/Root
@onready var fondo_capas: Array = [$FondoVerde, $FondoLuz, $BrumaDorada, $Vignette]
@onready var margen: MarginContainer = $MargenPrincipal
@onready var tarjeta: Panel = $MargenPrincipal/Tarjeta
@onready var titulo: Label = $MargenPrincipal/Tarjeta/VBoxContainer/Titulo
@onready var boton_iniciar: Button = $MargenPrincipal/Tarjeta/VBoxContainer/BotonIniciar
@onready var musica: AudioStreamPlayer = $MusicaMenu


func _ready() -> void:
	_intentar_musica()

	for n in fondo_capas:
		if n:
			n.modulate.a = 0.0

	if tarjeta:
		tarjeta.modulate.a = 0.0
		tarjeta.scale = Vector2(0.94, 0.94)

	if ambiente_visual:
		ambiente_visual.modulate.a = 0.0

	call_deferred("_configurar_pivotes")

	var tween := create_tween()
	tween.set_parallel(true)
	for n in fondo_capas:
		if n:
			tween.tween_property(n, "modulate:a", 1.0, 0.5)
	if ambiente_visual:
		tween.tween_property(ambiente_visual, "modulate:a", 1.0, 0.55)
	if tarjeta:
		tween.tween_property(tarjeta, "modulate:a", 1.0, 0.45)
		tween.tween_property(tarjeta, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_animar_boton()
	_animar_titulo()


func _configurar_pivotes() -> void:
	if tarjeta:
		tarjeta.pivot_offset = tarjeta.size * 0.5
	if titulo:
		titulo.pivot_offset = titulo.size * 0.5
	if boton_iniciar:
		boton_iniciar.pivot_offset = boton_iniciar.size * 0.5


func _intentar_musica() -> void:
	MusicaUtil.iniciar(musica, -6.0)


func _on_boton_iniciar_pressed() -> void:
	boton_iniciar.disabled = true

	var tween := create_tween()
	tween.set_parallel(true)
	if tarjeta:
		tween.tween_property(tarjeta, "modulate:a", 0.0, 0.22)
	for n in fondo_capas:
		if n:
			tween.tween_property(n, "modulate:a", 0.0, 0.22)
	if ambiente_visual:
		tween.tween_property(ambiente_visual, "modulate:a", 0.0, 0.22)
	if margen:
		tween.tween_property(margen, "modulate:a", 0.0, 0.22)

	tween.chain().tween_callback(func(): get_tree().change_scene_to_file("res://Escenas/mundo.tscn"))


func _animar_boton() -> void:
	if not boton_iniciar:
		return

	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(boton_iniciar, "scale", Vector2(1.045, 1.045), 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(boton_iniciar, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _animar_titulo() -> void:
	if not titulo:
		return

	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(titulo, "scale", Vector2(1.03, 1.03), 1.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(titulo, "scale", Vector2.ONE, 1.35).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
