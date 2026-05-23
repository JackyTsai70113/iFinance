import uuid
from datetime import datetime

from sqlalchemy import Column, String, Float, DateTime, Index
from pydantic import BaseModel, Field
from typing import Optional

from database import Base


class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    amount = Column(Float, nullable=False)
    type = Column(String(10), nullable=False, default="支出")  # 收入 or 支出
    category = Column(String(50), nullable=False, default="breakfast")
    date = Column(DateTime, nullable=False, index=True)
    note = Column(String(200), default="")
    created_at = Column(DateTime, default=datetime.utcnow)


# --- Pydantic schemas ---

class CreateTransactionRequest(BaseModel):
    amount: float
    type: str = "支出"
    category: str = "breakfast"
    date: Optional[datetime] = None
    note: str = ""


class TransactionResponse(BaseModel):
    id: str
    amount: float
    type: str
    category: str
    date: datetime
    note: str
    created_at: datetime

    model_config = {"from_attributes": True}


class TransactionSummary(BaseModel):
    totalIncome: float = Field(alias="totalIncome")
    totalExpense: float = Field(alias="totalExpense")
    balance: float
    count: int
