import uuid
from datetime import datetime

from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from database import engine, get_db, Base
from models import (
    Transaction,
    CreateTransactionRequest,
    TransactionResponse,
    TransactionSummary,
)

# Create tables on startup
Base.metadata.create_all(bind=engine)

app = FastAPI(title="iFinance API")


@app.get("/api/transactions", response_model=list[TransactionResponse])
def list_transactions(month: str | None = Query(None), db: Session = Depends(get_db)):
    query = db.query(Transaction)

    if month:
        try:
            month_date = datetime.strptime(month + "-01", "%Y-%m-%d")
            start = month_date.replace(day=1)
            if start.month == 12:
                end = start.replace(year=start.year + 1, month=1)
            else:
                end = start.replace(month=start.month + 1)
            query = query.filter(Transaction.date >= start, Transaction.date < end)
        except ValueError:
            pass

    transactions = query.order_by(Transaction.date.desc()).all()
    return transactions


@app.get("/api/transactions/{id}", response_model=TransactionResponse)
def get_transaction(id: str, db: Session = Depends(get_db)):
    transaction = db.query(Transaction).filter(Transaction.id == id).first()
    if transaction is None:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return transaction


@app.post("/api/transactions", response_model=TransactionResponse, status_code=201)
def create_transaction(req: CreateTransactionRequest, db: Session = Depends(get_db)):
    transaction = Transaction(
        id=str(uuid.uuid4()),
        amount=req.amount,
        type=req.type,
        category=req.category,
        date=req.date or datetime.utcnow(),
        note=req.note,
        created_at=datetime.utcnow(),
    )
    db.add(transaction)
    db.commit()
    db.refresh(transaction)
    return transaction


@app.put("/api/transactions/{id}", response_model=TransactionResponse)
def update_transaction(
    id: str, req: CreateTransactionRequest, db: Session = Depends(get_db)
):
    transaction = db.query(Transaction).filter(Transaction.id == id).first()
    if transaction is None:
        raise HTTPException(status_code=404, detail="Transaction not found")

    transaction.amount = req.amount
    transaction.type = req.type
    transaction.category = req.category
    transaction.date = req.date or transaction.date
    transaction.note = req.note

    db.commit()
    db.refresh(transaction)
    return transaction


@app.delete("/api/transactions/{id}", status_code=204)
def delete_transaction(id: str, db: Session = Depends(get_db)):
    transaction = db.query(Transaction).filter(Transaction.id == id).first()
    if transaction is None:
        raise HTTPException(status_code=404, detail="Transaction not found")

    db.delete(transaction)
    db.commit()
    return None


@app.get("/api/summary")
def get_summary(month: str | None = Query(None), db: Session = Depends(get_db)):
    query = db.query(Transaction)

    if month:
        try:
            month_date = datetime.strptime(month + "-01", "%Y-%m-%d")
            start = month_date.replace(day=1)
            if start.month == 12:
                end = start.replace(year=start.year + 1, month=1)
            else:
                end = start.replace(month=start.month + 1)
            query = query.filter(Transaction.date >= start, Transaction.date < end)
        except ValueError:
            pass

    transactions = query.all()
    income = sum(t.amount for t in transactions if t.type == "收入")
    expense = sum(t.amount for t in transactions if t.type == "支出")

    return {
        "totalIncome": income,
        "totalExpense": expense,
        "balance": income - expense,
        "count": len(transactions),
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
