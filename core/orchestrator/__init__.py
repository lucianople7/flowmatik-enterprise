import logging
from typing import Any, Dict, Optional

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class FlowmatikOrchestrator:
    """Orquestador principal - version minima funcional"""

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        self.config = config or {}
        logger.info("Inicializado correctamente")

    def run(self, pipeline: str, **kwargs) -> Dict[str, Any]:
        logger.info(f"Iniciando pipeline: {pipeline}")
        return {
            "status": "success",
            "pipeline": pipeline,
            "input": kwargs,
            "output": "mock_data"
        }


orchestrator = FlowmatikOrchestrator()
