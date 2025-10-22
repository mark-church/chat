from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
import sqlalchemy
import database
import httpx
import os

# --- CONFIGURATION ---
STREAMLIT_URL = os.environ.get("STREAMLIT_URL", "http://127.0.0.1:8501")

# --- SETUP ---
app = FastAPI()
engine = database.connect_with_connector()
client = httpx.AsyncClient(base_url=STREAMLIT_URL)

# --- Pydantic Model for Data Validation ---
class Message(BaseModel):
    username: str
    message: str
    avatar: str
    channel: str

# --- API Endpoint ---
@app.post("/send_message")
def send_message(message: Message):
    """
    Receives a message and inserts it into the database.
    """
    try:
        with engine.connect() as conn:
            conn.execute(
                sqlalchemy.text(
                    "INSERT INTO messages (username, message, avatar, channel) VALUES (:username, :message, :avatar, :channel)"
                ),
                {
                    "username": message.username,
                    "message": message.message,
                    "avatar": message.avatar,
                    "channel": message.channel,
                },
            )
            conn.commit()
        return {"status": "success", "message": "Message sent"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- Streamlit Proxy ---
async def _proxy(request: Request):
    """
    A reverse proxy that forwards all requests to the Streamlit server.
    """
    url = httpx.URL(path=request.url.path, query=request.url.query.encode("utf-8"))
    rp_req = client.build_request(
        request.method, url, headers=request.headers.raw, content=await request.body()
    )
    rp_resp = await client.send(rp_req, stream=True)
    return StreamingResponse(
        rp_resp.aiter_raw(),
        status_code=rp_resp.status_code,
        headers=rp_resp.headers,
        background=rp_resp.aclose,
    )

# Add the proxy routes. This must be last.
app.add_route("/{path:path}", _proxy, ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"])