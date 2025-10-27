extends Control
	
func _on_solo_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Escolha de Dificuldade.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Menu.tscn")


func _on_quiz_pressed():
		get_tree().change_scene_to_file("res://scenes/Combate/QUIZ/Escolha de Materia Quiz.tscn")
