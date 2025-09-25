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
