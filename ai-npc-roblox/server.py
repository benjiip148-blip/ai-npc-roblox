from flask import Flask, request, jsonify
from openai import OpenAI

client = OpenAI(api_key="TU_API_KEY_AQUI")

app = Flask(__name__)

SYSTEM_PROMPT = """
Eres un NPC dentro de un juego de Roblox.
Hablas de forma casual y amigable.
Puedes invitar al jugador a jugar, seguirlo o bromear.
Nunca hables de política, sexo ni temas prohibidos.
"""

@app.route("/chat", methods=["POST"])
def chat():
    data = request.json
    user_text = data["text"]

    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_text}
        ],
        max_tokens=80
    )

    reply = completion.choices[0].message.content
    return jsonify({"reply": reply})

if __name__ == "__main__":
    app.run(port=5000)
