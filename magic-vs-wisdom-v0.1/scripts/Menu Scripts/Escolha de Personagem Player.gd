extends Control

var personagem_selecionado  = ""

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Escolha de Materia.tscn")
	

func _on_mago_de_fogo_pressed() -> void:
	selecionar_personagem( "mago_de_fogo", preload("res://assets/mago_de_fogo.png"))


func _on_mago_de_agua_pressed() -> void:
		selecionar_personagem( "mago_da_agua", preload("res://assets/mago_de_agua.png"))


func _on_mago_da_natureza_pressed() -> void:
		selecionar_personagem( "mago_da_Natureza", preload("res://assets/mago_da_floresta.png"))

func selecionar_personagem(nome: String, sprite: Texture2D):
	Global.personagem_selecionado  = {
		"nome": nome,
		"sprite": sprite
	}
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Escolha de Personagem Bot.tscn")
