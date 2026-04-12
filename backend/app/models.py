from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    
    receipts = relationship("Receipt", back_populates="owner")

class Receipt(Base):
    __tablename__ = "receipts"

    id = Column(Integer, primary_key=True, index=True)
    store_name = Column(String, index=True)
    merchant_id = Column(String, index=True, nullable=True) # CNPJ
    date = Column(DateTime, default=datetime.utcnow)
    total_amount = Column(Float)
    taxes = Column(Float, nullable=True)
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
