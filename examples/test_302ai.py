import asyncio
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from core.302ai_orchestrator import Flowmatik302AI
async def main():
    orchestrator = Flowmatik302AI()
    result = await orchestrator.process_task("Hola, prueba")
    print("V Resultado:", result["response"][:50], "...")
asyncio.run(main())
