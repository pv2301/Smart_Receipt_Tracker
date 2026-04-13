from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
import io
from . import models, schemas, crud, suggester_service
from .database import engine, get_db
from datetime import datetime

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Smart Receipt Tracker")

# Configure CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Welcome to Smart Receipt Tracker API"}

from . import crud

@app.get("/budget/status", response_model=schemas.BudgetStatusResponse)
def get_budget_status(
    month: int = Query(datetime.now().month),
    year: int = Query(datetime.now().year),
    db: Session = Depends(get_db)
):
    """
    Retorna o status do orçamento para o mês/ano especificado.
    """
    return crud.get_budget_status(db, month=month, year=year)

@app.put("/budget/settings")
def update_budget_settings(budget_in: schemas.UserBudgetUpdate, db: Session = Depends(get_db)):
    """
    Atualiza as configurações globais de orçamento do usuário.
    """
    crud.update_user_budget_settings(db, budget_in)
    return {"status": "success"}

@app.post("/budget/monthly", response_model=schemas.MonthlyGoal)
def set_monthly_goal(goal: schemas.MonthlyGoalCreate, db: Session = Depends(get_db)):
    """
    Define uma meta específica para um mês/ano.
    """
    return crud.upsert_monthly_goal(db, goal)

@app.get("/receipts/export")
def export_receipts(
    format: str = Query("pdf", regex="^(pdf|excel)$"),
    month: int = Query(datetime.now().month),
    year: int = Query(datetime.now().year),
    db: Session = Depends(get_db)
):
    """
    Gera e retorna um relatório (PDF ou Excel) dos recibos do período.
    """
    # Import lazy para evitar carregar pandas/matplotlib na inicialização da Lambda
    from . import report_service
    if format == "pdf":
        content = report_service.generate_pdf_report(db, month, year)
        return StreamingResponse(
            io.BytesIO(content),
            media_type="application/pdf",
            headers={"Content-Disposition": f"attachment; filename=relatorio_{year}_{month}.pdf"}
        )
    else:
        content = report_service.generate_excel_report(db, month, year)
        return StreamingResponse(
            io.BytesIO(content),
            media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            headers={"Content-Disposition": f"attachment; filename=gastos_{year}_{month}.xlsx"}
        )

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
