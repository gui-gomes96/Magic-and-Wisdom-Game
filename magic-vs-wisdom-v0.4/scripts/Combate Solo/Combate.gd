extends Control

@onready var lbl_pergunta = $Pergunta
@onready var lbl_resultado = $Resultado
@onready var botoes = [
	$VBoxContainer/BotaoA,
	$VBoxContainer/BotaoB,
	$VBoxContainer/BotaoC,
	$VBoxContainer/BotaoD
]
@onready var sprite_player = $Jogador
@onready var sprite_bot = $Bot
@onready var lbl_status_player = $StatusPlayer
@onready var lbl_status_bot = $StatusBot
@onready var lbl_dificuldade = $LblDificuldade

# === CONFIGURAÇÕES ===
const HP_MAX = 20
const MANA_MAX = 10

var player = {"hp": HP_MAX, "mana": MANA_MAX, "curas": 0}
var bot = {"hp": HP_MAX, "mana": MANA_MAX, "curas": 0}

var perguntas = []
var pergunta_atual = 0
var acertos_turno = 0
var perguntas_turno = 0

var turno_do_player = true
var em_acao = false

# =====================================================
func _ready():
	# Mostrar dificuldade
	if has_node("LblDificuldade"):
		lbl_dificuldade.text = "🎯 Dificuldade: " + Global.dificuldade_escolhida

	# Carregar sprites
	if Global.personagem_selecionado.has("sprite"):
		sprite_player.texture = Global.personagem_selecionado["sprite"]
	if Global.personagem_bot_selecionado.has("sprite"):
		sprite_bot.texture = Global.personagem_bot_selecionado["sprite"]

	# ====== CARREGAR PERGUNTAS ======
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

	# Inicia o jogo
	atualizar_status()
	gerar_pergunta()

# =====================================================
func gerar_pergunta():
	if perguntas.size() == 0:
		lbl_pergunta.text = "Sem perguntas disponíveis!"
		return

	var p = perguntas[randi() % perguntas.size()]
	lbl_pergunta.text = p["texto"]
	for i in range(botoes.size()):
		botoes[i].text = p["alternativas"][i]
		botoes[i].disconnect_all("pressed")
		botoes[i].connect("pressed", Callable(self, "_responder").bind(i, p))

# =====================================================
func _responder(indice, pergunta):
	if em_acao:
		return

	perguntas_turno += 1
	if indice == pergunta["correta"]:
		acertos_turno += 1
		lbl_resultado.text = "✅ Correto!"
	else:
		lbl_resultado.text = "❌ Errado!"

	await get_tree().create_timer(0.8).timeout

	if perguntas_turno < 3:
		gerar_pergunta()
	else:
		if turno_do_player:
			acao_player()
		else:
			acao_bot()

# =====================================================
func acao_player():
	em_acao = true

	var escolha = randi() % 2 # 0 ataque, 1 cura (simples, pode ser botão depois)
	if escolha == 0:
		executar_ataque(player, bot)
	else:
		executar_cura(player)

	regenerar_mana(player)
	em_acao = false
	turno_do_player = false
	acao_bot()

# =====================================================
func acao_bot():
	em_acao = true

	var chance_acerto = _chance_dificuldade(Global.dificuldade_escolhida)
	var acertos_bot = 0
	for i in range(3):
		if randf() <= chance_acerto:
			acertos_bot += 1

	var escolha = randi() % 2 # aleatório: atacar ou curar
	if escolha == 0:
		executar_ataque(bot, player, acertos_bot)
	else:
		executar_cura(bot, acertos_bot)

	regenerar_mana(bot)
	em_acao = false
	turno_do_player = true
	gerar_pergunta()

# =====================================================
func executar_ataque(atacante, defensor, acertos=acertos_turno):
	var dano_base = 2
	var custo_mana = 3

	if atacante["mana"] < custo_mana:
		lbl_resultado.text = "⚠️ Sem mana suficiente!"
		return

	atacante["mana"] -= custo_mana

	if acertos == 0:
		lbl_resultado.text = "❌ Ataque falhou!"
		return
	elif acertos == 3:
		dano_base += 1

	defensor["hp"] -= dano_base
	lbl_resultado.text = "⚔️ Ataque causou %d de dano!" % dano_base
	atualizar_status()
	verificar_fim()

	acertos_turno = 0
	perguntas_turno = 0

# =====================================================
func executar_cura(jogador, acertos=acertos_turno):
	if jogador["curas"] >= 3:
		lbl_resultado.text = "🚫 Limite de curas atingido!"
		return

	var cura = 0
	match acertos:
		1:
			cura = 1
		2:
			cura = 2
		3:
			cura = 4

	jogador["hp"] = min(HP_MAX, jogador["hp"] + cura)
	jogador["curas"] += 1
	lbl_resultado.text = "🩹 Curou %d de HP!" % cura
	atualizar_status()

	acertos_turno = 0
	perguntas_turno = 0

# =====================================================
func regenerar_mana(personagem):
	personagem["mana"] = min(MANA_MAX, personagem["mana"] + 3)
	atualizar_status()

# =====================================================
func _chance_dificuldade(nivel):
	match nivel:
		"Fácil":
			return 0.3
		"Normal":
			return 0.5
		"Difícil":
			return 0.75
		"Impossível":
			return 0.9
		_:
			return 0.5

# =====================================================
func atualizar_status():
	lbl_status_player.text = "👤 Player | HP: %d | Mana: %d | Curas: %d" % [player["hp"], player["mana"], player["curas"]]
	lbl_status_bot.text = "🤖 Bot | HP: %d | Mana: %d | Curas: %d" % [bot["hp"], bot["mana"], bot["curas"]]

# =====================================================
func verificar_fim():
	if player["hp"] <= 0 and bot["hp"] <= 0:
		lbl_resultado.text = "🤝 Empate!"
	elif player["hp"] <= 0:
		lbl_resultado.text = "💀 Você perdeu!"
	elif bot["hp"] <= 0:
		lbl_resultado.text = "🏆 Vitória!"

func _on_voltar_pressed() :
	get_tree().change_scene_to_file("res://scenes/Menu Scenes/Menu.tscn")
