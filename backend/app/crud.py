import re
from datetime import datetime
from . import categorizer

def get_receipt(db: Session, receipt_id: int):
    return db.query(models.Receipt).filter(models.Receipt.id == receipt_id).first()

def get_receipts(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Receipt).offset(skip).limit(limit).all()

def create_receipt(db: Session, receipt: schemas.ReceiptCreate):
    db_receipt = models.Receipt(
        store_name=receipt.store_name,
        merchant_id=receipt.merchant_id,
        date=receipt.date,
        total_amount=receipt.total_amount,
        taxes=receipt.taxes,
        qr_data=receipt.qr_data,
        access_key=receipt.access_key
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

def parse_nfce_url(qr_url: str):
    """
    Mock parser for NFC-e URLs.
    Extracts access key if present (usually 44 digits) and returns dummy data.
    In a real-world scenario, this function would perform web scraping via requests/BeautifulSoup.
    """
    access_key_match = re.search(r'(?:p=|chNFe=|\.gov\.br\/.*\/)([0-9]{44})', qr_url)
    access_key = access_key_match.group(1) if access_key_match else "UNKNOWN_KEY"
    
    # Mocking parsed data (this would be real scraping results in production)
    items_data = [
        {"product_name": "Arroz 5kg", "quantity": 1, "unit_price": 25.90},
        {"product_name": "Feijão 1kg", "quantity": 2, "unit_price": 8.50},
        {"product_name": "Óleo de Soja", "quantity": 1, "unit_price": 8.00},
        {"product_name": "Detergente Limp", "quantity": 3, "unit_price": 1.50},
        {"product_name": "Cerveja Lata", "quantity": 6, "unit_price": 4.50},
    ]

    parsed_items = []
    for item in items_data:
        total_price = item["quantity"] * item["unit_price"]
        category = categorizer.categorize_item(item["product_name"])
        parsed_items.append(
            schemas.ReceiptItemCreate(
                product_name=item["product_name"],
                quantity=item["quantity"],
                unit_price=item["unit_price"],
                total_price=total_price,
                category=category
            )
        )

    return schemas.ReceiptCreate(
        store_name="Mercado Exemplo " + access_key[:4],
        merchant_id="12.345.678/0001-99",
        date=datetime.utcnow(),
        total_amount=sum(i.total_price for i in parsed_items),
        taxes=5.50,
        qr_data=qr_url,
        access_key=access_key,
        items=parsed_items
    )
