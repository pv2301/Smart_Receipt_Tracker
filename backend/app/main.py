from fastapi import FastAPI, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from . import models, schemas, crud, suggester_service
from .database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Smart Receipt Tracker")

@app.get("/")
def read_root():
    return {"message": "Welcome to Smart Receipt Tracker API"}

from . import crud

@app.get("/receipts/", response_model=List[schemas.Receipt])
def read_receipts(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    receipts = crud.get_receipts(db, skip=skip, limit=limit)
    return receipts

@app.get("/receipts/{receipt_id}", response_model=schemas.Receipt)
def read_receipt(receipt_id: int, db: Session = Depends(get_db)):
    db_receipt = crud.get_receipt(db, receipt_id=receipt_id)
    if db_receipt is None:
        raise HTTPException(status_code=404, detail="Receipt not found")
    return db_receipt

@app.get("/suggestions", response_model=List[schemas.SuggestionResponse])
def get_shopping_suggestions(categories: Optional[List[str]] = Query(None), db: Session = Depends(get_db)):
    """
    Retorna sugestões de compra baseadas na frequência histórica.
    """
    return suggester_service.get_suggestions(db, categories=categories)

@app.post("/receipts/scan", response_model=schemas.Receipt)
def scan_receipt(qr_url: str, db: Session = Depends(get_db)):
    # Parse the QR URL to create receipt object structure
    try:
        receipt_in = crud.parse_nfce_url(qr_url)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to parse QR code: {str(e)}")
    
    # Save to database
    return crud.create_receipt(db=db, receipt=receipt_in)
