import re
import unicodedata

# Categorias e subcategorias
CATEGORIES = {
    "ALIMENTOS_FRIOS":      "Alimentos/Frios",
    "ALIMENTOS_CARNES":     "Alimentos/Carnes",
    "ALIMENTOS_HORTIFRUTI": "Alimentos/Hortifruti",
    "ALIMENTOS_PANIF":      "Alimentos/Panificação",
    "ALIMENTOS_GRAOS":      "Alimentos/Grãos",
    "ALIMENTOS_LATICINIOS": "Alimentos/Laticínios",
    "ALIMENTOS_MERCEARIA":  "Alimentos/Mercearia",
    "ALIMENTOS":            "Alimentos",
    "LIMPEZA":              "Limpeza",
    "HIGIENE":              "Higiene",
    "BEBIDAS":              "Bebidas",
    "LAZER":                "Lazer",
    "OUTROS":               "Outros",
}

# Palavras-chave em maiúsculo e sem acentos → categoria
KEYWORD_MAP = {
    # Alimentos/Frios
    "QUEIJO":       CATEGORIES["ALIMENTOS_FRIOS"],
    "PRESUNTO":     CATEGORIES["ALIMENTOS_FRIOS"],
    "MORTADELA":    CATEGORIES["ALIMENTOS_FRIOS"],
    "IOGURTE":      CATEGORIES["ALIMENTOS_FRIOS"],
    "MANTEIGA":     CATEGORIES["ALIMENTOS_FRIOS"],
    "REQUEIJAO":    CATEGORIES["ALIMENTOS_FRIOS"],
    "MARGARINA":    CATEGORIES["ALIMENTOS_FRIOS"],
    "FATIADO":      CATEGORIES["ALIMENTOS_FRIOS"],

    # Alimentos/Carnes
    "CARNE":        CATEGORIES["ALIMENTOS_CARNES"],
    "FRANGO":       CATEGORIES["ALIMENTOS_CARNES"],
    "PEIXE":        CATEGORIES["ALIMENTOS_CARNES"],
    "LINGUICA":     CATEGORIES["ALIMENTOS_CARNES"],
    "HAMBURGUER":   CATEGORIES["ALIMENTOS_CARNES"],
    "BACON":        CATEGORIES["ALIMENTOS_CARNES"],
    "COXA":         CATEGORIES["ALIMENTOS_CARNES"],
    "FILE":         CATEGORIES["ALIMENTOS_CARNES"],
    "ALCATRA":      CATEGORIES["ALIMENTOS_CARNES"],
    "PICANHA":      CATEGORIES["ALIMENTOS_CARNES"],
    "PATINHO":      CATEGORIES["ALIMENTOS_CARNES"],
    "PEITO":        CATEGORIES["ALIMENTOS_CARNES"],

    # Alimentos/Hortifruti
    "FRUTA":        CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "LEGUME":       CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "VERDURA":      CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "TOMATE":       CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "BATATA":       CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "CENOURA":      CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "CEBOLA":       CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "ALHO":         CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "BANANA":       CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "MACA":         CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "LARANJA":      CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "ALFACE":       CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "BROCOLIS":     CATEGORIES["ALIMENTOS_HORTIFRUTI"],
    "ABOBRINHA":    CATEGORIES["ALIMENTOS_HORTIFRUTI"],

    # Alimentos/Panificação
    "PAO":          CATEGORIES["ALIMENTOS_PANIF"],
    "BOLO":         CATEGORIES["ALIMENTOS_PANIF"],
    "BISCOITO":     CATEGORIES["ALIMENTOS_PANIF"],
    "BOLACHA":      CATEGORIES["ALIMENTOS_PANIF"],
    "FARINHA":      CATEGORIES["ALIMENTOS_PANIF"],
    "MAIZENA":      CATEGORIES["ALIMENTOS_PANIF"],
    "TORRADA":      CATEGORIES["ALIMENTOS_PANIF"],
    "WAFER":        CATEGORIES["ALIMENTOS_PANIF"],
    "CHOCOLATE":    CATEGORIES["ALIMENTOS_PANIF"],

    # Alimentos/Grãos
    "ARROZ":        CATEGORIES["ALIMENTOS_GRAOS"],
    "FEIJAO":       CATEGORIES["ALIMENTOS_GRAOS"],
    "MACARRAO":     CATEGORIES["ALIMENTOS_GRAOS"],
    "LENTILHA":     CATEGORIES["ALIMENTOS_GRAOS"],
    "AVEIA":        CATEGORIES["ALIMENTOS_GRAOS"],
    "GRAO":         CATEGORIES["ALIMENTOS_GRAOS"],
    "ERVILHA":      CATEGORIES["ALIMENTOS_GRAOS"],
    "MILHO":        CATEGORIES["ALIMENTOS_GRAOS"],

    # Alimentos/Laticínios
    "LEITE":        CATEGORIES["ALIMENTOS_LATICINIOS"],
    "CREME DE LEITE": CATEGORIES["ALIMENTOS_LATICINIOS"],

    # Alimentos/Mercearia
    "ACUCAR":       CATEGORIES["ALIMENTOS_MERCEARIA"],
    "SAL ":         CATEGORIES["ALIMENTOS_MERCEARIA"],   # espaço evita "salsicha"
    "OLEO":         CATEGORIES["ALIMENTOS_MERCEARIA"],
    "CAFE":         CATEGORIES["ALIMENTOS_MERCEARIA"],
    "EXTRATO":      CATEGORIES["ALIMENTOS_MERCEARIA"],
    "MOLHO":        CATEGORIES["ALIMENTOS_MERCEARIA"],
    "VINAGRE":      CATEGORIES["ALIMENTOS_MERCEARIA"],
    "MAIONESE":     CATEGORIES["ALIMENTOS_MERCEARIA"],
    "MOSTARDA":     CATEGORIES["ALIMENTOS_MERCEARIA"],
    "KETCHUP":      CATEGORIES["ALIMENTOS_MERCEARIA"],
    "OVO":          CATEGORIES["ALIMENTOS_MERCEARIA"],
    "AZEITE":       CATEGORIES["ALIMENTOS_MERCEARIA"],

    # Limpeza
    "DETERGENTE":   CATEGORIES["LIMPEZA"],
    "SABAO":        CATEGORIES["LIMPEZA"],
    "AMACIANTE":    CATEGORIES["LIMPEZA"],
    "DESINFETANTE": CATEGORIES["LIMPEZA"],
    "AGUA SANITARIA": CATEGORIES["LIMPEZA"],
    "ESPONJA":      CATEGORIES["LIMPEZA"],
    "VASSOURA":     CATEGORIES["LIMPEZA"],
    "RODO":         CATEGORIES["LIMPEZA"],
    "LIMPADOR":     CATEGORIES["LIMPEZA"],
    "MULTIUSO":     CATEGORIES["LIMPEZA"],
    "SABONETE EM PO": CATEGORIES["LIMPEZA"],

    # Higiene
    "SHAMPOO":      CATEGORIES["HIGIENE"],
    "SABONETE":     CATEGORIES["HIGIENE"],
    "CREME DENTAL": CATEGORIES["HIGIENE"],
    "DENTIFRICIO":  CATEGORIES["HIGIENE"],
    "DESODORANTE":  CATEGORIES["HIGIENE"],
    "PAPEL HIGIENICO": CATEGORIES["HIGIENE"],
    "ABSORVENTE":   CATEGORIES["HIGIENE"],
    "ESCOVA DE DENTES": CATEGORIES["HIGIENE"],
    "FRALDA":       CATEGORIES["HIGIENE"],
    "CONDICIONADOR": CATEGORIES["HIGIENE"],

    # Bebidas
    "REFRIGERANTE": CATEGORIES["BEBIDAS"],
    "CERVEJA":      CATEGORIES["BEBIDAS"],
    "VINHO":        CATEGORIES["BEBIDAS"],
    "SUCO":         CATEGORIES["BEBIDAS"],
    "AGUA MINERAL": CATEGORIES["BEBIDAS"],
    "AGUA ":        CATEGORIES["BEBIDAS"],
    "ENERGETICO":   CATEGORIES["BEBIDAS"],
    "ISOTÔNICO":    CATEGORIES["BEBIDAS"],
    "ISOTON":       CATEGORIES["BEBIDAS"],

    # Lazer / Restaurante
    "RESTAURANTE":  CATEGORIES["LAZER"],
    "LANCHE":       CATEGORIES["LAZER"],
    "PIZZA":        CATEGORIES["LAZER"],
    "CINEMA":       CATEGORIES["LAZER"],
    "INGRESSO":     CATEGORIES["LAZER"],
}


def normalize_string(s: str) -> str:
    """Remove acentos e converte para maiúsculo para matching uniforme."""
    if not s:
        return ""
    s = ''.join(c for c in unicodedata.normalize('NFD', s)
                if unicodedata.category(c) != 'Mn')
    s = re.sub(r'[^\w\s]', ' ', s)
    return s.upper().strip()


def categorize_item(product_name: str) -> str:
    """
    Identifica a categoria (incluindo subcategoria) de um produto baseado em seu nome.
    Retorna strings como "Alimentos/Frios", "Bebidas", etc.
    """
    normalized = normalize_string(product_name)
    # Adiciona espaço no início para matching de palavras com espaço à esquerda (ex: "SAL ")
    padded = ' ' + normalized + ' '

    for keyword, category in KEYWORD_MAP.items():
        if keyword in padded:
            return category

    return CATEGORIES["OUTROS"]
