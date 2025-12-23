from flask import Flask, request, jsonify
from openai import OpenAI
import json
import os

# =====================
# CONFIG
# =====================
MEMORY_FILE = "memory.json"
MAX_MEMORY = 10

# =====================
# MEMORIA
# =====================
def load_memory():
    if os.path.exists(MEMORY_FILE):
        with open(MEMORY_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}

def save_memory(mem):
    with open(MEMORY_FILE, "w", encoding="utf-8") as f:
        json.dump(mem, f, ensure_ascii=False, indent=2)

memory = load_memory()

# =====================
# OPENAI
# =====================
client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY")  # 🔒 desde Render
)

# =====================
# FLASK
# =====================
app = Flask(__name__)

SYSTEM_PROMPT = """
Eres un NPC dentro de un juego de Roblox.
Tu nombre es Alex.
Hablas casual, corto y amigable.
Recuerdas a los jugadores.
Si el jugador dice "sígueme", responde con la palabra "sígueme".
Nunca hables de política, sexo ni temas prohibidos.
"""

@app.route("/chat", methods=["POST"])
def chat():
    data = request.json

    user_id = data.get("user", "unknown")
    user_text = data.get("text", "")

    # inicializar memoria del jugador
    if user_id not in memory:
        memory[user_id] = []

    history = memory[user_id]

    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        *history,
        {"role": "user", "content": user_text}
    ]

    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=messages,
        max_tokens=80
    )

    reply = completion.choices[0].message.content

    # guardar memoria
    history.append({"role": "user", "content": user_text})
    history.append({"role": "assistant", "content": reply})
    memory[user_id] = history[-MAX_MEMORY:]

    save_memory(memory)

    return jsonify({"reply": reply})

# =====================
# START SERVER (RENDER)
# =====================
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
