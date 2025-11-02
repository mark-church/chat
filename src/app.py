import random
import time
import logging

import google.cloud.logging
import sqlalchemy
from flask import Flask, render_template, request, redirect, url_for

import database

# --- LOGGING SETUP ---
client = google.cloud.logging.Client()
client.setup_logging()

# --- DATABASE SETUP ---
engine = database.connect_with_connector()
database.create_tables(engine)

# --- USER AND AVATAR SETUP ---
USER_LIST = [
    ("Alice", "🍎"), ("Bob", "🍌"), ("Charlie", "🚀"), ("David", "🚗"),
    ("Eve", "🍕"), ("Frank", "🎸"), ("Grace", "⚽️"), ("Heidi", "📚"),
    ("Ivan", "💡"), ("Judy", "💻"), ("Kevin", "🎉"), ("Linda", "🎁"),
    ("Mallory", "💎"), ("Nancy", "👑"), ("Oscar", "🌟"), ("Peggy", "🔥"),
    ("Quentin", "🌊"), ("Romeo", "🌍"), ("Sybil", "🌙"), ("Ted", "☀️")
]
user_map = {name: avatar for name, avatar in USER_LIST}

# --- CHANNEL SETUP ---
CHANNELS = ["general", "random", "tech"]

app = Flask(__name__)
logging.info("Flask app initialized.")

@app.route("/healthz")
def healthz():
    """
    Health check endpoint that also checks the database connection.
    """
    logging.info("Health check requested.")
    try:
        with engine.connect() as conn:
            conn.execute(sqlalchemy.text("SELECT 1"))
        logging.info("Health check successful.")
        return {"status": "healthy"}
    except Exception as e:
        logging.error(f"Health check failed: {e}", exc_info=True)
        return {"status": "unhealthy"}, 500

@app.route("/")
def index():
    """
    Renders the main chat page.
    """
    channel = request.args.get("channel", "general")
    username = request.args.get("user")
    logging.info(f"Request for index page: channel='{channel}', user='{username}'.")

    if channel not in CHANNELS:
        logging.warning(f"Invalid channel '{channel}', defaulting to 'general'.")
        channel = "general"

    if not username or username not in user_map:
        username, _ = random.choice(USER_LIST)
        logging.info(f"No user specified or user not found, assigning random user: '{username}'.")
        return redirect(url_for("index", channel=channel, user=username))

    avatar = user_map[username]
    logging.info(f"Fetching messages for user '{username}' in channel '{channel}'.")

    try:
        start_time = time.time()
        with engine.connect() as conn:
            result = conn.execute(
                sqlalchemy.text(
                    "SELECT username, message, avatar FROM messages WHERE channel = :channel ORDER BY timestamp ASC"
                ),
                {"channel": channel},
            )
            messages = result.fetchall()
        duration = time.time() - start_time
        logging.info(f"Loaded {len(messages)} messages for channel '{channel}' in {duration:.2f} seconds.")
    except Exception as e:
        logging.error(f"Failed to fetch messages for channel '{channel}': {e}", exc_info=True)
        messages = []

    logging.info(f"Rendering template for user '{username}' in channel '{channel}'.")
    return render_template(
        "index.html",
        channels=CHANNELS,
        channel=channel,
        messages=messages,
        username=username,
        avatar=avatar,
    )

@app.route("/send", methods=["POST"])
def send():
    """
    Receives a message and inserts it into the database.
    """
    username = request.form["username"]
    message = request.form["message"]
    avatar = request.form["avatar"]
    channel = request.form["channel"]
    logging.info(f"User '{username}' is sending a message to channel '{channel}'.")

    try:
        with engine.connect() as conn:
            conn.execute(
                sqlalchemy.text(
                    "INSERT INTO messages (username, message, avatar, channel) VALUES (:username, :message, :avatar, :channel)"
                ),
                {
                    "username": username,
                    "message": message,
                    "avatar": avatar,
                    "channel": channel,
                },
            )
            conn.commit()
        logging.info(f"Message from '{username}' successfully sent to channel '{channel}'.")
    except Exception as e:
        logging.error(f"Failed to send message for user '{username}' in channel '{channel}': {e}", exc_info=True)

    return redirect(url_for("index", channel=channel, user=username))

if __name__ == "__main__":
    app.run(debug=True)