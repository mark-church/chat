import streamlit as st
import sqlite3
import random
import os
import subprocess
from streamlit_autorefresh import st_autorefresh

# --- SCHEMA VERSION ---
CURRENT_SCHEMA_VERSION = 2

# --- DATABASE SETUP ---
def initialize_database():
    """
    Checks if the database schema is up to date. If not, it deletes the
    database file and recreates it.
    """
    conn = sqlite3.connect('chat.db')
    c = conn.cursor()
    recreate_db = False
    try:
        # Check for schema version table and version number
        c.execute("SELECT version FROM schema_version")
        version = c.fetchone()[0]
        if version != CURRENT_SCHEMA_VERSION:
            recreate_db = True

        # Check for channel column in messages table
        c.execute("PRAGMA table_info(messages)")
        columns = [info[1] for info in c.fetchall()]
        if 'channel' not in columns:
            recreate_db = True

    except (sqlite3.OperationalError, TypeError):
        recreate_db = True

    conn.close()

    if recreate_db:
        if os.path.exists('chat.db'):
            os.remove('chat.db')
        subprocess.run(["python", "database.py"])

initialize_database()
conn = sqlite3.connect('chat.db')
c = conn.cursor()

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
    c.execute("SELECT username, message, avatar FROM messages WHERE channel = ? ORDER BY timestamp ASC", (channel,))
    messages = c.fetchall()
    for username, message, avatar in messages:
        display_name = "user" if username == st.session_state.user_info[0] else username
        with st.chat_message(display_name, avatar=avatar):
            st.markdown(f"**{username}**")
            st.write(f"{message}")

show_messages(current_channel)

if prompt := st.chat_input("What is up?"):
    username, avatar = st.session_state.user_info
    c.execute("INSERT INTO messages (username, message, avatar, channel) VALUES (?, ?, ?, ?)", (username, prompt, avatar, current_channel))
    conn.commit()
    st.rerun()

st_autorefresh(interval=5000, limit=None)