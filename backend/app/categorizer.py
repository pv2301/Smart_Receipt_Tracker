import re
import unicodedata

# Categorias definidas
CATEGORIES = {
    "ALIMENTOS": "Alimentos",
    "LIMPEZA": "Limpeza",
    "HIGIENE": "Higiene",
    "BEBIDAS": "Bebidas",
    "LAZER": "Lazer",
    "OUTROS": "Outros",
}

# Mapeamento de palavras-chave para categorias
# Chaves em maiúsculo e sem acentos
KEYWORD_MAP = {
    # Alimentos
    "ARROZ": CATEGORIES["ALIMENTOS"],
    "FEIJAO": CATEGORIES["ALIMENTOS"],
    "MACARRAO": CATEGORIES["ALIMENTOS"],
    "CARNE": CATEGORIES["ALIMENTOS"],
    "FRANGO": CATEGORIES["ALIMENTOS"],
    "OVO": CATEGORIES["ALIMENTOS"],
    "LEITE": CATEGORIES["ALIMENTOS"],
    "PAO": CATEGORIES["ALIMENTOS"],
    "ACUCAR": CATEGORIES["ALIMENTOS"],
    "SAL": CATEGORIES["ALIMENTOS"],
    "OLEO": CATEGORIES["ALIMENTOS"],
    "CAFE": CATEGORIES["ALIMENTOS"],
    "FRUTA": CATEGORIES["ALIMENTOS"],
    "LEGUME": CATEGORIES["ALIMENTOS"],
    "BISCOITO": CATEGORIES["ALIMENTOS"],
    "BOLACHA": CATEGORIES["ALIMENTOS"],
    "CHOCOLATE": CATEGORIES["ALIMENTOS"],
    
    # Limpeza
    "DETERGENTE": CATEGORIES["LIMPEZA"],
    "SABÃO": CATEGORIES["LIMPEZA"],
    "SABAO": CATEGORIES["LIMPEZA"],
    "AMACIANTE": CATEGORIES["LIMPEZA"],
    "DESINFETANTE": CATEGORIES["LIMPEZA"],
    "AGUA SANITARIA": CATEGORIES["LIMPEZA"],
    "ESPONJA": CATEGORIES["LIMPEZA"],
    "VASSOURA": CATEGORIES["LIMPEZA"],
    "RODO": CATEGORIES["LIMPEZA"],
    
    # Higiene
    "SHAMPOO": CATEGORIES["HIGIENE"],
    "SABONETE": CATEGORIES["HIGIENE"],
    "CREME DENTAL": CATEGORIES["HIGIENE"],
    "DENTIFRICIO": CATEGORIES["HIGIENE"],
    "DESODORANTE": CATEGORIES["HIGIENE"],
    "PAPEL HIGIENICO": CATEGORIES["HIGIENE"],
    "ABSORVENTE": CATEGORIES["HIGIENE"],
    "ESCOVA DE DENTES": CATEGORIES["HIGIENE"],
    
    # Bebidas
    "REFRIGERANTE": CATEGORIES["BEBIDAS"],
    "CERVEJA": CATEGORIES["BEBIDAS"],
    "VINHO": CATEGORIES["BEBIDAS"],
    "SUCO": CATEGORIES["BEBIDAS"],
    "AGUA MINERAL": CATEGORIES["BEBIDAS"],
    "ENERGETICO": CATEGORIES["BEBIDAS"],
    
    # Lazer / Restaurante
    "RESTAURANTE": CATEGORIES["LAZER"],
    "LANCHE": CATEGORIES["LAZER"],
    "PIZZA": CATEGORIES["LAZER"],
    "CINEMA": CATEGORIES["LAZER"],
    "INGRESSO": CATEGORIES["LAZER"],
}

def normalize_string(s: str) -> str:
    """Remove acentos e converte para maiúsculo para matching uniforme."""
    if not s:
        return ""
    # Remove acentos
    s = ''.join(c for c in unicodedata.normalize('NFD', s)
               if unicodedata.category(c) != 'Mn')
    # Remove pontuação básica e espaços extras
    s = re.sub(r'[^\w\s]', '', s)
    return s.upper().strip()

def categorize_item(product_name: str) -> str:
    """
    Identifica a categoria de um produto baseado em seu nome usando busca por palavras-chave.
    """
    normalized_name = normalize_string(product_name)
    
    for keyword, category in KEYWORD_MAP.items():
        if keyword in normalized_name:
            return category
            
    return CATEGORIES["OUTROS"]
