import aiohttp
import asyncio
import os
import logging

MODEL_CATALOG = {
    "doubao-flash": {"model_id": "doubao-seed-1-6-flash-250715", "cost_per_1k": 0.001, "context_window": 128000},
    "glm-flash": {"model_id": "glm-4-flash-250715", "cost_per_1k": 0.0008, "context_window": 128000},
    "baichuan-flash": {"model_id": "baichuan-4-flash-250715", "cost_per_1k": 0.0007, "context_window": 128000},
    "qwen-flash": {"model_id": "qwen-2.5-1-0-72b-instruct", "cost_per_1k": 0.0009, "context_window": 32000}
}

TASK_TO_MODEL_MAPPING = {
    "coding": ["doubao-flash", "qwen-flash"],
    "business": ["baichuan-flash", "doubao-flash"],
    "chinese_task": ["glm-flash", "baichuan-flash"],
    "quick_chat": ["doubao-flash", "baichuan-flash"]
}

class Flowmatik302AI:
    def __init__(self):
        self.mcp_url = os.getenv("MCP_SERVER_URL", "").rstrip("/")
        if not self.mcp_url: raise ValueError("MCP_SERVER_URL no configurado")

    async def process_task(self, task):
        task_type = "coding" if "c¢digo" in task.lower() else "business"
        models = TASK_TO_MODEL_MAPPING.get(task_type, ["doubao-flash"])
        for model_key in models:
            try:
                async with aiohttp.ClientSession() as session:
                    payload = {"model": MODEL_CATALOG[model_key]["model_id"], "messages": [{"role": "user", "content": task}], "temperature": 0.7, "max_tokens": 1000}
                    async with session.post(f"{self.mcp_url}/v1/chat/completions", json=payload, timeout=30) as resp:
                        if resp.status == 200:
                            data = await resp.json()
                            cost = (1000 / 1000) * MODEL_CATALOG[model_key]["cost_per_1k"]
                            return {"response": data["choices"][0]["message"]["content"], "model_used": model_key, "cost": cost, "success": True}
            except: continue
        return {"response": "Error", "model_used": "none", "cost": 0, "success": False}
