# -*- coding: utf-8 -*-
#
# This file is used to stress test the Streamlit and FastAPI application.
#
# To run this test:
# 1. Make sure you have locust installed (`pip install locust`).
# 2. Run the command below from your terminal in the project root directory.
#
# Example command to run locust:
# locust -f stress/locustfile.py --host http://your-app-url.com --users 100 --spawn-rate 10 --run-time 5m --headless
#
# - http://your-app-url.com: The URL of your deployed application.
# - --users: Total number of concurrent users to simulate.
# - --spawn-rate: Number of users to start per second.
# - --run-time: Duration of the test (e.g., 10m for 10 minutes).
# - --headless: Run without the web UI. Omit this to use the browser interface.
#

import random
from locust import HttpUser, task, between

# --- CONFIGURATION ---

# 1. User Behavior Weights
# Controls the ratio of reading users to writing users.
# For example, a weight of 3 for readers and 1 for writers means for every
# 4 users, 3 will be readers and 1 will be a writer (75% read / 25% write).
READER_WEIGHT = 3
WRITER_WEIGHT = 1

# 2. Test Data
# This data is used by the simulated users to generate realistic traffic.
USER_LIST = [
    ("Alice", "🍎"), ("Bob", "🍌"), ("Charlie", "🚀"), ("David", "🚗"),
    ("Eve", "🍕"), ("Frank", "🎸"), ("Grace", "⚽️"), ("Heidi", "📚"),
    ("Ivan", "💡"), ("Judy", "💻"), ("Kevin", "🎉"), ("Linda", "🎁"),
    ("Mallory", "💎"), ("Nancy", "👑"), ("Oscar", "🌟"), ("Peggy", "🔥"),
    ("Quentin", "🌊"), ("Romeo", "🌍"), ("Sybil", "🌙"), ("Ted", "☀️")
]
CHANNELS = ["general", "random", "tech"]
SAMPLE_MESSAGES = [
    "Hey, how is everyone doing?",
    "Just finished a great book, highly recommend it!",
    "Anyone have plans for the weekend?",
    "I'm trying out a new recipe tonight.",
    "Just saw the funniest video, I'll share the link.",
    "Has anyone seen the latest episode of that new show?",
    "I'm so excited for the concert next month!",
    "Just got back from a run, feeling energized.",
    "I'm working on a new project, it's been a lot of fun.",
    "Just wanted to say hi to everyone!",
]

# --- LOCUST USER CLASSES (No need to edit below this line) ---

class StreamlitReader(HttpUser):
    """
    Simulates a user who is only READING messages by loading the main
    Streamlit application page. This generates read load on the database.
    """
    weight = READER_WEIGHT
    wait_time = between(2, 5)  # Readers are a bit slower

    @task
    def load_main_page(self):
        """
        Loads the root page for a random channel to simulate reading.
        """
        channel = random.choice(CHANNELS)
        # The 'name' parameter groups all these requests under one entry in the UI
        self.client.get(f"/?channel={channel}", name="/?channel=[channel]", verify=False)

class ApiWriter(HttpUser):
    """
    Simulates a user who is only WRITING messages by posting directly
    to the /send_message API endpoint. This generates write load.
    """
    weight = WRITER_WEIGHT
    wait_time = between(1, 3)  # Writers are a bit faster

    @task
    def send_message(self):
        """
        Picks a random user, channel, and message, then sends it to the API.
        """
        username, avatar = random.choice(USER_LIST)
        channel = random.choice(CHANNELS)
        message_text = random.choice(SAMPLE_MESSAGES)

        self.client.post(
            "/send_message",
            json={
                "username": username,
                "message": message_text,
                "avatar": avatar,
                "channel": channel,
            },
            verify=False,
        )
