from __future__ import annotations

import re
import warnings
import xml.etree.ElementTree as ET
from datetime import datetime

import requests
import urllib3
from bs4 import BeautifulSoup
from sqlalchemy.orm import Session
from sqlalchemy import extract, func
from . import models, schemas, categorizer

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# ── NFC-e parser constants ────────────────────────────────────────────────────
_NFE_NS = {'nfe': 'http://www.portalfiscal.inf.br/nfe'}

_BROWSER_HEADERS = {
    'User-Agent': (
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/124.0.0.0 Safari/537.36'
    ),
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
}

def get_user(db: Session, user_id: int = 1):
    # Mock user creation if not exists for ID 1
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        user = models.User(username="default_user", id=user_id)
        db.add(user)
        db.commit()
        db.refresh(user)
    return user

def update_user_budget_settings(db: Session, budget_update: schemas.UserBudgetUpdate, user_id: int = 1):
    user = get_user(db, user_id)
    user.default_budget = budget_update.default_budget
    user.is_budget_fixed = budget_update.is_budget_fixed
    db.commit()
    db.refresh(user)
    return user

def upsert_monthly_goal(db: Session, goal: schemas.MonthlyGoalCreate, user_id: int = 1):
    db_goal = db.query(models.MonthlyGoal).filter(
        models.MonthlyGoal.user_id == user_id,
        models.MonthlyGoal.month == goal.month,
        models.MonthlyGoal.year == goal.year
    ).first()
    
    if db_goal:
        db_goal.amount = goal.amount
    else:
        db_goal = models.MonthlyGoal(**goal.dict(), user_id=user_id)
        db.add(db_goal)
    
    db.commit()
    db.refresh(db_goal)
    return db_goal

def get_budget_status(db: Session, month: int, year: int, user_id: int = 1):
    try:
        user = get_user(db, user_id)
        
        # 1. Determine Goal
        monthly_goal = db.query(models.MonthlyGoal).filter(
            models.MonthlyGoal.user_id == user_id,
            models.MonthlyGoal.month == month,
            models.MonthlyGoal.year == year
        ).first()
        
        current_goal = 0.0
        if monthly_goal:
            current_goal = float(monthly_goal.amount)
        elif user and user.is_budget_fixed:
            current_goal = float(user.default_budget)
        
        # 2. Calculate Total Spent
        # Using a more robust date filtering for SQLite/Postgres compatibility
        receipts_query = db.query(models.Receipt).filter(
            models.Receipt.owner_id == user_id,
            extract('month', models.Receipt.date) == month,
            extract('year', models.Receipt.date) == year
        )
        
        total_spent_res = receipts_query.with_entities(func.sum(models.Receipt.total_amount)).scalar()
        total_spent = float(total_spent_res) if total_spent_res else 0.0
        
        remaining = current_goal - total_spent
        percent_used = (total_spent / current_goal * 100.0) if current_goal > 0 else 0.0
        
        return schemas.BudgetStatusResponse(
            month=month,
            year=year,
            current_goal=current_goal,
            is_fixed=user.is_budget_fixed if user else True,
            total_spent=total_spent,
            remaining=remaining,
            percent_used=percent_used
        )
    except Exception as e:
        print(f"Error in get_budget_status: {e}")
        # Return a fallback response instead of 500
        return schemas.BudgetStatusResponse(
            month=month, year=year, current_goal=0, is_fixed=True,
            total_spent=0, remaining=0, percent_used=0
        )

def get_receipt(db: Session, receipt_id: int):
    return db.query(models.Receipt).filter(models.Receipt.id == receipt_id).first()

def get_receipts(db: Session, skip: int = 0, limit: int = 100):
    user = get_user(db)
    return db.query(models.Receipt).filter(models.Receipt.owner_id == user.id).offset(skip).limit(limit).all()

def create_receipt(db: Session, receipt: schemas.ReceiptCreate):
    user = get_user(db)
    db_receipt = models.Receipt(
        store_name=receipt.store_name,
        merchant_id=receipt.merchant_id,
        date=receipt.date,
        total_amount=receipt.total_amount,
        taxes=receipt.taxes,
        qr_data=receipt.qr_data,
        access_key=receipt.access_key,
        owner_id=user.id
    )
    db.add(db_receipt)
    db.commit()
    db.refresh(db_receipt)
    
    for item in receipt.items:
        db_item = models.ReceiptItem(**item.dict(), receipt_id=db_receipt.id)
        db.add(db_item)
    
    db.commit()
    db.refresh(db_receipt)
    return db_receipt

# ── NFC-e helper functions ────────────────────────────────────────────────────

def _extract_access_key(url: str) -> str:
    """Extract the 44-digit NF-e access key from a QR code URL."""
    for pattern in [r'chNFe=([0-9]{44})', r'p=([0-9]{44})', r'([0-9]{44})']:
        m = re.search(pattern, url)
        if m:
            return m.group(1)
    return 'UNKNOWN'


def _br_float(text: str) -> float:
    """Parse Brazilian number format: '1.234,56' → 1234.56"""
    if not text:
        return 0.0
    cleaned = re.sub(r'[^\d,]', '', text.strip())  # keep only digits and comma
    cleaned = cleaned.replace(',', '.')
    try:
        return float(cleaned)
    except ValueError:
        return 0.0


def _xml_text(elem, tag: str) -> str | None:
    if elem is None:
        return None
    child = elem.find(tag, _NFE_NS)
    return child.text.strip() if child is not None and child.text else None


def _build_items(raw_items: list[dict]) -> list[schemas.ReceiptItemCreate]:
    result = []
    for it in raw_items:
        name = it.get('product_name', 'Produto')
        qty = float(it.get('quantity', 1))
        unit_price = float(it.get('unit_price', 0))
        total_price = float(it.get('total_price') or qty * unit_price)
        result.append(schemas.ReceiptItemCreate(
            product_name=name,
            quantity=qty,
            unit_price=unit_price,
            total_price=total_price,
            category=categorizer.categorize_item(name),
        ))
    return result


def _try_parse_xml(content: bytes, qr_url: str, access_key: str) -> schemas.ReceiptCreate | None:
    """
    Parse standard NF-e XML (nfeProc or NFe root).
    Returns None if content is not valid NF-e XML.
    """
    try:
        root = ET.fromstring(content)
    except ET.ParseError:
        return None

    inf = root.find('.//nfe:infNFe', _NFE_NS)
    if inf is None:
        return None

    # Emitter
    emit = inf.find('nfe:emit', _NFE_NS)
    store_name = (
        _xml_text(emit, 'nfe:xFant')
        or _xml_text(emit, 'nfe:xNome')
        or 'Loja Desconhecida'
    )
    raw_cnpj = _xml_text(emit, 'nfe:CNPJ') or ''
    cnpj = (
        f'{raw_cnpj[:2]}.{raw_cnpj[2:5]}.{raw_cnpj[5:8]}/{raw_cnpj[8:12]}-{raw_cnpj[12:]}'
        if len(raw_cnpj) == 14 else raw_cnpj
    )

    # Date
    ide = inf.find('nfe:ide', _NFE_NS)
    date_str = _xml_text(ide, 'nfe:dhEmi') or ''
    try:
        date = datetime.fromisoformat(date_str[:19])
    except Exception:
        date = datetime.utcnow()

    # Items
    raw_items = []
    for det in inf.findall('nfe:det', _NFE_NS):
        prod = det.find('nfe:prod', _NFE_NS)
        if prod is None:
            continue
        raw_items.append({
            'product_name': _xml_text(prod, 'nfe:xProd') or 'Produto',
            'quantity':     _xml_text(prod, 'nfe:qCom') or '1',
            'unit_price':   _xml_text(prod, 'nfe:vUnCom') or '0',
            'total_price':  _xml_text(prod, 'nfe:vProd') or '0',
        })

    if not raw_items:
        return None

    items = _build_items(raw_items)

    # Totals
    icms = inf.find('.//nfe:ICMSTot', _NFE_NS)
    total_amount = float(_xml_text(icms, 'nfe:vNF') or 0) if icms else sum(i.total_price for i in items)
    taxes = float(_xml_text(icms, 'nfe:vTotTrib') or 0) if icms else 0.0

    return schemas.ReceiptCreate(
        store_name=store_name,
        merchant_id=cnpj,
        date=date,
        total_amount=total_amount,
        taxes=taxes,
        qr_data=qr_url,
        access_key=access_key,
        items=items,
    )


def _try_parse_html(html: str, qr_url: str, access_key: str) -> schemas.ReceiptCreate | None:
    """
    Parse Brazilian NF-e consumer portal HTML (DANFE NFC-e, ENCAT/CONFAZ standard).
    Covers the standard layout used by PE, SP, MG, RJ, RS, BA, CE, GO, SC, PR.
    """
    soup = BeautifulSoup(html, 'html.parser')

    # ── Store name ──────────────────────────────────────────────────────────
    store_name = 'Loja Desconhecida'
    for sel in ['#nomeEmitente', '.NomEmit', '.col-info h4', '.txtTit', 'h4', 'h3']:
        el = soup.select_one(sel)
        if el:
            text = el.get_text(strip=True)
            if len(text) > 2:
                store_name = text
                break

    # ── CNPJ ────────────────────────────────────────────────────────────────
    cnpj = ''
    page_text = soup.get_text(' ')
    cnpj_m = re.search(r'(\d{2}[\.\s]?\d{3}[\.\s]?\d{3}[/\s]?\d{4}[-\s]?\d{2})', page_text)
    if cnpj_m:
        cnpj = cnpj_m.group(1)

    # ── Date ────────────────────────────────────────────────────────────────
    date = datetime.utcnow()
    date_m = re.search(r'(\d{2})/(\d{2})/(\d{4})', page_text)
    if date_m:
        try:
            date = datetime(int(date_m.group(3)), int(date_m.group(2)), int(date_m.group(1)))
        except Exception:
            pass

    # ── Items: table-based (standard SEFAZ layout) ───────────────────────────
    raw_items = []

    # Find main items table
    table = None
    for t in soup.find_all('table'):
        rows = t.find_all('tr')
        if len(rows) > 2:
            table = t
            break

    if table:
        rows = table.find_all('tr')
        # Detect column indices from header row
        col_desc, col_qty, col_unit_price, col_total = 1, 2, 4, 5
        if rows:
            header_cells = rows[0].find_all(['th', 'td'])
            for i, cell in enumerate(header_cells):
                h = cell.get_text(strip=True).lower()
                if any(w in h for w in ['desc', 'produto', 'nom']):
                    col_desc = i
                elif any(w in h for w in ['qtd', 'qde', 'quant']):
                    col_qty = i
                elif any(w in h for w in ['unit', 'unitário', 'vl.u', 'v.unit']):
                    col_unit_price = i
                elif any(w in h for w in ['total', 'vl.t', 'subtotal', 'v.tot']):
                    col_total = i

        for row in rows[1:]:
            cells = row.find_all(['td', 'th'])
            if len(cells) <= col_desc:
                continue
            name = cells[col_desc].get_text(strip=True) if col_desc < len(cells) else ''
            if not name or len(name) < 2:
                continue
            qty = _br_float(cells[col_qty].get_text()) if col_qty < len(cells) else 1.0
            unit_price = _br_float(cells[col_unit_price].get_text()) if col_unit_price < len(cells) else 0.0
            total_price = _br_float(cells[col_total].get_text()) if col_total < len(cells) else 0.0
            if total_price == 0 and qty > 0 and unit_price > 0:
                total_price = round(qty * unit_price, 2)
            raw_items.append({
                'product_name': name,
                'quantity': qty,
                'unit_price': unit_price,
                'total_price': total_price,
            })

    # ── Items: div-based fallback (some states use divs) ────────────────────
    if not raw_items:
        for item_div in soup.select('.item, .row-produto, [class*="item-nfe"], .linha-produto'):
            texts = [el.get_text(strip=True) for el in item_div.find_all(['span', 'p', 'div'])
                     if el.get_text(strip=True)]
            if len(texts) < 2:
                continue
            name = texts[0]
            numbers = [_br_float(t) for t in texts[1:] if re.search(r'\d', t)]
            if not numbers:
                continue
            total_price = numbers[-1]
            unit_price = numbers[-2] if len(numbers) >= 2 else total_price
            qty = numbers[0] if len(numbers) >= 3 else 1.0
            raw_items.append({
                'product_name': name,
                'quantity': qty,
                'unit_price': unit_price,
                'total_price': total_price,
            })

    if not raw_items:
        return None

    items = _build_items(raw_items)

    # ── Total ────────────────────────────────────────────────────────────────
    total_amount = sum(i.total_price for i in items)
    for sel in ['.totalNumb', '#totalNota', '.grand-total', '[id*="total"]', '[class*="total"]']:
        el = soup.select_one(sel)
        if el:
            parsed = _br_float(el.get_text())
            if parsed > 0:
                total_amount = parsed
                break

    return schemas.ReceiptCreate(
        store_name=store_name,
        merchant_id=cnpj,
        date=date,
        total_amount=total_amount,
        taxes=0.0,
        qr_data=qr_url,
        access_key=access_key,
        items=items,
    )


def _fallback_receipt(qr_url: str, access_key: str) -> schemas.ReceiptCreate:
    """Minimal receipt saved when all parsing attempts fail."""
    label = f'NFC-e {access_key[:8]}...' if access_key != 'UNKNOWN' else 'Nota Fiscal'
    return schemas.ReceiptCreate(
        store_name=label,
        merchant_id='',
        date=datetime.utcnow(),
        total_amount=0.0,
        taxes=0.0,
        qr_data=qr_url,
        access_key=access_key,
        items=[schemas.ReceiptItemCreate(
            product_name='[Itens não lidos — portal indisponível]',
            quantity=1,
            unit_price=0.0,
            total_price=0.0,
            category='outros',
        )],
    )


def parse_nfce_url(qr_url: str) -> schemas.ReceiptCreate:
    """
    Real NFC-e parser.
    1. Fetches the QR code URL (follows redirects, ignores SSL errors).
    2. Tries standard NF-e XML parsing first.
    3. Falls back to HTML scraping of the consumer portal.
    4. If both fail, saves a minimal receipt preserving the QR data.
    """
    access_key = _extract_access_key(qr_url)

    try:
        resp = requests.get(
            qr_url,
            headers=_BROWSER_HEADERS,
            timeout=15,
            verify=False,
            allow_redirects=True,
        )
        resp.raise_for_status()

        # Try XML (works when SEFAZ returns raw NF-e XML)
        result = _try_parse_xml(resp.content, qr_url, access_key)
        if result:
            return result

        # Try HTML (standard DANFE NFC-e portal)
        result = _try_parse_html(resp.text, qr_url, access_key)
        if result:
            return result

    except (requests.exceptions.Timeout, requests.exceptions.ConnectionError):
        pass
    except Exception:
        pass

    return _fallback_receipt(qr_url, access_key)
