extends Control

func _ready():
	$Continuar.pressed.connect(_on_continuar_pressed)
	$Voltar.pressed.connect(_on_voltar_pressed)

func _on_continuar_pressed():
	Global.materias_escolhidas.clear()

	# Encontra todos os CheckBoxes (em qualquer nível dentro do VBoxContainer)
	var checkboxes = $VBoxContainer.find_children("", "CheckBox", true, false)

	for checkbox in checkboxes:
		if checkbox.button_pressed:
			Global.materias_escolhidas.append(checkbox.name)

	if Global.materias_escolhidas.is_empty():
		print("⚠️ Selecione pelo menos uma matéria antes de continuar!")
		return

	print("📘 Matérias escolhidas:", Global.materias_escolhidas)
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Escolha de Personagem Player.tscn")


func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Escolha de Dificuldade.tscn")
