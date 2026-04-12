import re
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import extract, func
from . import models, schemas, categorizer

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
    user = get_user(db, user_id)
    
    # 1. Determine Goal
    monthly_goal = db.query(models.MonthlyGoal).filter(
        models.MonthlyGoal.user_id == user_id,
        models.MonthlyGoal.month == month,
        models.MonthlyGoal.year == year
    ).first()
    
    current_goal = 0.0
    if monthly_goal:
        current_goal = monthly_goal.amount
    elif user.is_budget_fixed:
        current_goal = user.default_budget
    
    # 2. Calculate Total Spent
    total_spent = db.query(models.Receipt).filter(
        models.Receipt.owner_id == user_id,
        extract('month', models.Receipt.date) == month,
        extract('year', models.Receipt.date) == year
    ).with_entities(func.sum(models.Receipt.total_amount)).scalar() or 0.0
    
    remaining = current_goal - total_spent
    percent_used = (total_spent / current_goal * 100) if current_goal > 0 else 0
    
    return schemas.BudgetStatusResponse(
        month=month,
        year=year,
        current_goal=current_goal,
        is_fixed=user.is_budget_fixed,
        total_spent=total_spent,
        remaining=remaining,
        percent_used=percent_used
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

def parse_nfce_url(qr_url: str):
    """
    Mock parser for NFC-e URLs.
    Extracts access key if present (usually 44 digits) and returns dummy data.
    """
    access_key_match = re.search(r'(?:p=|chNFe=|\.gov\.br\/.*\/)([0-9]{44})', qr_url)
    access_key = access_key_match.group(1) if access_key_match else "UNKNOWN_KEY"
    
    # Mocking parsed data
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
