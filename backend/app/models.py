from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    default_budget = Column(Float, default=0.0)
    is_budget_fixed = Column(Boolean, default=True)
    
    receipts = relationship("Receipt", back_populates="owner")
    monthly_goals = relationship("MonthlyGoal", back_populates="owner")

class MonthlyGoal(Base):
    __tablename__ = "monthly_goals"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    month = Column(Integer) # 1-12
    year = Column(Integer)
    amount = Column(Float)

    owner = relationship("User", back_populates="monthly_goals")

class Receipt(Base):
    __tablename__ = "receipts"

    id = Column(Integer, primary_key=True, index=True)
    store_name = Column(String, index=True)
    merchant_id = Column(String, index=True, nullable=True) # CNPJ
    date = Column(DateTime, default=datetime.utcnow)
    total_amount = Column(Float)
    taxes = Column(Float, nullable=True)
    tax_state = Column(Float, nullable=True)    # ICMS (estadual)
    tax_federal = Column(Float, nullable=True)  # PIS + COFINS (federal)
    qr_data = Column(Text, nullable=True)  # Raw URL or data from QR code
    access_key = Column(String, unique=True, index=True, nullable=True) # Chave de acesso NFC-e
    owner_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    owner = relationship("User", back_populates="receipts")
    items = relationship("ReceiptItem", back_populates="receipt", cascade="all, delete-orphan")

class ReceiptItem(Base):
    __tablename__ = "receipt_items"

    id = Column(Integer, primary_key=True, index=True)
    product_name = Column(String, index=True)
    product_code = Column(String, nullable=True)
    quantity = Column(Float)
    unit_price = Column(Float)
    total_price = Column(Float)
    category = Column(String, nullable=True)
    receipt_id = Column(Integer, ForeignKey("receipts.id"))

    receipt = relationship("Receipt", back_populates="items")
