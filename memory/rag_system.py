from typing import List, Dict


class RAGSystem:
    """Sistema RAG para consultar documentos y memoria"""

    def __init__(self, memory):
        self.memory = memory
        self.documents = []

    def add_document(self, content: str, metadata: Dict):
        """Agrega un documento al sistema"""
        self.documents.append({
            'content': content,
            'metadata': metadata
        })
        print(f"Documento agregado: {metadata.get('title', 'Sin titulo')}")

    def retrieve(self, query: str, top_k: int = 3) -> List[Dict]:
        """Recupera documentos relevantes"""
        # Buscar en documentos
        results = []
        query_lower = query.lower()

        for doc in self.documents:
            if query_lower in doc['content'].lower():
                results.append(doc)

        # Buscar en memoria
        memory_results = self.memory.search_memory(query)
        results.extend(memory_results)

        return results[:top_k]

    def generate_context(self, query: str) -> str:
        """Genera contexto para una query"""
        relevant = self.retrieve(query)

        if not relevant:
            return "No se encontro informacion relevante."

        context = "Informacion relevante:\n\n"
        for i, doc in enumerate(relevant, 1):
            content = doc.get('content', doc.get('fact', ''))
            context += f"{i}. {content}\n\n"

        return context
