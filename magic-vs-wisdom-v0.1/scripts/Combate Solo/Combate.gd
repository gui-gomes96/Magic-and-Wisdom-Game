extends Control



@onready var sprite_personagem_player = $Jogador
@onready var sprite_personagem_bot = $Bot


func _ready():
	if Global.personagem_selecionado.has("sprite"):
		sprite_personagem_player.texture = Global.personagem_selecionado["sprite"]

	if Global.personegem_bot_selecionado.has("sprite"):
		sprite_personagem_bot.texture = Global.personegem_bot_selecionado["sprite"]
