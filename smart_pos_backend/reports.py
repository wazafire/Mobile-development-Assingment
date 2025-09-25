from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from database import SessionLocal
from models import Order

router = APIRouter(prefix="/reports", tags=["Reports"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/daily_sales")
def daily_sales(date: str, db: Session = Depends(get_db)):
    total, count = db.query(func.sum(Order.total), func.count(Order.id))\
                     .filter(func.date(Order.created_at) == date).first()
    return {"date": date, "total_sales": total, "transactions": count}


@router.get("/tax_summary")
def tax_summary(date: str, db: Session = Depends(get_db)):
    # We assume a flat 16% tax rate for all orders (adjust as needed)
    total_sales = db.query(func.sum(Order.total))\
                    .filter(func.date(Order.created_at) == date).scalar()

    if not total_sales:
        total_sales = 0

    tax_collected = total_sales * 0.16
    return {"date": date, "tax_collected": tax_collected}
