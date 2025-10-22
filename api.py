from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sqlite3

app = FastAPI()

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
        conn = sqlite3.connect('chat.db')
        c = conn.cursor()
        c.execute("INSERT INTO messages (username, message, avatar, channel) VALUES (?, ?, ?, ?)",
                    (message.username, message.message, message.avatar, message.channel))
        conn.commit()
        conn.close()
        return {"status": "success", "message": "Message sent"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))