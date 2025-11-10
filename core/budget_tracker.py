import sqlite3
import os
class BudgetTracker:
    def __init__(self):
        self.db_path = os.getenv("DB_PATH", "./data/costs.db")
        os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
        self._init_db()
    def _init_db(self):
        with sqlite3.connect(self.db_path) as conn:
            conn.execute('CREATE TABLE IF NOT EXISTS cost_tracking (id INTEGER PRIMARY KEY, cost REAL, model_used TEXT)')
    def record_cost(self, model, cost):
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("INSERT INTO cost_tracking (model_used, cost) VALUES (?, ?)", (model, cost))
