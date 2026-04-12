import sys
import os

# Add the project root to sys.path
# This allows 'import backend...' to work
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

try:
    from backend.app.main import app
except ImportError as e:
    print(f"Error importing app: {e}")
    # Fallback to help debugging if needed
    raise e
