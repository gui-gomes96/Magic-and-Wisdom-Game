extends Control

# ======= Referências da cena =======
@onready var lbl_status: Label = $LblStatus
@onready var lbl_materia: Label = $LblMateria
@onready var lbl_pergunta: Label = $Pergunta
@onready var lbl_resultado: Label = $Resultado
@onready var botoes: Array[Button] = [
	$VBoxContainer/BotaoA,
	$VBoxContainer/BotaoB,
	$VBoxContainer/BotaoC,
	$VBoxContainer/BotaoD
]

# ======= Variáveis globais do quiz =======
var perguntas: Array = []
var indice_atual: int = 0
var acertos_totais: int = 0
var acertos_por_materia: Dictionary = {}
var total_perguntas: int = 0

# ======= Inicialização =======
func _ready() -> void:
	# Conecta todos os botões a funções individuais para evitar erro de argumento
	botoes[0].pressed.connect(_on_botao_a_pressed)
	botoes[1].pressed.connect(_on_botao_b_pressed)
	botoes[2].pressed.connect(_on_botao_c_pressed)
	botoes[3].pressed.connect(_on_botao_d_pressed)

	gerar_perguntas()
	total_perguntas = perguntas.size()
	mostrar_pergunta()


# ======= Gera perguntas =======
func gerar_perguntas() -> void:
	perguntas.clear()

	# ==== MATEMÁTICA ====
	if Global.materias_escolhidas.has("Matemática"):
		perguntas += [
			{
				"texto": "Quanto é 9 × 7?",
				"alternativas": ["72", "56", "64", "63"],
				"correta": 3,
				"materia": "Matemática"
			},
			{
				"texto": "Quanto é 12 ÷ 3?",
				"alternativas": ["4", "5", "6", "3"],
				"correta": 0,
				"materia": "Matemática"
			},
			{
				"texto": "Qual é o valor de 15 + 8?",
				"alternativas": ["24", "21", "23", "22"],
				"correta": 2,
				"materia": "Matemática"
			}
		]

	perguntas.shuffle()


# ======= Mostra pergunta atual =======
func mostrar_pergunta() -> void:
	if indice_atual >= perguntas.size():
		mostrar_resultado_final()
		return

	var p: Dictionary = perguntas[indice_atual]
	lbl_materia.text = "Matéria: %s" % p.get("materia", "—")
	lbl_pergunta.text = p.get("texto", "—")

	var letters: Array[String] = ["A", "B", "C", "D"]
	for i in range(botoes.size()):
		var alt_text: String = "—"
		if p.has("alternativas") and i < p["alternativas"].size():
			alt_text = str(p["alternativas"][i])
		botoes[i].text = "%s) %s" % [letters[i], alt_text]
		botoes[i].disabled = false

	atualizar_status()


# ======= Handlers dos botões =======
func _on_botao_a_pressed() -> void:
	_on_botao_pressed(0)

func _on_botao_b_pressed() -> void:
	_on_botao_pressed(1)

func _on_botao_c_pressed() -> void:
	_on_botao_pressed(2)

func _on_botao_d_pressed() -> void:
	_on_botao_pressed(3)


# ======= Função central de resposta =======
func _on_botao_pressed(indice: int) -> void:
	for b: Button in botoes:
		b.disabled = true
	responder(indice)


# ======= Verifica resposta =======
func responder(indice_resposta: int) -> void:
	if indice_atual >= perguntas.size():
		return

	var p: Dictionary = perguntas[indice_atual]
	if indice_resposta == p.get("correta", -1):
		acertos_totais += 1
		var materia: String = p.get("materia", "Desconhecida")
		acertos_por_materia[materia] = acertos_por_materia.get(materia, 0) + 1

	indice_atual += 1
	mostrar_pergunta()


# ======= Atualiza status =======
func atualizar_status() -> void:
	var faltam: int = total_perguntas - indice_atual
	lbl_status.text = "✅ Acertos: %d | 📚 Restantes: %d/%d" % [acertos_totais, faltam, total_perguntas]


# ======= Mostra resultado final =======
func mostrar_resultado_final() -> void:
	lbl_pergunta.text = "🎯 Fim do quiz!"
	var resumo: String = "Total de acertos: %d/%d\n" % [acertos_totais, total_perguntas]
	for materia: String in acertos_por_materia.keys():
		resumo += "- %s: %d acertos\n" % [materia, acertos_por_materia[materia]]
	lbl_status.text = resumo

	for b: Button in botoes:
		b.disabled = true


# ======= Botão de voltar =======
func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Modos de Jogo.tscn")
