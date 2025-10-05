import random
import getpass
import os
import time
import threading

# --------------------------------------------
# CONFIGURAÇÕES GERAIS
# --------------------------------------------

HABILIDADES = {
    1: ("Chamas do Destino", "fogo"),
    2: ("Lanças de Água", "agua"),
    3: ("Floresta do Julgamento", "terra")
}


# --------------------------------------------
# CLASSE DO JOGADOR
# --------------------------------------------

class Jogador:
    def __init__(self, nome, tipo):
        self.nome = nome
        self.tipo = tipo
        self.hp = 20
        self.mana = 10
        self.pontos = 0


# --------------------------------------------
# FUNÇÃO DE INPUT COM TEMPO
# --------------------------------------------

def input_com_tempo(prompt, tempo_limite):
    """Mostra contagem regressiva e espera resposta do usuário."""
    resposta = [None]

    def ler_input():
        resposta[0] = input(prompt)

    t = threading.Thread(target=ler_input)
    t.start()

    for i in range(tempo_limite, 0, -1):
        print(f"⏳ Tempo restante: {i}s", end="\r")
        time.sleep(1)
        if resposta[0] is not None:
            break

    if resposta[0] is None:
        print("\n⌛ Tempo esgotado!")
        return None
    return resposta[0].strip()


# --------------------------------------------
# FUNÇÕES DE PERGUNTAS
# --------------------------------------------

def gerar_pergunta():
    """Gera uma pergunta de multiplicação, divisão inteira ou subtração."""
    tipo = random.choice(["multiplicacao", "divisao", "subtracao"])
    a = random.randint(1, 100)
    b = random.randint(1, 100)

    if tipo == "divisao":
        b = random.randint(1, 10)
        a = b * random.randint(1, 10)
        resultado = a // b
        texto = f"{a} ÷ {b} = ?"
    elif tipo == "multiplicacao":
        resultado = a * b
        texto = f"{a} × {b} = ?"
    else:
        if b > a:
            a, b = b, a
        resultado = a - b
        texto = f"{a} - {b} = ?"

    alternativas = [resultado]
    while len(alternativas) < 4:
        erro = resultado + random.randint(-10, 10)
        if erro != resultado and erro not in alternativas and erro >= 0:
            alternativas.append(erro)
    random.shuffle(alternativas)

    letras = ['A', 'B', 'C', 'D']
    opcoes = dict(zip(letras, alternativas))
    correta = [letra for letra, valor in opcoes.items() if valor == resultado][0]

    return texto, opcoes, correta


def fazer_perguntas():
    """Faz 3 perguntas com limite de tempo e retorna número de acertos."""
    acertos = 0
    for i in range(3):
        print(f"\n🧮 Pergunta {i+1}:")
        texto, opcoes, correta = gerar_pergunta()
        print(texto)
        for letra, valor in opcoes.items():
            print(f"  {letra}) {valor}")

        resposta = input_com_tempo("Escolha (A, B, C, D): ", 15)
        if resposta is None:
            print(f"❌ Tempo acabou! Resposta certa era {correta}.")
            continue

        resposta = resposta.upper()
        if resposta == correta:
            print("✅ Correto!")
            acertos += 1
        else:
            print(f"❌ Errado! Resposta certa era {correta}.")
    return acertos


# --------------------------------------------
# SISTEMA DE ATAQUE
# --------------------------------------------

def atacar(jogador, inimigo):
    """Turno de ataque do jogador."""
    print(f"\n🎯 {jogador.nome}, é o seu turno!")
    acertos = fazer_perguntas()

    if acertos == 0:
        print("❌ Nenhum acerto! Você não pode atacar.")
        return

    print("\nEscolha sua habilidade:")
    for i, (nome_h, tipo_h) in HABILIDADES.items():
        print(f"{i}) {nome_h} ({tipo_h})")

    while True:
        escolha = getpass.getpass("Digite 1, 2 ou 3 (oculto): ").strip()
        if escolha in ("1", "2", "3"):
            escolha = int(escolha)
            break
        print("Escolha inválida!")

    habilidade, tipo_habilidade = HABILIDADES[escolha]

    # Dano e custo de mana
    if tipo_habilidade == jogador.tipo:
        dano = 4
        custo = 5
    else:
        dano = 2
        custo = 3

    if acertos == 3:
        dano = int(dano * 1.5)
        print("💥 ATAQUE CRÍTICO!")

    if jogador.mana < custo:
        print(f"⚡ Mana insuficiente! ({jogador.mana}/{custo})")
        return

    jogador.mana -= custo
    inimigo["hp"] -= dano

    print(f"\n🔥 {jogador.nome} usou {habilidade} e causou {dano} de dano!")
    print(f"💀 {inimigo['nome']} agora tem {inimigo['hp']} HP.")
    print(f"🔋 Mana restante: {jogador.mana}")


def bot_atacar(jogador, inimigo):
    acertou = random.randint(1, 100) <= inimigo["chance"]
    print(f"\n🤖 {inimigo['nome']} está atacando...")

    if acertou:
        jogador.hp -= inimigo["dano"]
        print(f"💥 {inimigo['nome']} acertou! Dano: {inimigo['dano']}")
    else:
        print(f"💨 {inimigo['nome']} errou o ataque!")

    print(f"❤️ {jogador.nome}: {jogador.hp} HP restantes.\n")


# --------------------------------------------
# SISTEMA DE RANKING
# --------------------------------------------

def salvar_ranking(nome, pontos):
    ranking = []
    if os.path.exists("ranking.txt"):
        with open("ranking.txt", "r", encoding="utf-8") as f:
            for linha in f.readlines():
                try:
                    n, p = linha.strip().split(": ")
                    ranking.append((n, int(p)))
                except:
                    pass
    ranking.append((nome, pontos))
    ranking = sorted(ranking, key=lambda x: x[1], reverse=True)[:5]

    with open("ranking.txt", "w", encoding="utf-8") as f:
        for n, p in ranking:
            f.write(f"{n}: {p}\n")


def mostrar_ranking():
    if os.path.exists("ranking.txt"):
        print("\n🏆 TOP 5 RANKING ARCADE:")
        with open("ranking.txt", "r", encoding="utf-8") as f:
            for linha in f.readlines():
                print(" ", linha.strip())
    else:
        print("\n🏆 Nenhum registro no ranking ainda.")


# --------------------------------------------
# MODO ARCADE PRINCIPAL
# --------------------------------------------

def modo_arcade():
    print("\n=== 🎮 MODO ARCADE: SOBREVIVÊNCIA INFINITA ===")
    mostrar_ranking()

    nome = input("\nDigite seu nome: ")
    print("\nEscolha seu mago:")
    print("1) 🔥 Mago do Fogo\n2) 💧 Mago da Água\n3) 🌱 Mago da Terra")

    while True:
        escolha = input("Escolha (1, 2 ou 3): ").strip()
        if escolha in ("1", "2", "3"):
            tipo = HABILIDADES[int(escolha)][1]
            break
        print("Escolha inválida!")

    jogador = Jogador(nome, tipo)
    nivel = 1
    chance = 5
    hp_inimigo = 5
    dano_inimigo = 2

    tempo_total = 180  # 3 minutos de jogo total
    inicio = time.time()

    while jogador.hp > 0:
        tempo_restante = tempo_total - int(time.time() - inicio)
        if tempo_restante <= 0:
            print("\n⏰ Tempo total esgotado!")
            break
        print(f"\n🕒 Tempo restante de jogo: {tempo_restante}s")

        print(f"\n⚔️  Inimigo #{nivel} apareceu!")
        inimigo = {
            "nome": f"Inimigo Nível {nivel}",
            "hp": hp_inimigo,
            "chance": chance,
            "dano": dano_inimigo
        }

        jogador.mana = 10

        while inimigo["hp"] > 0 and jogador.hp > 0:
            atacar(jogador, inimigo)
            if inimigo["hp"] <= 0:
                print(f"💀 {inimigo['nome']} foi derrotado!")
                jogador.pontos += 10
                break
            bot_atacar(jogador, inimigo)

        if jogador.hp <= 0:
            print("\n💀 Você foi derrotado!")
            break

        nivel += 1
        chance += 5
        if hp_inimigo < 20:
            hp_inimigo += 5
        if nivel % 2 == 0:
            dano_inimigo += 1

        print(f"✅ Vitória! Pontuação atual: {jogador.pontos}")

    print(f"\n🏁 FIM DE JOGO! Pontuação final: {jogador.pontos}")
    salvar_ranking(jogador.nome, jogador.pontos)
    mostrar_ranking()


# --------------------------------------------
# EXECUÇÃO DO JOGO
# --------------------------------------------

if __name__ == "__main__":
    modo_arcade()
