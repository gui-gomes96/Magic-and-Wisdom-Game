extends Control



func _on_facil_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Escolha de Materia.tscn")


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Modos de Jogo.tscn")
