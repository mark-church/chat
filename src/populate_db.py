import sqlite3
import random
from datetime import datetime, timedelta

# --- SETUP ---
USERS = [
    ("Alice", "🍎"), ("Bob", "🍌"), ("Charlie", "🚀"), ("David", "🚗"),
    ("Eve", "🍕"), ("Frank", "🎸"), ("Grace", "⚽️"), ("Heidi", "📚"),
    ("Ivan", "💡"), ("Judy", "💻"), ("Kevin", "🎉"), ("Linda", "🎁"),
    ("Mallory", "💎"), ("Nancy", "👑"), ("Oscar", "🌟"), ("Peggy", "🔥"),
    ("Quentin", "🌊"), ("Romeo", "🌍"), ("Sybil", "🌙"), ("Ted", "☀️")
]
CHANNELS = ["general", "random", "tech"]

# --- CONVERSATION DATA ---
CONVERSATIONS = {
    "general": [
        ("Alice", "Hey everyone, how's it going?"),
        ("Bob", "Pretty good, Alice! Just grabbing some coffee."),
        ("Charlie", "I'm doing great. Ready for the weekend!"),
        ("Alice", "Same here. Any big plans?"),
        ("Charlie", "Just relaxing, maybe a movie marathon."),
    ],
    "random": [
        ("David", "If you could have any superpower, what would it be?"),
        ("Eve", "Definitely teleportation. Imagine the travel possibilities!"),
        ("Frank", "I'd go with invisibility. Think of the pranks!"),
        ("David", "Haha, classic choice."),
        ("Grace", "I think I'd want to talk to animals."),
        ("Eve", "That's a good one, Grace!"),
    ],
    "tech": [
        ("Heidi", "Has anyone tried the new Python update yet?"),
        ("Ivan", "I have! The performance improvements are noticeable."),
        ("Judy", "I'm planning to upgrade my environment this afternoon."),
        ("Heidi", "Let me know how it goes. I'm curious about the new pattern matching features."),
        ("Ivan", "They're a game-changer for sure. Makes some complex logic so much cleaner."),
        ("Kevin", "Agreed. I've already refactored some old code with it."),
    ]
}

# --- DATABASE POPULATION ---
def populate_db():
    # First, re-initialize the database to create the tables
    import database
    
    conn = sqlite3.connect('chat.db')
    c = conn.cursor()

    start_time = datetime.now() - timedelta(minutes=30)

    for channel, messages in CONVERSATIONS.items():
        for i, (user_name, message_text) in enumerate(messages):
            user_avatar = dict(USERS)[user_name]
            timestamp = start_time + timedelta(minutes=i*2) # Stagger messages
            c.execute(
                "INSERT INTO messages (username, message, avatar, channel, timestamp) VALUES (?, ?, ?, ?, ?)",
                (user_name, message_text, user_avatar, channel, timestamp)
            )
    
    conn.commit()
    conn.close()
    print("Database populated with simulated conversations.")

if __name__ == "__main__":
    populate_db()
