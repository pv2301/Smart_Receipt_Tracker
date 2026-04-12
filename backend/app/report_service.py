import io
import pandas as pd
import matplotlib.pyplot as plt
from fpdf import FPDF
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import extract
from . import models

class PDF(FPDF):
    def header(self):
        self.set_font('Helvetica', 'B', 15)
        self.cell(0, 10, 'Smart Receipt Tracker - Relatório Mensal', 0, 1, 'C')
        self.ln(5)

    def footer(self):
        self.set_y(-15)
        self.set_font('Helvetica', 'I', 8)
        self.cell(0, 10, f'Página {self.page_no()}', 0, 0, 'C')

def generate_pdf_report(db: Session, month: int, year: int, user_id: int = 1):
    # 1. Fetch Data
    receipts = db.query(models.Receipt).filter(
        models.Receipt.owner_id == user_id,
        extract('month', models.Receipt.date) == month,
        extract('year', models.Receipt.date) == year
    ).all()

    if not receipts:
        # Generate empty PDF with message
        pdf = PDF()
        pdf.add_page()
        pdf.set_font("Helvetica", size=12)
        pdf.cell(0, 10, f"Nenhum recibo encontrado para {month}/{year}", ln=True)
        return pdf.output()

    # 2. Data Processing for Charts
    data = []
    for r in receipts:
        for item in r.items:
            data.append({
                "date": r.date,
                "amount": item.total_price,
                "category": item.category or "Outros",
                "product": item.product_name
            })
    
    df = pd.DataFrame(data)
    
    # 3. Create Charts
    # Chart 1: Category Distribution (Pie)
    cat_summary = df.groupby('category')['amount'].sum()
    plt.figure(figsize=(6, 4))
    cat_summary.plot.pie(autopct='%1.1f%%', colors=['#00E676', '#172033', '#8B9BB4', '#FF5252'])
    plt.title('Gastos por Categoria')
    plt.ylabel('')
    
    chart_pie_buf = io.BytesIO()
    plt.savefig(chart_pie_buf, format='png', bbox_inches='tight')
    plt.close()

    # 4. Generate PDF
    pdf = PDF()
    pdf.add_page()
    
    # Summary Info
    total_spent = df['amount'].sum()
    pdf.set_font("Helvetica", 'B', 12)
    pdf.cell(0, 10, f"Período: {month}/{year} | Total Gasto: R$ {total_spent:.2f}", ln=True)
    pdf.ln(5)

    # Insert Image
    pdf.image(chart_pie_buf, x=30, w=150)
    pdf.ln(10)

    # Detailed Items Table
    pdf.set_font("Helvetica", 'B', 10)
    pdf.set_fill_color(23, 32, 51) # cardColor
    pdf.set_text_color(255, 255, 255)
    
    pdf.cell(30, 8, "Data", 1, 0, 'C', True)
    pdf.cell(90, 8, "Produto", 1, 0, 'C', True)
    pdf.cell(30, 8, "Categoria", 1, 0, 'C', True)
    pdf.cell(40, 8, "Valor", 1, 1, 'C', True)
    
    pdf.set_text_color(0, 0, 0)
    pdf.set_font("Helvetica", size=9)
    
    for _, row in df.iterrows():
        pdf.cell(30, 8, row['date'].strftime('%d/%m/%Y'), 1)
        pdf.cell(90, 8, str(row['product'])[:40], 1)
        pdf.cell(30, 8, str(row['category']), 1)
        pdf.cell(40, 8, f"R$ {row['amount']:.2f}", 1, 1, 'R')

    return pdf.output()

def generate_excel_report(db: Session, month: int, year: int, user_id: int = 1):
    receipts = db.query(models.Receipt).filter(
        models.Receipt.owner_id == user_id,
        extract('month', models.Receipt.date) == month,
        extract('year', models.Receipt.date) == year
    ).all()

    data = []
    for r in receipts:
        for item in r.items:
            data.append({
                "Data": r.date.strftime('%d/%m/%Y'),
                "Loja": r.store_name,
                "Produto": item.product_name,
                "Quantidade": item.quantity,
                "Custo Unit": item.unit_price,
                "Total Item": item.total_price,
                "Categoria": item.category or "Outros"
            })
    
    df = pd.DataFrame(data)
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='openpyxl') as writer:
        df.to_excel(writer, index=False, sheet_name='Gastos Detalhados')
    
    output.seek(0)
    return output.getValue()
