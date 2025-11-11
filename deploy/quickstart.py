import os
import sys

print("="*60)
print("FLOWMATIK ENTERPRISE - INSTALACION RAPIDA")
print("="*60)
print("\nPaso 1/3: Instalando dependencias...")
os.system("pip install requests --quiet")
print("OK")

print("\nPaso 2/3: Verificando proxy...")
import requests
try:
    r = requests.get("https://flowmatik-enterprise-1.onrender.com/health", timeout=10)
    if r.status_code == 200:
        print("OK - Proxy funcionando")
    else:
        print("ADVERTENCIA: Proxy respondio con error")
except:
    print("ADVERTENCIA: No se pudo conectar al proxy")

print("\nPaso 3/3: Iniciando sistema...")
sys.path.insert(0, os.path.dirname(__file__))

from core.orchestrator import FlowmatikOrchestrator
from core.architect_agent import ArchitectAgent
from memory.persistent_memory import PersistentMemory
from memory.rag_system import RAGSystem

print("\nInicializando componentes...")
orchestrator = FlowmatikOrchestrator("https://flowmatik-enterprise-1.onrender.com")
architect = ArchitectAgent("https://flowmatik-enterprise-1.onrender.com")
memory = PersistentMemory()
rag = RAGSystem(memory)

print("\n" + "="*60)
print("SISTEMA LISTO")
print("="*60)
print("\nComponentes activos:")
print("- Orchestrator")
print("- Architect Agent")
print("- Persistent Memory")
print("- RAG System")
print("\nEjemplo de uso:")
print("  from deploy.quickstart import orchestrator, architect")
print("  result = architect.create_agent('SEO_Expert', 'SEO', 'Optimiza mi web'^)")
