extends Control

# ======================
# VARIÁVEIS PRINCIPAIS
# ======================
@onready var sprite_player = $Jogador
@onready var sprite_bot = $Bot

@onready var lbl_pergunta = $Pergunta
@onready var lbl_status_player = $StatusPlayer
@onready var lbl_status_bot = $StatusBot
@onready var lbl_resultado = $Resultado

@onready var botoes = [
	$PerguntaContainer/BotaoA,
	$PerguntaContainer/BotaoB,
	$PerguntaContainer/BotaoC,
	$PerguntaContainer/BotaoD
]

@onready var btn_pular = $AcoesContainer/Pular_Turno
@onready var btn_fraco = $AcoesContainer/Ataque_Fraco
@onready var btn_medio = $AcoesContainer/Ataque_Medio
@onready var btn_forte = $AcoesContainer/Ataque_Forte
@onready var btn_curar = $AcoesContainer/Cura

@onready var container_perguntas = $PerguntaContainer
@onready var container_acoes = $AcoesContainer

# ======================
# ATRIBUTOS DOS PERSONAGENS
# ======================

var player = {"hp": 20, "mana": 10, "curas": 0}
var bot = {"hp": 20, "mana": 10, "curas": 0}
var max_mana = 10
var max_curas = 3
var jogo_encerrado = false

# ======================
# VARIÁVEIS DE CONTROLE
# ======================

var acao_escolhida = ""
var perguntas = []
var em_acao = false
var acertos_turno = 0
var perguntas_restantes = 0

# ======================
# INÍCIO
# ======================

func _ready() -> void:
	if Global.personagem_selecionado.has("sprite"):
		sprite_player.texture = Global.personagem_selecionado["sprite"]
	if Global.personagem_bot_selecionado.has("sprite"):
		sprite_bot.texture = Global.personagem_bot_selecionado["sprite"]

	
	randomize()
	conectar_acoes()
	carregar_perguntas()
	atualizar_status()
	container_acoes.visible = true
	container_perguntas.visible = false
	lbl_resultado.text = "Escolha sua ação."

# ======================
# CONEXÃO DOS BOTÕES
# ======================

func conectar_acoes() -> void:
	btn_pular.pressed.connect(_pular_turno)
	btn_fraco.pressed.connect(func(): escolher_acao("ataque_fraco"))
	btn_medio.pressed.connect(func(): escolher_acao("ataque_medio"))
	btn_forte.pressed.connect(func(): escolher_acao("ataque_forte"))
	btn_curar.pressed.connect(func(): escolher_acao("cura"))

# ======================
# PERGUNTAS
# ======================

func carregar_perguntas() -> void:

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

func gerar_pergunta() -> void:
	if perguntas.is_empty():
		lbl_pergunta.text = "Sem perguntas disponíveis!"
		return

	var p = perguntas[randi() % perguntas.size()]
	lbl_pergunta.text = p["texto"]

	for i in range(botoes.size()):
		var btn = botoes[i]
		btn.text = p["alternativas"][i]

		for connection in btn.pressed.get_connections():
			if connection.callable.get_object() == self:
				btn.pressed.disconnect(connection.callable)

		btn.pressed.connect(func(): _responder(i, p))

# ======================
# ESCOLHER AÇÃO
# ======================

func escolher_acao(tipo: String) -> void:
	if em_acao or jogo_encerrado:
		return
	em_acao = true
	acao_escolhida = tipo
	acertos_turno = 0
	perguntas_restantes = 3

	if tipo == "pular":
		_pular_turno()
	else:
		container_acoes.visible = false
		container_perguntas.visible = true
		gerar_pergunta()

func _responder(indice: int, pergunta: Dictionary) -> void:
	var correta = pergunta["correta"]

	if indice == correta:
		acertos_turno += 1
		lbl_resultado.text = "✅ Resposta correta!"
	else:
		lbl_resultado.text = "❌ Resposta errada!"

	perguntas_restantes -= 1

	if perguntas_restantes > 0:
		await get_tree().create_timer(1.2).timeout
		gerar_pergunta()
	else:
		await get_tree().create_timer(1.2).timeout
		avaliar_turno()

func avaliar_turno() -> void:
	container_perguntas.visible = false

	if acertos_turno == 0:
		lbl_resultado.text = "❌ Nenhuma resposta certa! A ação falhou!"
		em_acao = false
		await get_tree().create_timer(1.5).timeout
		fim_turno()
	else:
		lbl_resultado.text = "✅ %d acerto(s)! Executando ação..." % acertos_turno
		await get_tree().create_timer(1.2).timeout
		executar_acao_escolhida()

func _pular_turno() -> void:
	lbl_resultado.text = "⏭️ Você pulou o turno!"
	fim_turno()

# ======================
# EXECUÇÃO DAS AÇÕES
# ======================

func executar_acao_escolhida() -> void:
	if jogo_encerrado:
		return

	var bonus = 1 if acertos_turno == 3 else 0

	match acao_escolhida:
		"ataque_fraco":
			executar_ataque(player, bot, 1 + bonus, 1)
		"ataque_medio":
			executar_ataque(player, bot, 2 + bonus, 4)
		"ataque_forte":
			executar_ataque(player, bot, 4 + bonus, 5)
		"cura":
			executar_cura(player)

	await get_tree().create_timer(1.5).timeout
	fim_turno()

func executar_ataque(atacante: Dictionary, alvo: Dictionary, dano: int, custo_mana: int) -> void:
	if atacante["mana"] < custo_mana:
		lbl_resultado.text = "⚠️ Mana insuficiente!"
		return
	atacante["mana"] -= custo_mana
	alvo["hp"] -= dano
	lbl_resultado.text = "💥 Causou %d de dano!" % dano
	atualizar_status()
	verificar_fim_de_jogo()

func executar_cura(alvo: Dictionary) -> void:
	if alvo["curas"] >= max_curas:
		lbl_resultado.text = "⚠️ Limite de curas atingido!"
		if alvo == player:
			btn_curar.disabled = true
		return

	if alvo["mana"] < 3:
		lbl_resultado.text = "⚠️ Mana insuficiente!"
		return

	alvo["curas"] += 1
	alvo["mana"] -= 3
	alvo["hp"] = min(alvo["hp"] + 3, 20)
	lbl_resultado.text = "💊 Cura realizada! (%d/%d)" % [alvo["curas"], max_curas]
	if alvo == player and alvo["curas"] >= max_curas:
		btn_curar.disabled = true
	atualizar_status()

# ======================
# FIM DE TURNO
# ======================

func fim_turno() -> void:
	if jogo_encerrado:
		return
	recuperar_mana(player)
	recuperar_mana(bot)
	atualizar_status()
	em_acao = false
	await get_tree().create_timer(1.5).timeout
	acao_bot()

func recuperar_mana(alvo: Dictionary) -> void:
	alvo["mana"] = min(alvo["mana"] + 3, max_mana)

# ======================
# BOT
# ======================

func acao_bot() -> void:
	if jogo_encerrado:
		return

	var escolha = randi() % 4
	if escolha == 3 and bot["curas"] < max_curas:
		bot_tenta_curar()
	else:
		bot_tenta_acao()

	await get_tree().create_timer(1.5).timeout
	fim_turno_jogador()

func bot_tenta_curar() -> void:
	if bot["mana"] >= 3:
		bot["curas"] += 1
		bot["mana"] -= 3
		bot["hp"] = min(bot["hp"] + 3, 20)
		lbl_resultado.text = "🤖 Bot se curou!"
	else:
		lbl_resultado.text = "🤖 Bot tentou curar, mas não tinha mana!"
	verificar_fim_de_jogo()
	atualizar_status()

func bot_tenta_acao() -> void:
	var chance_acerto = 0.6
	var acertos = 0
	for i in range(3):
		if randf() < chance_acerto:
			acertos += 1

	if acertos == 0:
		lbl_resultado.text = "🤖 Bot errou todas as perguntas!"
		return

	var bonus = 1 if acertos == 3 else 0
	var escolha = randi() % 3
	match escolha:
		0:
			executar_ataque(bot, player, 1 + bonus, 1)
			lbl_resultado.text = "🤖 Bot atacou fraco!"
		1:
			executar_ataque(bot, player, 2 + bonus, 4)
			lbl_resultado.text = "🤖 Bot atacou médio!"
		2:
			executar_ataque(bot, player, 4 + bonus, 5)
			lbl_resultado.text = "🤖 Bot atacou forte!"
	atualizar_status()
	verificar_fim_de_jogo()

func fim_turno_jogador() -> void:
	if not jogo_encerrado:
		container_acoes.visible = true
		lbl_resultado.text = "Escolha sua próxima ação."
	atualizar_status()

# ======================
# FIM DE JOGO
# ======================

func verificar_fim_de_jogo() -> void:
	if player["hp"] <= 0:
		lbl_resultado.text = "💀 Você foi derrotado!"
		finalizar_jogo()
	elif bot["hp"] <= 0:
		lbl_resultado.text = "🏆 Você venceu!"
		finalizar_jogo()

func finalizar_jogo() -> void:
	jogo_encerrado = true
	container_acoes.visible = false
	container_perguntas.visible = false
	lbl_resultado.text += "\n\n🎮 Fim de jogo!"
	for btn in [btn_pular, btn_fraco, btn_medio, btn_forte, btn_curar]:
		btn.disabled = true

# ======================
# HUD
# ======================

func atualizar_status() -> void:
	lbl_status_player.text = "❤️ HP: %d | 💧 Mana: %d | 💊 Curas: %d/%d" % [player["hp"], player["mana"], player["curas"], max_curas]
	lbl_status_bot.text = "🤖 HP: %d | 💧 Mana: %d | 💊 Curas: %d/%d" % [bot["hp"], bot["mana"], bot["curas"], max_curas]
