import re
import unicodedata

# Categorias expandidas (24 categorias principais)
CATEGORIES = {
    "ALIMENTACAO":          "Alimentação",
    "BEBIDAS":              "Bebidas",
    "LIMPEZA":              "Limpeza",
    "HIGIENE":              "Higiene",
    "SAUDE_FARMACIA":       "Saúde & Farmácia",
    "BELEZA":               "Beleza & Cuidados",
    "ACADEMIA":             "Academia & Suplementos",
    "ELETRONICOS":          "Eletrônicos",
    "INFORMATICA":          "Informática",
    "CELULARES":            "Celulares & Tablets",
    "ELETRODOMESTICOS":     "Eletrodomésticos",
    "ELETROPORTATEIS":      "Eletroportáteis",
    "MOVEIS_DECORACAO":     "Móveis & Decoração",
    "CASA_DOMESTICO":       "Casa & Doméstico",
    "UTENSILIOS_DOM":       "Utensílios Domésticos",
    "VESTUARIO":            "Vestuário & Calçados",
    "BEBE_KIDS":            "Bebês & Kids",
    "BRINQUEDOS":           "Brinquedos & Hobbies",
    "ESPORTE_LAZER":        "Esporte & Lazer",
    "PET":                  "Pet Shop",
    "LIVROS_EDUCACAO":      "Livros & Educação",
    "PAPELARIA":            "Papelaria & Escritório",
    "FERRAMENTAS":          "Ferramentas & Jardim",
    "VIAGEM":               "Viagem",
    "AUTOMOTIVO":           "Automotivo",
    "OUTROS":               "Outros",
}

# Keywords ordenadas da mais específica para a mais genérica para evitar falsos positivos.
# IMPORTANTE: chaves sem espaços desnecessários — a correspondência usa word-boundary via regex.
KEYWORD_MAP: dict[str, str] = {
    # ── Bebidas (antes de Alimentação para evitar "LEITE" ser Alim antes de "LEITE FORMULA" ser Bebê) ──
    "AGUA MINERAL":      CATEGORIES["BEBIDAS"],
    "REFRIGERANTE":      CATEGORIES["BEBIDAS"],
    "CERVEJA":           CATEGORIES["BEBIDAS"],
    "VINHO":             CATEGORIES["BEBIDAS"],
    "SUCO":              CATEGORIES["BEBIDAS"],
    "WHISKY":            CATEGORIES["BEBIDAS"],
    "VODKA":             CATEGORIES["BEBIDAS"],
    "ENERGETICO":        CATEGORIES["BEBIDAS"],
    "CHAMPAGNE":         CATEGORIES["BEBIDAS"],
    "CACHAÇA":           CATEGORIES["BEBIDAS"],
    "HIDROELETRICO":     CATEGORIES["BEBIDAS"],
    "CHA":               CATEGORIES["BEBIDAS"],

    # ── Bebês & Kids (antes de Alimentação para "LEITE FORMULA" não ser Alim) ──
    "LEITE FORMULA":     CATEGORIES["BEBE_KIDS"],
    "FORMULA INFANTIL":  CATEGORIES["BEBE_KIDS"],
    "FRALDA":            CATEGORIES["BEBE_KIDS"],
    "MAMADEIRA":         CATEGORIES["BEBE_KIDS"],
    "CHUPETA":           CATEGORIES["BEBE_KIDS"],
    "CARRINHO DE BEBE":  CATEGORIES["BEBE_KIDS"],
    "PAPINHA":           CATEGORIES["BEBE_KIDS"],

    # ── Alimentação ──────────────────────────────────────────────────────────
    "ARROZ":             CATEGORIES["ALIMENTACAO"],
    "FEIJAO":            CATEGORIES["ALIMENTACAO"],
    "MACARRAO":          CATEGORIES["ALIMENTACAO"],
    "ESPAGUETE":         CATEGORIES["ALIMENTACAO"],
    "CARNE":             CATEGORIES["ALIMENTACAO"],
    "FRANGO":            CATEGORIES["ALIMENTACAO"],
    "PEIXE":             CATEGORIES["ALIMENTACAO"],
    "PICANHA":           CATEGORIES["ALIMENTACAO"],
    "COSTELA":           CATEGORIES["ALIMENTACAO"],
    "LINGUICA":          CATEGORIES["ALIMENTACAO"],
    "OVO":               CATEGORIES["ALIMENTACAO"],
    "LEITE":             CATEGORIES["ALIMENTACAO"],
    "QUEIJO":            CATEGORIES["ALIMENTACAO"],
    "PRESUNTO":          CATEGORIES["ALIMENTACAO"],
    "PAO":               CATEGORIES["ALIMENTACAO"],
    "ACUCAR":            CATEGORIES["ALIMENTACAO"],
    "CAFE":              CATEGORIES["ALIMENTACAO"],
    "OLEO":              CATEGORIES["ALIMENTACAO"],
    "AZEITE":            CATEGORIES["ALIMENTACAO"],
    "MANTEIGA":          CATEGORIES["ALIMENTACAO"],
    "MARGARINA":         CATEGORIES["ALIMENTACAO"],
    "FRUTA":             CATEGORIES["ALIMENTACAO"],
    "BANANA":            CATEGORIES["ALIMENTACAO"],
    "MACA":              CATEGORIES["ALIMENTACAO"],
    "TOMATE":            CATEGORIES["ALIMENTACAO"],
    "BATATA":            CATEGORIES["ALIMENTACAO"],
    "CENOURA":           CATEGORIES["ALIMENTACAO"],
    "ALFACE":            CATEGORIES["ALIMENTACAO"],
    "IOGURTE":           CATEGORIES["ALIMENTACAO"],
    "REQUEIJAO":         CATEGORIES["ALIMENTACAO"],
    "BISCOITO":          CATEGORIES["ALIMENTACAO"],
    "BOLACHA":           CATEGORIES["ALIMENTACAO"],
    "ACHOCOLATADO":      CATEGORIES["ALIMENTACAO"],
    "FARINHA":           CATEGORIES["ALIMENTACAO"],
    "TEMPERO":           CATEGORIES["ALIMENTACAO"],
    "MOLHO":             CATEGORIES["ALIMENTACAO"],
    "ATUM":              CATEGORIES["ALIMENTACAO"],
    "SARDINHA":          CATEGORIES["ALIMENTACAO"],
    "SALSICHA":          CATEGORIES["ALIMENTACAO"],

    # ── Saúde & Farmácia ─────────────────────────────────────────────────────
    "REMEDIO":           CATEGORIES["SAUDE_FARMACIA"],
    "MEDICAMENTO":       CATEGORIES["SAUDE_FARMACIA"],
    "DIPIRONA":          CATEGORIES["SAUDE_FARMACIA"],
    "PARACETAMOL":       CATEGORIES["SAUDE_FARMACIA"],
    "IBUPROFENO":        CATEGORIES["SAUDE_FARMACIA"],
    "VITAMINA":          CATEGORIES["SAUDE_FARMACIA"],
    "DROGARIA":          CATEGORIES["SAUDE_FARMACIA"],
    "FARMACIA":          CATEGORIES["SAUDE_FARMACIA"],
    "CURATIVO":          CATEGORIES["SAUDE_FARMACIA"],
    "BANDAGEM":          CATEGORIES["SAUDE_FARMACIA"],
    "XAROPE":            CATEGORIES["SAUDE_FARMACIA"],
    "POMADA":            CATEGORIES["SAUDE_FARMACIA"],
    "PROBIOTICO":        CATEGORIES["SAUDE_FARMACIA"],
    "TERMOMETRO":        CATEGORIES["SAUDE_FARMACIA"],
    "ANTICONCEPCIONAL":  CATEGORIES["SAUDE_FARMACIA"],

    # ── Higiene ───────────────────────────────────────────────────────────────
    "SHAMPOO":           CATEGORIES["HIGIENE"],
    "SABONETE":          CATEGORIES["HIGIENE"],
    "DESODORANTE":       CATEGORIES["HIGIENE"],
    "CONDICIONADOR":     CATEGORIES["HIGIENE"],
    "CREME DENTAL":      CATEGORIES["HIGIENE"],
    "FITA DENTAL":       CATEGORIES["HIGIENE"],
    "ESCOVA DENTAL":     CATEGORIES["HIGIENE"],
    "PAPEL HIGIENICO":   CATEGORIES["HIGIENE"],
    "ABSORVENTE":        CATEGORIES["HIGIENE"],
    "LENCO UMIDO":       CATEGORIES["HIGIENE"],

    # ── Beleza & Cuidados ─────────────────────────────────────────────────────
    "MAQUIAGEM":         CATEGORIES["BELEZA"],
    "BATOM":             CATEGORIES["BELEZA"],
    "ESMALTE":           CATEGORIES["BELEZA"],
    "CREME HIDRATANTE":  CATEGORIES["BELEZA"],
    "PERFUME":           CATEGORIES["BELEZA"],
    "COLONIA":           CATEGORIES["BELEZA"],
    "PROTETOR SOLAR":    CATEGORIES["BELEZA"],
    "SERUM":             CATEGORIES["BELEZA"],
    "CORTADOR DE UNHA":  CATEGORIES["BELEZA"],
    "BASE FACIAL":       CATEGORIES["BELEZA"],
    "MASCARA CABELO":    CATEGORIES["BELEZA"],

    # ── Academia & Suplementos ────────────────────────────────────────────────
    "WHEY":              CATEGORIES["ACADEMIA"],
    "CREATINA":          CATEGORIES["ACADEMIA"],
    "BCAA":              CATEGORIES["ACADEMIA"],
    "PRE TREINO":        CATEGORIES["ACADEMIA"],
    "ALBUMINA":          CATEGORIES["ACADEMIA"],
    "SUPLEMENTO":        CATEGORIES["ACADEMIA"],
    "PROTEINA":          CATEGORIES["ACADEMIA"],
    "GLUTAMINA":         CATEGORIES["ACADEMIA"],
    "TERMOGENICO":       CATEGORIES["ACADEMIA"],
    "COQUETELEIRA":      CATEGORIES["ACADEMIA"],
    "BARRA PROTEICA":    CATEGORIES["ACADEMIA"],

    # ── Eletrônicos ───────────────────────────────────────────────────────────
    "TELEVISAO":         CATEGORIES["ELETRONICOS"],
    "SMART TV":          CATEGORIES["ELETRONICOS"],
    "FONE":              CATEGORIES["ELETRONICOS"],
    "HEADPHONE":         CATEGORIES["ELETRONICOS"],
    "HEADSET":           CATEGORIES["ELETRONICOS"],
    "CAIXA DE SOM":      CATEGORIES["ELETRONICOS"],
    "AMPLIFICADOR":      CATEGORIES["ELETRONICOS"],
    "SMARTWATCH":        CATEGORIES["ELETRONICOS"],
    "CARREGADOR":        CATEGORIES["ELETRONICOS"],
    "CABO USB":          CATEGORIES["ELETRONICOS"],
    "DRONE":             CATEGORIES["ELETRONICOS"],
    "CAMERA":            CATEGORIES["ELETRONICOS"],

    # ── Informática ───────────────────────────────────────────────────────────
    "NOTEBOOK":          CATEGORIES["INFORMATICA"],
    "TECLADO":           CATEGORIES["INFORMATICA"],
    "MOUSE":             CATEGORIES["INFORMATICA"],
    "MONITOR":           CATEGORIES["INFORMATICA"],
    "IMPRESSORA":        CATEGORIES["INFORMATICA"],
    "ROTEADOR":          CATEGORIES["INFORMATICA"],
    "PENDRIVE":          CATEGORIES["INFORMATICA"],
    "HD EXTERNO":        CATEGORIES["INFORMATICA"],
    "SSD":               CATEGORIES["INFORMATICA"],
    "MEMORIA RAM":       CATEGORIES["INFORMATICA"],
    "WEBCAM":            CATEGORIES["INFORMATICA"],

    # ── Celulares & Tablets ───────────────────────────────────────────────────
    "SMARTPHONE":        CATEGORIES["CELULARES"],
    "IPHONE":            CATEGORIES["CELULARES"],
    "CELULAR":           CATEGORIES["CELULARES"],
    "TABLET":            CATEGORIES["CELULARES"],
    "IPAD":              CATEGORIES["CELULARES"],
    "CAPA CELULAR":      CATEGORIES["CELULARES"],
    "PELICULA":          CATEGORIES["CELULARES"],

    # ── Eletrodomésticos ──────────────────────────────────────────────────────
    "GELADEIRA":         CATEGORIES["ELETRODOMESTICOS"],
    "FOGAO":             CATEGORIES["ELETRODOMESTICOS"],
    "MAQUINA DE LAVAR":  CATEGORIES["ELETRODOMESTICOS"],
    "MICROONDAS":        CATEGORIES["ELETRODOMESTICOS"],
    "LAVA LOUCAS":       CATEGORIES["ELETRODOMESTICOS"],
    "FREEZER":           CATEGORIES["ELETRODOMESTICOS"],
    "AR CONDICIONADO":   CATEGORIES["ELETRODOMESTICOS"],
    "VENTILADOR":        CATEGORIES["ELETRODOMESTICOS"],

    # ── Eletroportáteis ───────────────────────────────────────────────────────
    "AIR FRYER":         CATEGORIES["ELETROPORTATEIS"],
    "LIQUIDIFICADOR":    CATEGORIES["ELETROPORTATEIS"],
    "ASPIRADOR":         CATEGORIES["ELETROPORTATEIS"],
    "BATEDEIRA":         CATEGORIES["ELETROPORTATEIS"],
    "SANDUICHEIRA":      CATEGORIES["ELETROPORTATEIS"],
    "CAFETEIRA":         CATEGORIES["ELETROPORTATEIS"],
    "CHAPINHA":          CATEGORIES["ELETROPORTATEIS"],
    "SECADOR":           CATEGORIES["ELETROPORTATEIS"],
    "FRITADEIRA":        CATEGORIES["ELETROPORTATEIS"],

    # ── Móveis & Decoração ────────────────────────────────────────────────────
    "SOFA":              CATEGORIES["MOVEIS_DECORACAO"],
    "MESA":              CATEGORIES["MOVEIS_DECORACAO"],
    "CADEIRA":           CATEGORIES["MOVEIS_DECORACAO"],
    "ARMARIO":           CATEGORIES["MOVEIS_DECORACAO"],
    "CORTINA":           CATEGORIES["MOVEIS_DECORACAO"],
    "TAPETE":            CATEGORIES["MOVEIS_DECORACAO"],
    "LUMINARIA":         CATEGORIES["MOVEIS_DECORACAO"],
    "CAMA":              CATEGORIES["MOVEIS_DECORACAO"],
    "COLCHAO":           CATEGORIES["MOVEIS_DECORACAO"],
    "TRAVESSEIRO":       CATEGORIES["CASA_DOMESTICO"],
    "ROUPA DE CAMA":     CATEGORIES["CASA_DOMESTICO"],
    "TOALHA":            CATEGORIES["CASA_DOMESTICO"],

    # ── Utensílios Domésticos ─────────────────────────────────────────────────
    "PANELA":            CATEGORIES["UTENSILIOS_DOM"],
    "FRIGIDEIRA":        CATEGORIES["UTENSILIOS_DOM"],
    "POTE":              CATEGORIES["UTENSILIOS_DOM"],
    "COPO":              CATEGORIES["UTENSILIOS_DOM"],
    "PRATO":             CATEGORIES["UTENSILIOS_DOM"],
    "TALHERES":          CATEGORIES["UTENSILIOS_DOM"],
    "VASILHA":           CATEGORIES["UTENSILIOS_DOM"],
    "ESCORREDOR":        CATEGORIES["UTENSILIOS_DOM"],

    # ── Vestuário & Calçados ──────────────────────────────────────────────────
    "CAMISETA":          CATEGORIES["VESTUARIO"],
    "CALCA":             CATEGORIES["VESTUARIO"],
    "TENIS":             CATEGORIES["VESTUARIO"],
    "SANDALIA":          CATEGORIES["VESTUARIO"],
    "SAPATO":            CATEGORIES["VESTUARIO"],
    "MEIA":              CATEGORIES["VESTUARIO"],
    "VESTIDO":           CATEGORIES["VESTUARIO"],
    "CUECA":             CATEGORIES["VESTUARIO"],
    "CALCINHA":          CATEGORIES["VESTUARIO"],
    "SUTIA":             CATEGORIES["VESTUARIO"],
    "JAQUETA":           CATEGORIES["VESTUARIO"],
    "MOLETOM":           CATEGORIES["VESTUARIO"],
    "SHORTS":            CATEGORIES["VESTUARIO"],

    # ── Brinquedos & Hobbies ──────────────────────────────────────────────────
    "BRINQUEDO":         CATEGORIES["BRINQUEDOS"],
    "LEGO":              CATEGORIES["BRINQUEDOS"],
    "BONECA":            CATEGORIES["BRINQUEDOS"],
    "JOGO":              CATEGORIES["BRINQUEDOS"],
    "QUEBRA CABECA":     CATEGORIES["BRINQUEDOS"],

    # ── Esporte & Lazer ───────────────────────────────────────────────────────
    "BOLA":              CATEGORIES["ESPORTE_LAZER"],
    "CHUTEIRA":          CATEGORIES["ESPORTE_LAZER"],
    "RAQUETE":           CATEGORIES["ESPORTE_LAZER"],
    "BIKE":              CATEGORIES["ESPORTE_LAZER"],
    "BICICLETA":         CATEGORIES["ESPORTE_LAZER"],
    "LUVA":              CATEGORIES["ESPORTE_LAZER"],
    "MUSCULACAO":        CATEGORIES["ESPORTE_LAZER"],
    "NATACAO":           CATEGORIES["ESPORTE_LAZER"],

    # ── Pet Shop ──────────────────────────────────────────────────────────────
    "RACAO":             CATEGORIES["PET"],
    "AREIA GATO":        CATEGORIES["PET"],
    "PET SHOP":          CATEGORIES["PET"],
    "COLEIRA":           CATEGORIES["PET"],
    "BRINQUEDO PET":     CATEGORIES["PET"],
    "VERMIFUGO":         CATEGORIES["PET"],
    "ANTIPULGA":         CATEGORIES["PET"],
    "VACINA PET":        CATEGORIES["PET"],

    # ── Livros & Educação ──────────────────────────────────────────────────────
    "LIVRO":             CATEGORIES["LIVROS_EDUCACAO"],
    "EBOOK":             CATEGORIES["LIVROS_EDUCACAO"],
    "APOSTILA":          CATEGORIES["LIVROS_EDUCACAO"],
    "CURSO":             CATEGORIES["LIVROS_EDUCACAO"],
    "MATERIAL ESCOLAR":  CATEGORIES["LIVROS_EDUCACAO"],

    # ── Papelaria & Escritório ────────────────────────────────────────────────
    "CANETA":            CATEGORIES["PAPELARIA"],
    "PAPEL A4":          CATEGORIES["PAPELARIA"],
    "CADERNO":           CATEGORIES["PAPELARIA"],
    "AGENDA":            CATEGORIES["PAPELARIA"],
    "TESOURA":           CATEGORIES["PAPELARIA"],
    "GRAMPEADOR":        CATEGORIES["PAPELARIA"],
    "CLIPS":             CATEGORIES["PAPELARIA"],
    "CARIMBO":           CATEGORIES["PAPELARIA"],

    # ── Ferramentas & Jardim ─────────────────────────────────────────────────
    "MARTELO":           CATEGORIES["FERRAMENTAS"],
    "CHAVE DE FENDA":    CATEGORIES["FERRAMENTAS"],
    "FURADEIRA":         CATEGORIES["FERRAMENTAS"],
    "PARAFUSO":          CATEGORIES["FERRAMENTAS"],
    "PREGOS":            CATEGORIES["FERRAMENTAS"],
    "MANGUEIRA":         CATEGORIES["FERRAMENTAS"],
    "FERTILIZANTE":      CATEGORIES["FERRAMENTAS"],
    "TERRA VEGETAL":     CATEGORIES["FERRAMENTAS"],
    "VASO PLANTA":       CATEGORIES["FERRAMENTAS"],

    # ── Viagem ────────────────────────────────────────────────────────────────
    "PASSAGEM":          CATEGORIES["VIAGEM"],
    "HOSPEDAGEM":        CATEGORIES["VIAGEM"],
    "HOTEL":             CATEGORIES["VIAGEM"],
    "BAGAGEM":           CATEGORIES["VIAGEM"],
    "MALA":              CATEGORIES["VIAGEM"],

    # ── Automotivo ────────────────────────────────────────────────────────────
    "COMBUSTIVEL":       CATEGORIES["AUTOMOTIVO"],
    "GASOLINA":          CATEGORIES["AUTOMOTIVO"],
    "ETANOL":            CATEGORIES["AUTOMOTIVO"],
    "DIESEL":            CATEGORIES["AUTOMOTIVO"],
    "PNEU":              CATEGORIES["AUTOMOTIVO"],
    "OLEO MOTOR":        CATEGORIES["AUTOMOTIVO"],
    "BATERIA CARRO":     CATEGORIES["AUTOMOTIVO"],
    "FILTRO OLEO":       CATEGORIES["AUTOMOTIVO"],
    "PARABRISA":         CATEGORIES["AUTOMOTIVO"],
    "PASTILHA FREIO":    CATEGORIES["AUTOMOTIVO"],

    # ── Limpeza ───────────────────────────────────────────────────────────────
    "DETERGENTE":        CATEGORIES["LIMPEZA"],
    "SABAO":             CATEGORIES["LIMPEZA"],
    "AMACIANTE":         CATEGORIES["LIMPEZA"],
    "DESINFETANTE":      CATEGORIES["LIMPEZA"],
    "AGUA SANITARIA":    CATEGORIES["LIMPEZA"],
    "MULTIUSO":          CATEGORIES["LIMPEZA"],
    "ESPONJA":           CATEGORIES["LIMPEZA"],
    "VASSOURA":          CATEGORIES["LIMPEZA"],
    "ROUPA LAVANDA":     CATEGORIES["LIMPEZA"],
    "SACOS LIXO":        CATEGORIES["LIMPEZA"],
}


def normalize_string(s: str) -> str:
    """Remove acentos e converte para maiúsculo para matching uniforme."""
    if not s:
        return ""
    s = ''.join(
        c for c in unicodedata.normalize('NFD', s)
        if unicodedata.category(c) != 'Mn'
    )
    s = re.sub(r'[^\w\s]', ' ', s)
    return s.upper().strip()


def categorize_item(product_name: str) -> str:
    """
    Identifica a categoria de um produto baseado em seu nome.
    Usa word-boundary implícito via espaços adicionados antes/depois do nome
    normalizado para evitar falsos positivos (ex: MACA em FARMACIA).
    Keywords mais específicas (multi-palavra) têm precedência por estarem primeiro no dict.
    """
    normalized = normalize_string(product_name)
    # Adiciona espaços ao redor para simular word-boundary simples
    padded = f' {normalized} '

    for keyword, category in KEYWORD_MAP.items():
        if f' {keyword} ' in padded:
            return category

    return CATEGORIES["OUTROS"]


def get_all_categories() -> dict[str, str]:
    """Retorna o dicionário completo de categorias disponíveis."""
    return dict(CATEGORIES)
