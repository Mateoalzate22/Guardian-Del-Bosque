extends RefCounted
class_name MusicaUtil

const CANDIDATOS: PackedStringArray = [
	"res://audio/musica.wav",
	"res://Audio/musica.wav",
	"res://audio/Musica.wav",
	"res://Audio/Musica.wav",
	"res://audio/musica.ogg",
	"res://Audio/musica.ogg",
]


static func encontrar_ruta() -> String:
	for p in CANDIDATOS:
		if FileAccess.file_exists(p):
			return p
	return ""


static func iniciar(player: AudioStreamPlayer, volume_db: float) -> void:
	if player == null:
		return

	var ruta := encontrar_ruta()
	if ruta.is_empty():
		push_warning(
			"Musica: no se encontro el archivo. Pon musica.wav en la carpeta audio/ del proyecto "
			+ "(nombre exacto: musica.wav). Rutas probadas: " + str(CANDIDATOS)
		)
		return

	var stream: Variant = load(ruta)
	if stream == null:
		push_warning("Musica: load() devolvio null para: %s (¿importacion rota? Reimporta en Godot.)" % ruta)
		return

	if not (stream is AudioStream):
		push_warning("Musica: el recurso no es AudioStream: %s" % ruta)
		return

	var audio_stream := stream as AudioStream

	if audio_stream is AudioStreamWAV:
		var w := audio_stream as AudioStreamWAV
		w.loop_mode = AudioStreamWAV.LOOP_DISABLED
		if not player.get_meta("_musica_loop_conectado", false):
			player.set_meta("_musica_loop_conectado", true)
			player.finished.connect(func(): player.play())
	elif audio_stream is AudioStreamOggVorbis:
		(audio_stream as AudioStreamOggVorbis).loop = true
	elif audio_stream is AudioStreamMP3:
		(audio_stream as AudioStreamMP3).loop = true

	player.stream = audio_stream
	player.volume_db = volume_db
	player.bus = "Master"
	player.play()
