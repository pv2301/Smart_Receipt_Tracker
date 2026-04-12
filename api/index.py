import sys
import os

# Add the project root to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi import FastAPI
from backend.app.main import app as backend_app

# Vercel routes all /api/* requests to this file preserving the full path.
# We mount the backend app at /api so that /api/receipts/ matches /receipts/.
app = FastAPI()
app.mount("/api", backend_app)
