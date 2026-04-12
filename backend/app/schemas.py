from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class ReceiptItemBase(BaseModel):
    product_name: str
    product_code: Optional[str] = None
    quantity: float
    unit_price: float
    total_price: float
    category: Optional[str] = None

class ReceiptItemCreate(ReceiptItemBase):
    pass

class ReceiptItem(ReceiptItemBase):
    id: int
    receipt_id: int

    class Config:
        from_attributes = True

class ReceiptBase(BaseModel):
    store_name: str
    merchant_id: Optional[str] = None
    date: datetime
    total_amount: float
    taxes: Optional[float] = None
    qr_data: Optional[str] = None
    access_key: Optional[str] = None

class ReceiptCreate(ReceiptBase):
    items: List[ReceiptItemCreate] = []

class Receipt(ReceiptBase):
    id: int
    owner_id: Optional[int] = None
    items: List[ReceiptItem] = []

    class Config:
        from_attributes = True
