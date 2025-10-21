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

# Labels de status
@onready var lbl_status_player = $StatusPlayer
@onready var lbl_status_bot = $StatusBot

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
	# Aplica sprites
	if Global.personagem_selecionado.has("sprite"):
		sprite_player.texture = Global.personagem_selecionado["sprite"]
	if Global.personagem_bot_selecionado.has("sprite"):
		sprite_bot.texture = Global.personagem_bot_selecionado["sprite"]

	# ===== GERA AS PERGUNTAS =====
	if "Matemática" in Global.materias_escolhidas:
		perguntas += [
			{"texto": "Quanto é 9 × 7?", "alternativas": ["56", "63", "64", "72"], "correta": 1},
			{"texto": "Qual é a raiz quadrada de 81?", "alternativas": ["9", "8", "7", "6"], "correta": 0},
			{"texto": "5 + 8 × 2 = ?", "alternativas": ["26", "21", "16", "18"], "correta": 1},
			{"texto": "Quanto é 12 ÷ 3?", "alternativas": ["6", "5", "4", "3"], "correta": 2},
			{"texto": "O dobro de 15 é?", "alternativas": ["20", "25", "30", "35"], "correta": 2},
			{"texto": "7 + 8 + 9 =", "alternativas": ["23", "24", "25", "26"], "correta": 1},
			{"texto": "Quanto é 10²?", "alternativas": ["10", "100", "20", "1000"], "correta": 1},
			{"texto": "Qual é o resultado de 6 × 6?", "alternativas": ["30", "32", "35", "36"], "correta": 3},
			{"texto": "A metade de 50 é?", "alternativas": ["10", "20", "25", "30"], "correta": 2},
			{"texto": "Quanto é 3³?", "alternativas": ["6", "9", "27", "18"], "correta": 2}
		]

	if "História" in Global.materias_escolhidas:
		perguntas += [
			{"texto": "Quem foi o primeiro presidente do Brasil?", "alternativas": ["Deodoro da Fonseca", "Dom Pedro II", "Lula", "Getúlio Vargas"], "correta": 0},
			{"texto": "Qual país colonizou o Brasil?", "alternativas": ["Espanha", "Portugal", "França", "Inglaterra"], "correta": 1},
			{"texto": "Em que ano o Brasil proclamou a independência?", "alternativas": ["1822", "1889", "1500", "1750"], "correta": 0},
			{"texto": "Quem proclamou a independência?", "alternativas": ["Dom Pedro I", "Tiradentes", "Deodoro da Fonseca", "Dom João VI"], "correta": 0},
			{"texto": "Qual evento marcou o fim da monarquia?", "alternativas": ["Proclamação da República", "Descobrimento do Brasil", "Inconfidência Mineira", "Abolição da Escravidão"], "correta": 0},
			{"texto": "Quem foi Tiradentes?", "alternativas": ["Um bandeirante", "Um líder da Inconfidência Mineira", "Um rei", "Um militar"], "correta": 1},
			{"texto": "A escravidão no Brasil acabou em?", "alternativas": ["1822", "1850", "1888", "1900"], "correta": 2},
			{"texto": "Quem assinou a Lei Áurea?", "alternativas": ["Princesa Isabel", "Dom Pedro I", "Getúlio Vargas", "Deodoro da Fonseca"], "correta": 0},
			{"texto": "Em que ano o Brasil foi descoberto?", "alternativas": ["1498", "1500", "1520", "1550"], "correta": 1},
			{"texto": "Qual era o nome da colônia portuguesa antes do Brasil?", "alternativas": ["Terra de Vera Cruz", "Pindorama", "Ilha de Santa Cruz", "Brasil"], "correta": 0}
		]

	# Outras matérias (Geografia, Ciências, Artes etc.) seguem o mesmo modelo
	perguntas.shuffle()
	exibir_pergunta()
	atualizar_status()

# =====================================================
func exibir_pergunta():
	if player["hp"] <= 0 or bot["hp"] <= 0:
		lbl_pergunta.text = "🏁 Fim de Jogo!"
		lbl_resultado.text = player["hp"] > 0 ? "🎉 Você venceu!" : "💀 Você perdeu!"
		for b in botoes:
			b.visible = false
		return

	if pergunta_atual >= perguntas.size():
		pergunta_atual = 0
		perguntas.shuffle()

	var p = perguntas[pergunta_atual]
	lbl_pergunta.text = p["texto"]

	var letras = ["A", "B", "C", "D"]
	for i in range(botoes.size()):
		botoes[i].visible = true
		botoes[i].text = "%s) %s" % [letras[i], p["alternativas"][i]]
		if botoes[i].is_connected("pressed", Callable(self, "_on_resposta")):
			botoes[i].disconnect("pressed", Callable(self, "_on_resposta"))
		botoes[i].pressed.connect(_on_resposta.bind(i))

# =====================================================
func _on_resposta(indice):
	if em_acao:
		return

	var p = perguntas[pergunta_atual]
	var acertou = indice == p["correta"]

	if acertou:
		lbl_resultado.text = "✅ Correto!"
		acertos_turno += 1
	else:
		lbl_resultado.text = "❌ Errado!"

	pergunta_atual += 1
	perguntas_turno += 1
	await get_tree().create_timer(0.7).timeout

	if perguntas_turno >= 3:
		perguntas_turno = 0
		executar_acao()
	else:
		exibir_pergunta()

# =====================================================
func executar_acao():
	em_acao = true
	if turno_do_player:
		acao_jogador()
	else:
		acao_bot()

	await get_tree().create_timer(1.5).timeout
	acertos_turno = 0
	player["mana"] = clamp(player["mana"] + 3, 0, MANA_MAX)
	bot["mana"] = clamp(bot["mana"] + 3, 0, MANA_MAX)
	turno_do_player = !turno_do_player
	em_acao = false
	exibir_pergunta()
	atualizar_status()

# =====================================================
func acao_jogador():
	var escolha = randi() % 2
	if escolha == 0:
		executar_ataque(player, bot)
	else:
		executar_cura(player)

func acao_bot():
	var escolha = randi() % 2
	if escolha == 0:
		executar_ataque(bot, player)
	else:
		executar_cura(bot)

# =====================================================
func executar_ataque(atacante, defensor):
	var custo_mana = 3
	if atacante["mana"] < custo_mana:
		lbl_resultado.text = atacante == player ? "⚠️ Mana insuficiente!" : "🤖 Bot sem mana!"
		return

	atacante["mana"] -= custo_mana

	if acertos_turno == 0:
		lbl_resultado.text = atacante == player ? "💨 Ataque falhou!" : "🤖 Bot errou tudo!"
		return

	var dano = 2 + (acertos_turno == 3 ? 1 : 0)
	defensor["hp"] = clamp(defensor["hp"] - dano, 0, HP_MAX)
	lbl_resultado.text = atacante == player ? "⚔️ Você causou %d de dano!" % dano : "🤖 Bot causou %d de dano!" % dano
	atualizar_status()

# =====================================================
func executar_cura(alvo):
	if alvo["curas"] >= 3:
		lbl_resultado.text = alvo == player ? "❌ Você já usou todas as curas!" : "🤖 Bot não pode mais curar!"
		return

	var cura = 0
	if acertos_turno == 1:
		cura = 1
	elif acertos_turno == 2:
		cura = 2
	elif acertos_turno == 3:
		cura = 4

	alvo["hp"] = clamp(alvo["hp"] + cura, 0, HP_MAX)
	alvo["curas"] += 1
	lbl_resultado.text = alvo == player ? "💚 Você se curou em %d HP!" % cura : "🤖 Bot se curou!"
	atualizar_status()

# =====================================================
func atualizar_status():
	lbl_status_player.text = "❤️ HP: %d / %d | 🔷 Mana: %d / %d" % [player["hp"], HP_MAX, player["mana"], MANA_MAX]
	lbl_status_bot.text = "🤖 HP: %d / %d | 🔹 Mana: %d / %d" % [bot["hp"], HP_MAX, bot["mana"], MANA_MAX]
