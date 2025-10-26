extends Control

@onready var lbl_pergunta = $Pergunta
@onready var lbl_resultado = $Resultado
@onready var botoes = [
	$VBoxContainer/BotaoA,
	$VBoxContainer/BotaoB,
	$VBoxContainer/BotaoC,
	$VBoxContainer/BotaoD
]

var perguntas = []
var pergunta_atual = 0

func _ready():

	print("📘 Matérias carregadas:", Global.materias_escolhidas)
	gerar_perguntas()
	exibir_pergunta()

func gerar_perguntas():
	perguntas.clear()

	# ==== MATEMÁTICA ====
	if "Matemática" in Global.materias_escolhidas:
		perguntas += [
			{"texto": "Quanto é 9 × 7?", "alternativas": ["56", "63", "64", "72"], "correta": 1},
			{"texto": "Quanto é 12 ÷ 3?", "alternativas": ["6", "3", "4", "5"], "correta": 2},
			{"texto": "Qual é o valor de 15 + 8?", "alternativas": ["21", "22", "23", "24"], "correta": 2},
			{"texto": "Qual é o dobro de 9?", "alternativas": ["16", "17", "18", "20"], "correta": 2}
		]

	# ==== HISTÓRIA ====
	if "História" in Global.materias_escolhidas:
		perguntas += [
			{"texto": "Quem foi o primeiro presidente do Brasil?", "alternativas": ["Deodoro da Fonseca", "Dom Pedro II", "Lula", "Getúlio Vargas"], "correta": 0},
			{"texto": "Em que ano o Brasil foi descoberto?", "alternativas": ["1492", "1500", "1822", "1889"], "correta": 1},
			{"texto": "Quem proclamou a independência do Brasil?", "alternativas": ["Tiradentes", "Dom Pedro I", "Dom João VI", "Getúlio Vargas"], "correta": 1},
			{"texto": "A Revolução Francesa começou em qual país?", "alternativas": ["Inglaterra", "França", "Espanha", "Itália"], "correta": 1}
		]

	# ==== CIÊNCIAS ====
	if "Ciências" in Global.materias_escolhidas:
		perguntas += [
			{"texto": "Qual planeta é conhecido como o planeta vermelho?", "alternativas": ["Marte", "Vênus", "Júpiter", "Saturno"], "correta": 0},
			{"texto": "A água ferve a quantos graus Celsius?", "alternativas": ["90", "100", "110", "120"], "correta": 1},
			{"texto": "O oxigênio é essencial para qual função do corpo?", "alternativas": ["Respiração", "Digestão", "Circulação", "Audição"], "correta": 0},
			{"texto": "Qual órgão bombeia sangue?", "alternativas": ["Pulmão", "Estômago", "Coração", "Cérebro"], "correta": 2}
		]

	# ==== GEOGRAFIA ====
	if "Geografia" in Global.materias_escolhidas:
		perguntas += [
			{"texto": "Qual é o maior país do mundo?", "alternativas": ["China", "EUA", "Rússia", "Canadá"], "correta": 2},
			{"texto": "Qual é o rio mais extenso do Brasil?", "alternativas": ["São Francisco", "Paraná", "Amazonas", "Tietê"], "correta": 2},
			{"texto": "Qual é o continente onde está o Egito?", "alternativas": ["África", "Europa", "Ásia", "Oceania"], "correta": 0},
			{"texto": "Qual é o ponto mais alto do mundo?", "alternativas": ["Monte Everest", "Pico da Neblina", "Kilimanjaro", "Andes"], "correta": 0}
		]

	# ==== ARTES ====
	if "Artes" in Global.materias_escolhidas:
		perguntas += [
			{"texto": "Quem pintou a Mona Lisa?", "alternativas": ["Van Gogh", "Leonardo da Vinci", "Picasso", "Michelangelo"], "correta": 1},
			{"texto": "Qual é o nome do estilo de arte que usa cubos?", "alternativas": ["Cubismo", "Realismo", "Impressionismo", "Futurismo"], "correta": 0},
			{"texto": "Quem pintou 'Noite Estrelada'?", "alternativas": ["Monet", "Van Gogh", "Da Vinci", "Rembrandt"], "correta": 1},
			{"texto": "O que é escultura?", "alternativas": ["Pintura com tinta", "Obra feita em 3D", "Fotografia", "Desenho animado"], "correta": 1}
		]

	# ==== EDUCAÇÃO FÍSICA ====
	if "Educação Física" in Global.materias_escolhidas:
		perguntas += [
			{"texto": "Quantos jogadores tem um time de futebol?", "alternativas": ["9", "10", "11", "12"], "correta": 2},
			{"texto": "Qual esporte usa raquete e bola amarela?", "alternativas": ["Tênis", "Vôlei", "Basquete", "Futebol"], "correta": 0},
			{"texto": "Em qual esporte se usa traves?", "alternativas": ["Basquete", "Futebol", "Tênis", "Vôlei"], "correta": 1},
			{"texto": "Quantos pontos vale uma cesta de 3 no basquete?", "alternativas": ["2", "3", "4", "5"], "correta": 1}
		]

	# ==== PORTUGUÊS ====
	if "Português" in Global.materias_escolhidas:
		perguntas += [
			{"texto": "Qual palavra está escrita corretamente?", "alternativas": ["Excessão", "Execessão", "Exceção", "Eceção"], "correta": 2},
			{"texto": "Qual é o plural de 'pão'?", "alternativas": ["pãos", "pães", "pãeses", "paões"], "correta": 1},
			{"texto": "Qual é o antônimo de 'feliz'?", "alternativas": ["Alegre", "Triste", "Contente", "Divertido"], "correta": 1},
			{"texto": "Qual é o verbo na frase 'Ela correu ontem'?", "alternativas": ["Ela", "correu", "ontem", "nenhuma"], "correta": 1}
		]

	perguntas.shuffle()

func exibir_pergunta():
	if pergunta_atual >= perguntas.size():
		lbl_pergunta.text = "🏁 Fim do quiz!"
		lbl_resultado.text = ""
		for b in botoes:
			b.visible = false
		return

	var p = perguntas[pergunta_atual]
	lbl_pergunta.text = p["texto"]

	var letras = ["A", "B", "C", "D"]
	for i in range(botoes.size()):
		if i < p["alternativas"].size():
			botoes[i].text = "%s) %s" % [letras[i], p["alternativas"][i]]
			botoes[i].visible = true
			if botoes[i].is_connected("pressed", Callable(self, "_on_resposta")):
				botoes[i].disconnect("pressed", Callable(self, "_on_resposta"))
			botoes[i].pressed.connect(_on_resposta.bind(i))
		else:
			botoes[i].visible = false

func _on_resposta(indice):
	var p = perguntas[pergunta_atual]
	if indice == p["correta"]:
		lbl_resultado.text = "✅ Correto!"
	else:
		lbl_resultado.text = "❌ Errado!"

	pergunta_atual += 1
	await get_tree().create_timer(1.2).timeout
	exibir_pergunta()


func _on_voltar_pressed():
		get_tree().change_scene_to_file("res://scenes/Menu Scenes/Menu.tscn")
