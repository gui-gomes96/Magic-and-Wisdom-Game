import random
import math
import time
import threading
import sys

# ======= CONFIGURAÇÕES GERAIS =======
VIDA_INICIAL = 20
MANA_INICIAL = 10
MAX_MANA = 10
TEMPO_POR_PERGUNTA = 60  # tempo real (segundos)

# Habilidades: nome e tipo elemental
HABILIDADES = {
    1: ("Chamas do Destino", "Fogo"),
    2: ("Lanças de Água", "Água"),
    3: ("Floresta do Julgamento", "Floresta"),
}


# ======= CLASSE DO JOGADOR =======
class Jogador:
    def __init__(self, nome, tipo):
        self.nome = nome
        self.tipo = tipo
        self.hp = VIDA_INICIAL
        self.mana = MANA_INICIAL

    def recuperar_mana(self, qtd):
        """Recupera mana sem passar do máximo."""
        self.mana = min(MAX_MANA, self.mana + qtd)

    def levar_dano(self, dano):
        """Reduz HP do jogador."""
        self.hp = max(0, self.hp - dano)


# ======= PERGUNTAS DE MÚLTIPLA ESCOLHA =======
def gerar_pergunta():
    """Gera uma pergunta (+, -, ×, ÷) com resultado inteiro."""
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
    else:  # multiplicação
        a = random.randint(1, 12)
        b = random.randint(1, 12)
        resultado = a * b
        texto = f"{a} × {b}"

    return texto, resultado


def gerar_opcoes(resposta_certa):
    """Gera 3 respostas erradas e embaralha tudo."""
    opcoes = [resposta_certa]
    while len(opcoes) < 4:
        erro = resposta_certa + random.randint(-10, 10)
        if erro != resposta_certa and erro >= 0 and erro not in opcoes:
            opcoes.append(erro)
    random.shuffle(opcoes)
    return opcoes


# ======= PERGUNTA COM CONTAGEM REGRESSIVA =======
def fazer_pergunta():
    """Mostra a pergunta e retorna True se o jogador acertar (com tempo e contagem regressiva)."""
    texto, resposta_certa = gerar_pergunta()
    opcoes = gerar_opcoes(resposta_certa)
    letras = ["A", "B", "C", "D"]
    idx_certo = opcoes.index(resposta_certa)

    print(f"\nResolva: {texto}")
    for i, opcao in enumerate(opcoes):
        print(f"  {letras[i]}) {opcao}")

    resposta = {"valor": None}

    def esperar_resposta():
        resp = input("Sua resposta (A, B, C ou D): ").strip().upper()
        resposta["valor"] = resp

    # Thread para permitir contagem regressiva e input ao mesmo tempo
    t = threading.Thread(target=esperar_resposta)
    t.start()

    for restante in range(TEMPO_POR_PERGUNTA, 0, -1):
        if resposta["valor"] is not None:
            break
        sys.stdout.write(f"\r⏳ Tempo restante: {restante:02d}s ")
        sys.stdout.flush()
        time.sleep(1)

    print()  # pula linha ao final do timer
    if resposta["valor"] is None:
        print("⏰ Tempo esgotado!")
        return False

    resp = resposta["valor"]
    if resp in letras:
        return letras.index(resp) == idx_certo
    else:
        print("Escolha inválida!")
        return False


# ======= FUNÇÕES DE JOGO =======
def escolher_tipo(nome):
    """Permite que o jogador escolha o tipo do mago."""
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
    """Exibe o status atual dos jogadores."""
    print("\n================ STATUS ================")
    print(f"{j1.nome}: HP={j1.hp} | MANA={j1.mana} | Tipo={j1.tipo}")
    print(f"{j2.nome}: HP={j2.hp} | MANA={j2.mana} | Tipo={j2.tipo}")
    print("========================================\n")


def atacar(atacante, defensor, acertos):
    """Realiza o ataque após as perguntas."""
    if acertos == 0:
        print(f"{atacante.nome} errou tudo e não pode atacar!")
        return

    print(f"\n{atacante.nome}, escolha sua habilidade de ataque:")
    for i, (nome_h, tipo_h) in HABILIDADES.items():
        print(f"{i}) {nome_h} ({tipo_h})")

    while True:
        escolha = input("Digite 1, 2 ou 3: ").strip()
        if escolha in ("1", "2", "3"):
            escolha = int(escolha)
            break

    nome_hab, tipo_hab = HABILIDADES[escolha]

    # Dano e custo base
    if tipo_hab == atacante.tipo:
        dano = 5
        custo_mana = 5
    else:
        dano = 2
        custo_mana = 3

    # Crítico se acertar todas
    if acertos == 3:
        dano = math.floor(dano * 1.5)
        print("💥 ATAQUE CRÍTICO!")

    if atacante.mana < custo_mana:
        print(f"❌ {atacante.nome} não tem mana suficiente!")
        return

    atacante.mana -= custo_mana

    # ===== DEFESA OPCIONAL =====
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

    # Mostrar ataque só depois da defesa
    print(f"\n⚡ {atacante.nome} lança {nome_hab}!")

    # Recuperar mana ao defender
    defensor.recuperar_mana(3)
    print(f"{defensor.nome} recuperou 3 de mana (agora {defensor.mana}).")

    # Verificar se defendeu corretamente
    if defesa == escolha:
        print("🛡️ Defesa perfeita! Nenhum dano sofrido.")
    else:
        defensor.levar_dano(dano)
        print(f"{defensor.nome} recebeu {dano} de dano! (HP: {defensor.hp})")


def turno(jogador, oponente):
    """Executa o turno de perguntas e ataque."""
    print(f"\n--- Turno de {jogador.nome} ---")

    acertos = 0
    for i in range(3):
        print(f"\nPergunta {i+1}/3:")
        if fazer_pergunta():
            print("✅ Correto!\n")
            acertos += 1
        else:
            print("❌ Errado!\n")

    print(f"{jogador.nome} acertou {acertos}/3 perguntas.")
    atacar(jogador, oponente, acertos)


# ======= PROGRAMA PRINCIPAL =======
def main():
    print("=== 🧙‍♂️ Duelo de Magos - 2 Jogadores (Múltipla Escolha com Tempo) ===")

    nome1 = input("Nome do Jogador 1: ").strip() or "Jogador 1"
    tipo1 = escolher_tipo(nome1)
    nome2 = input("\nNome do Jogador 2: ").strip() or "Jogador 2"
    tipo2 = escolher_tipo(nome2)

    j1 = Jogador(nome1, tipo1)
    j2 = Jogador(nome2, tipo2)

    # ===== NOVO: confirmação antes do duelo =====
    print("\n🔮 Preparação para o duelo!")
    input(f"{j1.nome}, pressione ENTER quando estiver pronto para o duelo...")
    input(f"{j2.nome}, pressione ENTER quando estiver pronto para o duelo...")

    print("\n✨ Ambos os magos estão prontos! Que o duelo comece! ✨\n")
    time.sleep(1)

    # Loop principal do jogo
    while j1.hp > 0 and j2.hp > 0:
        mostrar_status(j1, j2)
        turno(j1, j2)
        if j2.hp <= 0:
            break
        turno(j2, j1)

    vencedor = j1 if j1.hp > 0 else j2
    print(f"\n🏆 {vencedor.nome} venceu o duelo! 🏆")


if __name__ == "__main__":
    main()
