import os
from aiohttp import web
import aiohttp
async def h(request):
 k=os.getenv("MCP_ACCESS_KEY")
 if not k: raise Exception("No key")
 p=await request.json()
 async with aiohttp.ClientSession() as s:
  r=await s.post("https://api.302.ai/v1/chat/completions", json=p, headers={"Authorization":"Bearer "+k})
  return web.json_response(await r.json())
app=web.Application()
app.router.add_post("/v1/chat/completions", h)
if __name__=="__main__":
 import os
 web.run_app(app, port=int(os.getenv("PORT",10000)))
