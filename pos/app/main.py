from fastapi import FastAPI, BackgroundTasks, HTTPException
from pydantic import BaseModel
import os, asyncio
import httpx
from typing import Optional
from sqlalchemy import create_engine, Column, Integer, String, JSON, TIMESTAMP, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from fastapi import Depends
from sqlalchemy.orm import Session

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./test.db")
TAX_AUTH_URL = os.getenv("TAX_AUTH_URL", "https://db0fa27d-4a6b-4e16-8ed7-09d40d6c30e9.mock.pstmn.io")
MAX_RETRIES = int(os.getenv("MAX_RETRIES", "5"))

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {}
)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

class Invoice(Base):
    __tablename__ = "invoices"
    id = Column(Integer, primary_key=True, index=True)
    invoice_id = Column(String, unique=True, index=True, nullable=False)
    payload = Column(JSON, nullable=False)
    status = Column(String, default="pending")
    created_at = Column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updated_at = Column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))

class InvoiceResponse(Base):
    __tablename__ = "invoice_responses"
    id = Column(Integer, primary_key=True, index=True)
    invoice_id = Column(String, index=True)
    status_code = Column(Integer)
    response_body = Column(JSON)
    authority_reference = Column(String)
    attempt_no = Column(Integer)
    error_message = Column(String, nullable=True)
    created_at = Column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))

Base.metadata.create_all(bind=engine)

app = FastAPI(title="SmartPOS - Invoicing Backend")

class InvoiceModel(BaseModel):
    invoice_id: str
    timestamp: str
    seller: dict
    buyer: Optional[dict] = None
    items: list
    totals: dict
    currency: str
    metadata: Optional[dict] = None

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/invoices/submit", status_code=202)
async def submit_invoice(invoice: InvoiceModel, background_tasks: BackgroundTasks):
    db = SessionLocal()
    existing = db.query(Invoice).filter(Invoice.invoice_id == invoice.invoice_id).first()
    if existing:
        db.close()
        return {"status": "accepted", "note": "invoice already submitted", "invoice_id": invoice.invoice_id}
    inv = Invoice(invoice_id=invoice.invoice_id, payload=invoice.model_dump(), status="processing")
    db.add(inv); db.commit()
    db.close()
    background_tasks.add_task(process_invoice, invoice.model_dump())
    return {"status": "accepted", "invoice_id": invoice.invoice_id}

@app.get("/invoices/{invoice_id}/status")
def invoice_status(invoice_id: str):
    db = SessionLocal()
    inv = db.query(Invoice).filter(Invoice.invoice_id == invoice_id).first()
    if not inv:
        db.close()
        raise HTTPException(status_code=404, detail="invoice not found")
    last_resp = db.query(InvoiceResponse).filter(
        InvoiceResponse.invoice_id == invoice_id
    ).order_by(InvoiceResponse.created_at.desc()).first()
    result = {
        "invoice_id": invoice_id,
        "status": inv.status,
        "last_response": last_resp.response_body if last_resp else None,
        "authority_reference": last_resp.authority_reference if last_resp else None,
        "attempts": last_resp.attempt_no if last_resp else 0,
        "submitted_at": inv.created_at.isoformat() if inv.created_at else None
    }
    db.close()
    return result
@app.get("/invoices")
def list_invoices():
    db = SessionLocal()
    invoices = db.query(Invoice).order_by(Invoice.created_at.desc()).all()
    db.close()
    result = []
    for inv in invoices:
        result.append({
            "invoice_id": inv.invoice_id,
            "status": inv.status,
            "created_at": inv.created_at.isoformat() if inv.created_at else None,
            "updated_at": inv.updated_at.isoformat() if inv.updated_at else None,
            "totals": inv.payload.get("totals") if isinstance(inv.payload, dict) else None,

        })
    return {"invoices": result}

async def process_invoice(invoice_json):
    idempotency_key = invoice_json.get("invoice_id")
    attempt = 0
    backoff = 1
    db = SessionLocal()
    async with httpx.AsyncClient(timeout=15) as client:
        while attempt < MAX_RETRIES:
            attempt += 1
            try:
                headers = {"Idempotency-Key": idempotency_key, "Content-Type": "application/json"}
                resp = await client.post(TAX_AUTH_URL + "/tax/invoice", json=invoice_json, headers=headers)
                try:
                    body = resp.json()
                except Exception:
                    body = {"raw_text": resp.text}
                ir = InvoiceResponse(
                    invoice_id=idempotency_key,
                    status_code=resp.status_code,
                    response_body=body,
                    authority_reference=body.get("authority_reference") if isinstance(body, dict) else None,
                    attempt_no=attempt
                )
                db.add(ir); db.commit()
                if 200 <= resp.status_code < 300:
                    inv = db.query(Invoice).filter(Invoice.invoice_id == idempotency_key).first()
                    inv.status = "accepted"; db.commit(); db.close(); return
                elif 400 <= resp.status_code < 500 and resp.status_code != 429:
                    inv = db.query(Invoice).filter(Invoice.invoice_id == idempotency_key).first()
                    inv.status = "rejected"; db.commit(); db.close(); return
                else:
                    await asyncio.sleep(backoff); backoff *= 2
            except Exception as ex:
                ir = InvoiceResponse(invoice_id=idempotency_key, status_code=None, response_body={}, attempt_no=attempt, error_message=str(ex))
                db.add(ir); db.commit()
                await asyncio.sleep(backoff); backoff *= 2
    inv = db.query(Invoice).filter(Invoice.invoice_id == idempotency_key).first()
    if inv:
        inv.status = "failed"; db.commit()
    db.close()
