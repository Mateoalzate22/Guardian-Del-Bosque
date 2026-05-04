extends Area2D

# Velocidad a la que viajará el poder
const VELOCIDAD = 500.0

# Esta variable la llenaremos desde el jugador al disparar
var direccion = Vector2.ZERO

func _process(delta):
	# Si tenemos una dirección, nos movemos hacia ella
	if direccion != Vector2.ZERO:
		position += direccion * VELOCIDAD * delta

# Esta función se conecta con el VisibleOnScreenNotifier2D
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() # Borra el poder del juego cuando sale de pantalla

func _on_body_entered(body):
	if body.is_in_group("enemigo"):
		if body.has_method("recibir_dano"):
			body.recibir_dano(1)
		queue_free()
