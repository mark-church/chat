import streamlit as st
import sqlite3
import random

# --- DATABASE SETUP ---
conn = sqlite3.connect('chat.db')
c = conn.cursor()

# --- USER AND AVATAR SETUP ---
USER_LIST = [
    ("Alice", "😊"), ("Bob", "😎"), ("Charlie", "😂"), ("David", "😜"),
    ("Eve", "😍"), ("Frank", "🥳"), ("Grace", "🤩"), ("Heidi", "🤯"),
    ("Ivan", "🤗"), ("Judy", "😇"), ("Kevin", "🤪"), ("Linda", "🥰"),
    ("Mallory", "🤫"), ("Nancy", "🤔"), ("Oscar", "🤠"), ("Peggy", "🤡"),
    ("Quentin", "🤓"), ("Romeo", "😴"), ("Sybil", "🥺"), ("Ted", "🤖")
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

# --- CHATROOM ---
st.title("Multi-user Chat App")

def show_messages():
    c.execute("SELECT username, message, avatar FROM messages ORDER BY timestamp ASC")
    messages = c.fetchall()
    for username, message, avatar in messages:
        display_name = "user" if username == st.session_state.user_info[0] else username
        with st.chat_message(display_name, avatar=avatar):
            st.markdown(f"**{username}**")
            st.write(f"{message}")

show_messages()

if prompt := st.chat_input("What is up?"):
    username, avatar = st.session_state.user_info
    c.execute("INSERT INTO messages (username, message, avatar) VALUES (?, ?, ?)", (username, prompt, avatar))
    conn.commit()
    st.rerun()