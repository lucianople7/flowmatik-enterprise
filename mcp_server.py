import os
import aiohttp
from aiohttp import web
import json

async def proxy_chat(request):
    """Proxy endpoint for 302.AI chat completions"""
    try:
        api_key = os.getenv("API_302_KEY")
        if not api_key:
            return web.json_response(
                {"error": "API_302_KEY not set in environment"},
                status=500
            )
        
        data = await request.json()
        
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(
                "https://api.302.ai/v1/chat/completions",
                json=data,
                headers=headers
            ) as resp:
                response_data = await resp.json()
                return web.json_response(response_data, status=resp.status)
                
    except Exception as e:
        return web.json_response(
            {"error": f"Server error: {str(e)}"},
            status=500
        )

async def health_check(request):
    """Health check endpoint"""
    return web.json_response({"status": "ok", "service": "302.AI Proxy"})

app = web.Application()
app.router.add_post("/v1/chat/completions", proxy_chat)
app.router.add_get("/health", health_check)

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    print(f"Starting 302.AI proxy server on port {port}")
    web.run_app(app, host="0.0.0.0", port=port)