extends Area2D

func _on_body_entered(body):
	# Verificamos que sea el Player quien pisa la semilla
	if body.name == "Player":
		# Le pasamos esta misma semilla (self) al inventario del jugador
		body.recolectar_item(self)
		
		# La quitamos del mapa para que no se recoja dos veces
		queue_free()
