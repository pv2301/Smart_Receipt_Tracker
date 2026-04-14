from datetime import datetime
from enum import Enum
from typing import List, Optional
from pydantic import BaseModel

class SuggestionStatus(str, Enum):
    NORMAL = "Normal"
    PROXIMO = "Próximo"
    CRITICO = "Crítico"

class SuggestionResponse(BaseModel):
    product_name: str
    category: str
    avg_interval_days: float
    last_purchase_date: datetime
    days_since_last: int
    predicted_next_date: datetime
    status: SuggestionStatus

class MonthlyGoalBase(BaseModel):
    month: int
    year: int
    amount: float

class MonthlyGoalCreate(MonthlyGoalBase):
    pass

class MonthlyGoal(MonthlyGoalBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True

class OcrScanRequest(BaseModel):
    text: str

class UserBudgetUpdate(BaseModel):
    default_budget: float
    is_budget_fixed: bool

class BudgetStatusResponse(BaseModel):
    month: int
    year: int
    current_goal: float
    is_fixed: bool
    total_spent: float
    remaining: float
    percent_used: float

class ReceiptItemPatch(BaseModel):
    category: Optional[str] = None

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
    tax_state: Optional[float] = None
    tax_federal: Optional[float] = None
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
