from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
import io
from . import models, schemas, crud, suggester_service
from .database import engine, get_db
from datetime import datetime

try:
    models.Base.metadata.create_all(bind=engine)
except Exception as _db_init_err:
    import logging
    logging.warning(f"[startup] create_all falhou: {_db_init_err}")

# Migrações incrementais: adiciona colunas novas sem derrubar tabelas existentes.
# ADD COLUMN IF NOT EXISTS é idempotente — seguro rodar toda vez.
try:
    from sqlalchemy import text
    with engine.connect() as _conn:
        _conn.execute(text(
            "ALTER TABLE receipts ADD COLUMN IF NOT EXISTS tax_state FLOAT"
        ))
        _conn.execute(text(
            "ALTER TABLE receipts ADD COLUMN IF NOT EXISTS tax_federal FLOAT"
        ))
        _conn.commit()
except Exception as _migration_err:
    import logging
    logging.warning(f"[startup] migração incremental falhou: {_migration_err}")

app = FastAPI(title="Notinha")

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
    format: str = Query("pdf", pattern="^(pdf|excel)$"),
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

@app.get("/receipts/{receipt_id}/export")
def export_single_receipt(
    receipt_id: int,
    format: str = Query("pdf", pattern="^(pdf|excel)$"),
    db: Session = Depends(get_db)
):
    """Gera PDF ou Excel de um único recibo pelo ID."""
    from . import report_service
    if format == "pdf":
        content = report_service.generate_single_receipt_pdf(db, receipt_id)
        return StreamingResponse(
            io.BytesIO(content),
            media_type="application/pdf",
            headers={"Content-Disposition": f"attachment; filename=recibo_{receipt_id}.pdf"}
        )
    else:
        content = report_service.generate_single_receipt_excel(db, receipt_id)
        return StreamingResponse(
            io.BytesIO(content),
            media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            headers={"Content-Disposition": f"attachment; filename=recibo_{receipt_id}.xlsx"}
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

@app.delete("/receipts/{receipt_id}", status_code=204)
def delete_receipt(receipt_id: int, db: Session = Depends(get_db)):
    deleted = crud.delete_receipt(db, receipt_id=receipt_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Receipt not found")

@app.delete("/receipts/", status_code=200)
def delete_all_receipts(db: Session = Depends(get_db)):
    """Apaga todos os recibos do usuário padrão."""
    count = crud.delete_all_receipts(db)
    return {"deleted": count}

@app.post("/receipts/ocr", response_model=schemas.Receipt)
def scan_receipt_ocr(req: schemas.OcrScanRequest, db: Session = Depends(get_db)):
    """
    Recebe texto extraído por OCR de um cupom impresso,
    parseia e salva como recibo.
    """
    try:
        receipt_in = crud.parse_receipt_from_ocr_text(req.text)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Falha ao parsear OCR: {str(e)}")
    return crud.create_receipt(db=db, receipt=receipt_in)

@app.get("/suggestions", response_model=List[schemas.SuggestionResponse])
def get_shopping_suggestions(categories: Optional[List[str]] = Query(None), db: Session = Depends(get_db)):
    """
    Retorna sugestões de compra baseadas na frequência histórica.
    """
    return suggester_service.get_suggestions(db, categories=categories)

@app.patch("/receipt-items/{item_id}", response_model=schemas.ReceiptItem)
def update_receipt_item(item_id: int, patch: schemas.ReceiptItemPatch, db: Session = Depends(get_db)):
    """Atualiza campos de um item de recibo (ex: corrigir categoria)."""
    item = crud.patch_receipt_item(db, item_id=item_id, patch=patch)
    if item is None:
        raise HTTPException(status_code=404, detail="Item não encontrado")
    return item

@app.post("/receipts/scan", response_model=schemas.Receipt)
def scan_receipt(qr_url: str, db: Session = Depends(get_db)):
    # Parse the QR URL to create receipt object structure
    try:
        receipt_in = crud.parse_nfce_url(qr_url)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to parse QR code: {str(e)}")

    # Save to database
    return crud.create_receipt(db=db, receipt=receipt_in)
