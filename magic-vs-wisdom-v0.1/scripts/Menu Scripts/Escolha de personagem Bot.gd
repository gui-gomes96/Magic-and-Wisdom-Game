extends Control
var personegem_bot_selecionado   = ""

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Escolha de Personagem Player.tscn")
	

func _on_mago_de_fogo_pressed() -> void:
	selecionar_personagem_bot( "mago_de_fogo", preload("res://assets/mago_de_fogo.png"))


func _on_mago_de_agua_pressed() -> void:
		selecionar_personagem_bot( "mago_da_agua", preload("res://assets/mago_de_agua.png"))


func _on_mago_da_natureza_pressed() -> void:
		selecionar_personagem_bot( "mago_da_Natureza", preload("res://assets/mago_de_fogo.png"))

func selecionar_personagem_bot(nome: String, sprite: Texture2D):
	Global.personegem_bot_selecionado   = {
		"nome": nome,
		"sprite": sprite
	}
	get_tree().change_scene_to_file("res://scenes/Combate.tscn")
