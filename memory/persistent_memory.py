import json
import os
from datetime import datetime
from typing import List, Dict, Any

class PersistentMemory:
    """Sistema de memoria persistente para agentes"""
    
    def __init__(self, memory_file: str = "memory.json"):
        self.memory_file = memory_file
        self.memory = self._load_memory()
    
    def _load_memory(self) -> Dict:
        """Carga memoria desde archivo"""
        if os.path.exists(self.memory_file):
            with open(self.memory_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {'conversations': [], 'facts': [], 'preferences': {}}
    
    def _save_memory(self):
        """Guarda memoria a archivo"""
        with open(self.memory_file, 'w', encoding='utf-8') as f:
            json.dump(self.memory, f, indent=2, ensure_ascii=False)
    
    def store_conversation(self, role: str, content: str, metadata: Dict = None):
        """Almacena una conversacion"""
        entry = {
            'role': role,
            'content': content,
            'timestamp': datetime.now().isoformat(),
            'metadata': metadata or {}
        }
        self.memory['conversations'].append(entry)
        self._save_memory()
    
    def store_fact(self, fact: str, category: str):
        """Almacena un hecho importante"""
        entry = {
            'fact': fact,
            'category': category,
            'timestamp': datetime.now().isoformat()
        }
        self.memory['facts'].append(entry)
        self._save_memory()
    
    def search_memory(self, query: str) -> List[Dict]:
        """Busca en la memoria"""
        results = []
        query_lower = query.lower()
        
        # Buscar en conversaciones
        for conv in self.memory['conversations']:
            if query_lower in conv['content'].lower():
                results.append(conv)
        
        # Buscar en hechos
        for fact in self.memory['facts']:
            if query_lower in fact['fact'].lower():
                results.append(fact)
        
        return results
    
    def get_recent(self, n: int = 10) -> List[Dict]:
        """Obtiene conversaciones recientes"""
        return self.memory['conversations'][-n:]

if __name__ == "__main__":
    mem = PersistentMemory()
    print(f"Memoria cargada: {len(mem.memory['conversations'])} conversaciones")
