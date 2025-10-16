extends Control




func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Escolha de Dificuldade.tscn")


func _on_português_toggled(toggled_on: bool) -> void:
	true
	

func _on_artes_toggled(toggled_on: bool) -> void:
	true

func _on_continuar_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/Menu Scenes/Escolha de Personagem Player.tscn")
