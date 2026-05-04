extends CanvasLayer

@onready var hojas: CPUParticles2D = $Root/Hojas
@onready var polen: CPUParticles2D = $Root/Polen

var _t: float = 0.0


func _ready() -> void:
	_configurar_area()
	var vp := get_viewport()
	if vp:
		vp.size_changed.connect(_configurar_area)


func _process(dt: float) -> void:
	_t += dt
	if not hojas:
		return

	var viento := sin(_t * 0.95) * 55.0 + cos(_t * 0.41) * 22.0
	var rafaga := sin(_t * 2.1) * 18.0

	hojas.gravity = Vector2(62.0 + viento + rafaga, 118.0)
	hojas.direction = Vector2(viento * 0.012, 1.0).normalized()

	if polen:
		polen.gravity = Vector2(38.0 + viento * 0.55, 52.0)
		polen.direction = Vector2(viento * 0.008, 0.35).normalized()


func _configurar_area() -> void:
	var vp := get_viewport()
	if not vp or not hojas:
		return

	var sz: Vector2 = vp.get_visible_rect().size
	var cx := sz.x * 0.5

	hojas.position = Vector2(cx, -50.0)
	hojas.emission_rect_extents = Vector2(sz.x * 0.52, 28.0)

	if polen:
		polen.position = Vector2(cx, -30.0)
		polen.emission_rect_extents = Vector2(sz.x * 0.55, 20.0)
