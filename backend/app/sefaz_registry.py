"""
Registro de SEFAZs estaduais brasileiras.
Permite detectar o estado emissor a partir da URL do QR code ou da chave de acesso NF-e.
"""
from __future__ import annotations
import re
from urllib.parse import urlparse

# ── Código IBGE (cUF) → sigla do estado ──────────────────────────────────────
CUF_TO_STATE: dict[str, str] = {
    "11": "RO", "12": "AC", "13": "AM", "14": "RR", "15": "PA",
    "16": "AP", "17": "TO", "21": "MA", "22": "PI", "23": "CE",
    "24": "RN", "25": "PB", "26": "PE", "27": "AL", "28": "SE",
    "29": "BA", "31": "MG", "32": "ES", "33": "RJ", "35": "SP",
    "41": "PR", "42": "SC", "43": "RS", "50": "MS", "51": "MT",
    "52": "GO", "53": "DF",
}

# ── Domínio da SEFAZ → sigla do estado ───────────────────────────────────────
SEFAZ_BY_DOMAIN: dict[str, str] = {
    "nfce.sefaz.pe.gov.br":              "PE",
    "nfce.sefaz.pe.gov.br:444":          "PE",
    "www.nfce.fazenda.sp.gov.br":        "SP",
    "nfce.fazenda.sp.gov.br":            "SP",
    "nfce.fazenda.rj.gov.br":            "RJ",
    "www.fazenda.rj.gov.br":             "RJ",
    "nfce.sefaz.ba.gov.br":              "BA",
    "nfce.sefaz.mg.gov.br":              "MG",
    "www.fazenda.mg.gov.br":             "MG",
    "nfce.sefaz.rs.gov.br":              "RS",
    "nfce.sefaz.pr.gov.br":              "PR",
    "sat.sef.sc.gov.br":                 "SC",
    "nfce.sef.sc.gov.br":                "SC",
    "nfce.sefaz.ce.gov.br":              "CE",
    "nfce.sefaz.go.gov.br":              "GO",
    "sistemas.sefaz.am.gov.br":          "AM",
    "nfce.sefaz.ma.gov.br":              "MA",
    "nfce.sefaz.mt.gov.br":              "MT",
    "nfce.sefaz.ms.gov.br":              "MS",
    "nfce.sefaz.es.gov.br":              "ES",
    "nfce.sefaz.pi.gov.br":              "PI",
    "nfce.sefaz.rn.gov.br":              "RN",
    "nfce.sefaz.pb.gov.br":              "PB",
    "nfce.sefaz.al.gov.br":              "AL",
    "nfce.sefaz.se.gov.br":              "SE",
    "nfce.sefaz.ro.gov.br":              "RO",
    "nfce.sefaz.to.gov.br":              "TO",
    "nfce.sefaz.pa.gov.br":              "PA",
}

# ── Nome completo do estado ───────────────────────────────────────────────────
STATE_NAMES: dict[str, str] = {
    "AC": "Acre", "AL": "Alagoas", "AP": "Amapá", "AM": "Amazonas",
    "BA": "Bahia", "CE": "Ceará", "DF": "Distrito Federal",
    "ES": "Espírito Santo", "GO": "Goiás", "MA": "Maranhão",
    "MT": "Mato Grosso", "MS": "Mato Grosso do Sul", "MG": "Minas Gerais",
    "PA": "Pará", "PB": "Paraíba", "PR": "Paraná", "PE": "Pernambuco",
    "PI": "Piauí", "RJ": "Rio de Janeiro", "RN": "Rio Grande do Norte",
    "RS": "Rio Grande do Sul", "RO": "Rondônia", "RR": "Roraima",
    "SC": "Santa Catarina", "SP": "São Paulo", "SE": "Sergipe",
    "TO": "Tocantins",
}


def detect_state_from_url(url: str) -> str | None:
    """Detecta o estado emissor a partir do domínio da URL do QR code NFC-e."""
    try:
        parsed = urlparse(url)
        host = parsed.netloc or parsed.path.split('/')[0]
        # Remove port if present for matching
        host_no_port = host.split(':')[0]
        # Try with port first, then without
        return (
            SEFAZ_BY_DOMAIN.get(host)
            or SEFAZ_BY_DOMAIN.get(host_no_port)
        )
    except Exception:
        return None


def detect_state_from_key(access_key: str) -> str | None:
    """
    Detecta o estado emissor a partir da chave de acesso NF-e (44 dígitos).
    Os 2 primeiros dígitos são o cUF (código IBGE do estado).
    """
    digits = re.sub(r'\D', '', access_key)
    if len(digits) >= 2:
        return CUF_TO_STATE.get(digits[:2])
    return None


def detect_state(url: str, access_key: str = '') -> str | None:
    """Detecta o estado tentando URL primeiro, depois chave de acesso."""
    return detect_state_from_url(url) or detect_state_from_key(access_key)
