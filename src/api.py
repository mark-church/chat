from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sqlalchemy
import database

app = FastAPI()
engine = database.connect_with_connector()

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
