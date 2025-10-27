extends Node

@onready var hover_player = $HoverPlayer
@onready var click_player = $ClickPlayer

# Função para tocar som de hover
func play_hover():
	if hover_player and not hover_player.playing:
		hover_player.play()

# Função para tocar som de click
func play_click():
	if click_player:
		click_player.play()
