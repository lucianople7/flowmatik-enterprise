FROM python:3.10-slim
WORKDIR /app
RUN pip install aiohttp
COPY . .
CMD ["python","mcp_server.py"]
