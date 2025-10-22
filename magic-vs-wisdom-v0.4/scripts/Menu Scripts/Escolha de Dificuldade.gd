extends Control



func _on_facil_pressed():
	Global.dificuldade_escolhida = "Fácil"
	ir_para_combate()

func _on_normal_pressed():
	Global.dificuldade_escolhida = "Normal"
	ir_para_combate()

func _on_dificil_pressed():
	Global.dificuldade_escolhida = "Difícil"
	ir_para_combate()

func _on_impossivel_pressed():
	Global.dificuldade_escolhida = "Impossível"
	ir_para_combate()

func ir_para_combate():
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Escolha de Materia.tscn")  # altere para o caminho real


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Escolha de Materia.tscn")
	
