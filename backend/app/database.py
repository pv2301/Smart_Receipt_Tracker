import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# The default URL assumes running locally with Docker via docker-compose
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://receipt_user:receipt_password@localhost/receipt_tracker")

# Vercel Postgres / Neon fornece URLs com prefixo "postgres://" mas SQLAlchemy exige "postgresql://"
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# Neon e Vercel Postgres exigem SSL. Se a URL não tiver sslmode, adiciona.
connect_args = {}
if "neon.tech" in DATABASE_URL or "vercel-storage.com" in DATABASE_URL:
    connect_args = {"sslmode": "require"}
elif "sslmode" not in DATABASE_URL and "localhost" not in DATABASE_URL and "127.0.0.1" not in DATABASE_URL:
    connect_args = {"sslmode": "require"}

engine = create_engine(DATABASE_URL, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
