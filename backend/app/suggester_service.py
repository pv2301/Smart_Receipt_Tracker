from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from . import models, schemas
from typing import List, Optional

def get_suggestions(db: Session, categories: Optional[List[str]] = None) -> List[schemas.SuggestionResponse]:
    """
    Analisa o histórico de compras para sugerir itens recorrentes.
    Lógica:
    1. Busca todos os itens (ReceiptItem) e as datas das notas (Receipt).
    2. Filtra pelas categorias fornecidas (ou mercado por padrão).
    3. Agrupa por nome do produto.
    4. Para itens com 2 ou mais compras, calcula o intervalo médio.
    5. Determina o status de urgência.
    """
    
    if not categories:
        # Default market categories
        categories = ["Alimentos", "Bebidas", "Limpeza", "Higiene"]

    # Busca itens com join na Receipt para ter a data
    # Filtramos por categoria aqui
    query = (
        db.query(
            models.ReceiptItem.product_name,
            models.ReceiptItem.category,
            models.Receipt.date
        )
        .join(models.Receipt)
        .filter(models.ReceiptItem.category.in_(categories))
        .order_by(models.ReceiptItem.product_name, models.Receipt.date)
    ).all()

    # Organiza em um dicionário: {product_name: [list of dates]}
    product_history = {}
    product_categories = {}
    for item in query:
        product_history.setdefault(item.product_name, []).append(item.date)
        product_categories[item.product_name] = item.category

    suggestions = []
    today = datetime.utcnow()

    for name, dates in product_history.items():
        if len(dates) < 2:
            continue  # Precisa de pelo menos 2 pontos para calcular frequência

        # Remove duplicatas de data no mesmo dia (compras repetidas no mesmo ticket)
        unique_dates = sorted(list(set([d.date() for d in dates])))
        if len(unique_dates) < 2:
            continue

        # Calcula intervalos em dias
        intervals = [
            (unique_dates[i] - unique_dates[i-1]).days 
            for i in range(1, len(unique_dates))
        ]
        
        avg_interval = sum(intervals) / len(intervals)
        last_purchase = datetime.combine(unique_dates[-1], datetime.min.time())
        days_since_last = (today - last_purchase).days
        
        predicted_next = last_purchase + timedelta(days=avg_interval)
        
        # Define status
        # Critico: Dia da compra prevista já passou ou é hoje
        # Proximo: Faltam menos de 20% do intervalo para a data prevista
        status = schemas.SuggestionStatus.NORMAL
        
        if days_since_last >= avg_interval:
            status = schemas.SuggestionStatus.CRITICO
        elif days_since_last >= avg_interval * 0.8:
            status = schemas.SuggestionStatus.PROXIMO

        suggestions.append(
            schemas.SuggestionResponse(
                product_name=name,
                category=product_categories[name],
                avg_interval_days=round(avg_interval, 1),
                last_purchase_date=last_purchase,
                days_since_last=days_since_last,
                predicted_next_date=predicted_next,
                status=status
            )
        )

    # Ordena: CRITICO primeiro, depois PROXIMO, depois NORMAL
    status_order = {
        schemas.SuggestionStatus.CRITICO: 0,
        schemas.SuggestionStatus.PROXIMO: 1,
        schemas.SuggestionStatus.NORMAL: 2
    }
    
    return sorted(suggestions, key=lambda s: status_order[s.status])
