extends Node

@onready var music = $Container/Music
@onready var hover_player = $HoverPlayer
@onready var click_player = $ClickPlayer

var cenas_sem_musica = [
"res://scenes/Combate/QUIZ/Questionario Quiz.tscn",
"res://scenes/Combate/Combate.tscn"
]

var iniciou_musica := false
var tempo_musica := 0.0

func _ready():
	if music == null:
		music = get_tree().get_root().find_node("Music", true, false)
		if music == null:
			push_error("Music node não encontrado!")
			return

	# Adiciona ao root se não estiver
	if get_parent() != get_tree().get_root():
		get_tree().get_root().add_child(self)
		self.owner = null

	# Toca a música apenas uma vez
	if not iniciou_musica:
		music.play()
		iniciou_musica = true

func _process(_delta):
	if music == null:
		return

	var cena_atual = get_tree().current_scene
	if cena_atual == null:
		return

	var caminho = cena_atual.scene_file_path

	if caminho in cenas_sem_musica:
		if music.playing:
			tempo_musica = music.get_playback_position()
			music.stop()
	else:
		if not music.playing:
			music.play(tempo_musica)
