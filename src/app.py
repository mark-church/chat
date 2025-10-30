import random
import time
import logging

import google.cloud.logging
import sqlalchemy
import streamlit as st
from streamlit_autorefresh import st_autorefresh

import database

# --- LOGGING SETUP ---
# Instantiates a client
client = google.cloud.logging.Client()

# Retrieves a Cloud Logging handler based on the environment
# you're running in and integrates the handler with the
# Python logging module. By default this captures all logs
# at INFO level and higher.
client.setup_logging()

# --- DATABASE SETUP ---
engine = database.connect_with_connector()

# --- USER AND AVATAR SETUP ---
USER_LIST = [
    ("Alice", "🍎"), ("Bob", "🍌"), ("Charlie", "🚀"), ("David", "🚗"),
    ("Eve", "🍕"), ("Frank", "🎸"), ("Grace", "⚽️"), ("Heidi", "📚"),
    ("Ivan", "💡"), ("Judy", "💻"), ("Kevin", "🎉"), ("Linda", "🎁"),
    ("Mallory", "💎"), ("Nancy", "👑"), ("Oscar", "🌟"), ("Peggy", "🔥"),
    ("Quentin", "🌊"), ("Romeo", "🌍"), ("Sybil", "🌙"), ("Ted", "☀️")
]
user_map = {name: avatar for name, avatar in USER_LIST}

if 'user_info' not in st.session_state:
    if "user" in st.query_params and st.query_params["user"] in user_map:
        username = st.query_params["user"]
        avatar = user_map[username]
        st.session_state.user_info = (username, avatar)
    else:
        username, avatar = random.choice(USER_LIST)
        st.session_state.user_info = (username, avatar)
        st.query_params["user"] = username

# --- CHANNEL SETUP ---
CHANNELS = ["general", "random", "tech"]
if "channel" not in st.query_params:
    st.query_params["channel"] = "general"
current_channel = st.query_params["channel"]

with st.sidebar:
    st.title("Channels")
    selected_channel = st.selectbox("Select a channel", CHANNELS, index=CHANNELS.index(current_channel))
    if selected_channel != current_channel:
        st.query_params["channel"] = selected_channel
        st.rerun()

# --- CHATROOM ---
st.title(f"#{current_channel}")

st.markdown("""
<style>
    /* --- BASE STYLES (Light Theme) --- */
    /* Chat pane background */
    section.main .block-container {
        background-color: #F8F9FA;
    }
    /* Other users' message bubble */
    div[data-testid="stChatMessage"]:not(:has(div[aria-label="Chat message from user"])) {
        background-color: #FAFAFA;
        border: 1px solid #E0E0E0;
    }
    /* User's message bubble */
    div[data-testid="stChatMessage"]:has(div[aria-label="Chat message from user"]) {
        flex-direction: row-reverse;
        background-color: #F0F0F0;
        border: 1px solid #C0C0C0;
    }
    /* User's message text alignment */
    div[data-testid="stChatMessage"]:has(div[aria-label="Chat message from user"]) div[data-testid="stMarkdownContainer"] p {
        text-align: right;
    }
    /* All message text color for light theme */
    div[data-testid="stMarkdownContainer"] p {
        color: #000000;
    }
    /* Avatar emoji size */
    div[data-testid="stChatMessage"] > div:first-child {
        font-size: 1.5rem;
    }
    /* Username font size */
    div[data-testid="stMarkdownContainer"] p strong {
        font-size: 1.1rem;
    }
    /* Reduce space between name and message */
    div[data-testid="stMarkdownContainer"] p:has(strong) {
        margin-bottom: 0;
    }

    /* --- DARK THEME OVERRIDES --- */
    body.dark section.main .block-container {
        background-color: #262730;
    }
    body.dark div[data-testid="stChatMessage"]:not(:has(div[aria-label="Chat message from user"])) {
        background-color: #31333F;
        border: 1px solid #4A4A4A;
    }
    body.dark div[data-testid="stChatMessage"]:has(div[aria-label="Chat message from user"]) {
        background-color: #083C24;
        border: 1px solid #1A5937;
    }
    body.dark div[data-testid="stMarkdownContainer"] p {
        color: #FFFFFF;
    }
</style>
""", unsafe_allow_html=True)

def show_messages(channel):
    try:
        start_time = time.time()
        with engine.connect() as conn:
            # Fetch all messages in a single query
            result = conn.execute(
                sqlalchemy.text(
                    "SELECT username, message, avatar FROM messages WHERE channel = :channel ORDER BY timestamp ASC"
                ),
                {"channel": channel},
            )
            messages = result.fetchall()

            for username, message, avatar in messages:
                display_name = "user" if username == st.session_state.user_info[0] else username
                with st.chat_message(display_name, avatar=avatar):
                    st.markdown(f"**{username}**")
                    st.write(f"{message}")
        duration = time.time() - start_time
        logging.info(f"Loaded messages for channel '{channel}' in {duration:.2f} seconds.")
    except Exception as e:
        logging.error(f"Failed to fetch messages for channel '{channel}': {e}", exc_info=True)
        st.error("Failed to load messages. Please try again later.")

show_messages(current_channel)

if prompt := st.chat_input("What is up?"):
    username, avatar = st.session_state.user_info
    try:
        with engine.connect() as conn:
            conn.execute(
                sqlalchemy.text(
                    "INSERT INTO messages (username, message, avatar, channel) VALUES (:username, :message, :avatar, :channel)"
                ),
                {
                    "username": username,
                    "message": prompt,
                    "avatar": avatar,
                    "channel": current_channel,
                },
            )
            conn.commit()
        st.rerun()
    except Exception as e:
        logging.error(f"Failed to send message for user '{username}' in channel '{current_channel}': {e}", exc_info=True)
        st.error("Failed to send message. Please check your connection and try again.")

st_autorefresh(interval=5000, limit=None)
