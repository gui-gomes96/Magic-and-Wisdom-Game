import random
import math
import time
import threading
import sys

# ======= CONFIGURAÇÃO =======
VIDA_INICIAL = 20
MANA_INICIAL = 10
MAX_MANA = 10
TEMPO_POR_PERGUNTA = 60  # segundos por pergunta

HABILIDADES = {
    1: ("Chamas do Destino", "Fogo"),
    2: ("Lanças de Água", "Água"),
    3: ("Floresta do Julgamento", "Floresta"),
}


# ======= CLASSE JOGADOR =======
class Jogador:
    def __init__(self, nome, tipo, is_bot=False, dificuldade="Médio"):
        self.nome = nome
        self.tipo = tipo
        self.hp = VIDA_INICIAL
        self.mana = MANA_INICIAL
        self.is_bot = is_bot
        self.dificuldade = dificuldade

    def recuperar_mana(self, quantidade):
        self.mana = min(MAX_MANA, self.mana + quantidade)

    def levar_dano(self, dano):
        self.hp = max(0, self.hp - dano)


# ======= PERGUNTAS =======
def gerar_pergunta():
    tipo = random.choice(["+", "-", "*", "/"])
    a = random.randint(1, 100)
    b = random.randint(1, 100)

    if tipo == "/":
        b = random.randint(1, 10)
        resultado = random.randint(1, 10)
        a = b * resultado
        texto = f"{a} ÷ {b}"
    elif tipo == "+":
        resultado = a + b
        texto = f"{a} + {b}"
    elif tipo == "-":
        if a < b:
            a, b = b, a
        resultado = a - b
        texto = f"{a} - {b}"
    else:
        a = random.randint(1, 12)
        b = random.randint(1, 12)
        resultado = a * b
        texto = f"{a} × {b}"

    return texto, resultado


def gerar_opcoes(resposta_certa):
    opcoes = [resposta_certa]
    while len(opcoes) < 4:
        erro = resposta_certa + random.randint(-10, 10)
        if erro != resposta_certa and erro >= 0 and erro not in opcoes:
            opcoes.append(erro)
    random.shuffle(opcoes)
    return opcoes


def fazer_pergunta_com_tempo():
    """Pergunta com limite real de 60 segundos e contagem regressiva."""
    texto, resposta_certa = gerar_pergunta()
    opcoes = gerar_opcoes(resposta_certa)
    letras = ["A", "B", "C", "D"]
    resposta_idx = opcoes.index(resposta_certa)

    print(f"\nResolva: {texto}")
    for i, opcao in enumerate(opcoes):
        print(f"  {letras[i]}) {opcao}")

    resposta = [None]
    tempo_acabou = [False]

    def obter_resposta():
        resp = input("Sua resposta (A, B, C ou D): ").strip().upper()
        if not tempo_acabou[0] and resp in letras:
            resposta[0] = resp

    def contagem_regressiva():
        for restante in range(TEMPO_POR_PERGUNTA, 0, -1):
            if resposta[0] is not None:
                return
            sys.stdout.write(f"\r⏳ Tempo restante: {restante:02d}s ")
            sys.stdout.flush()
            time.sleep(1)
        tempo_acabou[0] = True
        sys.stdout.write("\r⏰ Tempo esgotado!\n")

    # Executa as duas threads
    t1 = threading.Thread(target=obter_resposta)
    t2 = threading.Thread(target=contagem_regressiva)

    t2.start()
    t1.start()

    t1.join()
    t2.join()

    if resposta[0] is None or tempo_acabou[0]:
        return False

    return letras.index(resposta[0]) == resposta_idx


def pergunta_bot(dificuldade):
    chance = {
        "Fácil": 0.3,
        "Médio": 0.6,
        "Difícil": 0.8,
        "Impossível": 0.9
    }
    return random.random() < chance[dificuldade]


def defesa_bot(dificuldade, escolha_ataque):
    chance_defesa = {
        "Fácil": 0.3,
        "Médio": 0.6,
        "Difícil": 0.8,
        "Impossível": 0.9
    }
    if random.random() < chance_defesa[dificuldade]:
        return escolha_ataque
    else:
        return random.choice([1, 2, 3])


# ======= FUNÇÕES DE JOGO =======
def escolher_tipo(nome):
    tipos = ["Fogo", "Água", "Floresta"]
    print(f"\n{nome}, escolha o tipo do seu mago:")
    for i, t in enumerate(tipos, start=1):
        print(f"{i}) {t}")
    while True:
        escolha = input("Digite 1, 2 ou 3: ").strip()
        if escolha in ("1", "2", "3"):
            return tipos[int(escolha) - 1]
        print("Escolha inválida.")


def mostrar_status(j1, j2):
    print("\n================ STATUS ================")
    print(f"{j1.nome}: HP={j1.hp} | MANA={j1.mana} | Tipo={j1.tipo}")
    print(f"{j2.nome}: HP={j2.hp} | MANA={j2.mana} | Tipo={j2.tipo}")
    print("========================================\n")


def atacar(atacante, defensor, acertos):
    if acertos == 0:
        print(f"{atacante.nome} errou todas as perguntas e não pode atacar!")
        return

    # Escolher habilidade
    if atacante.is_bot:
        escolha = random.choice([1, 2, 3])
    else:
        print("\nEscolha sua habilidade de ataque:")
        for i, (nome_h, tipo_h) in HABILIDADES.items():
            print(f"{i}) {nome_h} ({tipo_h})")
        while True:
            escolha = input("Digite 1, 2 ou 3: ").strip()
            if escolha in ("1", "2", "3"):
                escolha = int(escolha)
                break

    nome_hab, tipo_hab = HABILIDADES[escolha]

    # Dano e custo
    dano = 5 if tipo_hab == atacante.tipo else 2
    custo_mana = 5 if tipo_hab == atacante.tipo else 3

    if acertos == 3:
        dano = math.floor(dano * 1.5)
        print("💥 ATAQUE CRÍTICO!")

    if atacante.mana < custo_mana:
        print(f"❌ {atacante.nome} não tem mana suficiente!")
        return

    atacante.mana -= custo_mana

    # ===== DEFESA =====
    if defensor.is_bot:
        defesa = defesa_bot(defensor.dificuldade, escolha)
        print(f"\n🤖 {defensor.nome} tenta se defender...")
        time.sleep(1)
    else:
        print(f"\n{defensor.nome}, você quer tentar defender o ataque? (S/N)")
        opcao_defesa = input(">>> ").strip().upper()
        if opcao_defesa == "S":
            print("Tente adivinhar qual ataque o inimigo vai usar!")
            print("1) Chamas do Destino | 2) Lanças de Água | 3) Floresta do Julgamento")
            while True:
                defesa = input("Qual número você acha que ele usou? ").strip()
                if defesa in ("1", "2", "3"):
                    defesa = int(defesa)
                    break
                print("Escolha inválida.")
        else:
            defesa = None

    print(f"\n⚡ {atacante.nome} lança {nome_hab}!")

    defensor.recuperar_mana(3)
    print(f"{defensor.nome} recuperou 3 de mana (agora {defensor.mana}).")

    if defesa == escolha:
        print("🛡️ Defesa perfeita! Nenhum dano sofrido.")
    else:
        defensor.levar_dano(dano)
        print(f"{defensor.nome} recebeu {dano} de dano! (HP: {defensor.hp})")


def turno(jogador, oponente):
    print(f"\n--- Turno de {jogador.nome} ---")
    acertos = 0

    if jogador.is_bot:
        for _ in range(3):
            if pergunta_bot(jogador.dificuldade):
                acertos += 1
        print(f"{jogador.nome} acertou {acertos}/3 perguntas.")
        time.sleep(1)
    else:
        for i in range(3):
            if fazer_pergunta_com_tempo():
                print("✅ Correto!\n")
                acertos += 1
            else:
                print("❌ Errado!\n")
        print(f"{jogador.nome} acertou {acertos}/3 perguntas.")

    atacar(jogador, oponente, acertos)


# ======= NOVA FUNÇÃO: PREPARAÇÃO =======
def preparar_duelo():
    print("\n⚔️  O duelo está prestes a começar!")
    input("Pressione ENTER quando estiver pronto...")

    print("\n🔮 Preparando o campo de batalha...")
    for i in range(3, 0, -1):
        print(f"🕒 Começando em {i}...")
        time.sleep(1)
    print("\n🔥 O duelo começou!\n")
    time.sleep(0.5)


# ======= PROGRAMA PRINCIPAL =======
def main():
    print("=== 🧙‍♂️ Duelo de Magos (Timer + Defesa do Bot + Contagem Regressiva) ===")

    nome = input("Seu nome: ").strip() or "Jogador"
    tipo = escolher_tipo(nome)

    print("\nEscolha a dificuldade do bot:")
    print("1) Fácil  2) Médio  3) Difícil  4) Impossível 💀")
    while True:
        dif = input(">>> ").strip()
        if dif in ("1", "2", "3", "4"):
            dificuldade = ["Fácil", "Médio", "Difícil", "Impossível"][int(dif) - 1]
            break
        print("Escolha inválida.")

    tipo_bot = random.choice(["Fogo", "Água", "Floresta"])
    j1 = Jogador(nome, tipo, is_bot=False)
    bot = Jogador("Bot Mágico", tipo_bot, is_bot=True, dificuldade=dificuldade)

    print(f"\nVocê enfrentará o {bot.nome} ({bot.tipo}) - Dificuldade: {bot.dificuldade}\n")

    # 🧙‍♂️ Etapa de preparação
    preparar_duelo()

    while j1.hp > 0 and bot.hp > 0:
        mostrar_status(j1, bot)
        turno(j1, bot)
        if bot.hp <= 0:
            break
        turno(bot, j1)

    vencedor = j1 if j1.hp > 0 else bot
    print(f"\n🏆 {vencedor.nome} venceu o duelo! 🏆")


if __name__ == "__main__":
    main()
