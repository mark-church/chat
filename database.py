import sqlite3

conn = sqlite3.connect('chat.db')
c = conn.cursor()

c.execute("""
    CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        message TEXT,
        avatar TEXT,
        channel TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
""")

c.execute("""
    CREATE TABLE IF NOT EXISTS schema_version (
        version INTEGER
    )
""")

c.execute("INSERT INTO schema_version (version) VALUES (2)")

conn.commit()
conn.close()