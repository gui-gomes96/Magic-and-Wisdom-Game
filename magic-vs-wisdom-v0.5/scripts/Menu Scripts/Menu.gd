extends Control

func _on_btn_jogar_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Modos de Jogo.tscn")


func _on_opções_pressed():
		get_tree().change_scene_to_file("res://scenes/Opition Scenes/Opções.tscn")


func _on_creditos_pressed():
		get_tree().change_scene_to_file("res://scenes/Opition Scenes/Creditos.tscn")

func _on_como_jogar_pressed():
		get_tree().change_scene_to_file("res://scenes/Opition Scenes/Como Jogar.tscn")

	
