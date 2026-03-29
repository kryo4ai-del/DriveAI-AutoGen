"""Factory HQ Assistant — FastAPI server on port 3002.

Exposes the chat() function as HTTP endpoint for the Dashboard.
"""

import sys
import os

# Ensure factory is importable
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", ".."))

from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import base64
import requests

from pydantic import BaseModel
from config.model_router import get_fallback_model
from typing import Optional

app = FastAPI(title="DriveAI Factory HQ Assistant")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

# Session-based history (in-memory)
sessions: dict = {}

# ElevenLabs config
ELEVENLABS_API_KEY = os.environ.get("ELEVENLABS_API_KEY", "")
ELEVENLABS_VOICE_ID = os.environ.get("ELEVENLABS_VOICE_ID", "")
ELEVENLABS_MODEL = "eleven_multilingual_v2"
SPEAK_MAX_CHARS = 300


class ChatRequest(BaseModel):
    message: str
    session_id: str = "default"


class ChatResponse(BaseModel):
    response: str
    session_id: str
    speak_text: Optional[str] = None


class SpeakRequest(BaseModel):
    text: str
    voice_id: Optional[str] = None


class SpeakResponse(BaseModel):
    audio_base64: str
    duration_estimate: float
    characters_used: int


@app.get("/health")
def health():
    voice_ok = bool(ELEVENLABS_API_KEY and ELEVENLABS_VOICE_ID)
    return {"status": "ok", "model": get_fallback_model(), "voice_enabled": voice_ok}


@app.post("/chat", response_model=ChatResponse)
def chat_endpoint(req: ChatRequest):
    from factory.hq.assistant.assistant import chat, extract_speak_text

    history = sessions.get(req.session_id, [])
    response_text, updated_history = chat(req.message, history)
    sessions[req.session_id] = updated_history

    clean_response, speak_text = extract_speak_text(response_text)

    return ChatResponse(
        response=clean_response,
        session_id=req.session_id,
        speak_text=speak_text,
    )


@app.post("/speak")
def speak_endpoint(req: SpeakRequest):
    """Convert short text to ElevenLabs audio (base64 mp3)."""
    if len(req.text) > SPEAK_MAX_CHARS:
        return {"error": f"Text zu lang (max {SPEAK_MAX_CHARS} Zeichen). Wird nur als Text angezeigt."}

    if not ELEVENLABS_API_KEY:
        return {"error": "ElevenLabs API-Key nicht konfiguriert."}

    voice_id = req.voice_id or ELEVENLABS_VOICE_ID
    if not voice_id:
        return {"error": "Keine Voice-ID konfiguriert. Bitte ELEVENLABS_VOICE_ID in .env setzen."}

    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
    headers = {
        "xi-api-key": ELEVENLABS_API_KEY,
        "Content-Type": "application/json",
    }
    payload = {
        "text": req.text,
        "model_id": ELEVENLABS_MODEL,
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75,
            "style": 0.3,
            "use_speaker_boost": True,
        },
    }

    try:
        resp = requests.post(url, json=payload, headers=headers, timeout=15)
        resp.raise_for_status()

        audio_b64 = base64.b64encode(resp.content).decode("utf-8")

        # Track character usage (non-blocking)
        try:
            from factory.hq.providers.balance_monitor import add_tracked_usage
            add_tracked_usage("elevenlabs", len(req.text), agent="hq_assistant")
        except Exception:
            pass

        return SpeakResponse(
            audio_base64=audio_b64,
            duration_estimate=len(req.text) / 15.0,
            characters_used=len(req.text),
        )
    except requests.exceptions.HTTPError as e:
        return {"error": f"ElevenLabs HTTP {e.response.status_code}: {e.response.text[:200]}"}
    except Exception as e:
        return {"error": f"ElevenLabs Fehler: {str(e)}"}


@app.post("/reset")
def reset_session(session_id: str = "default"):
    history = sessions.get(session_id, [])
    memory_updated = False
    if history:
        try:
            from factory.hq.assistant.assistant import _update_memory, _load_memory, _save_memory
            _update_memory(history)
            # Increment session counter
            mem = _load_memory()
            mem["sessions_count"] = mem.get("sessions_count", 0) + 1
            _save_memory(mem)
            memory_updated = True
        except Exception:
            pass
    sessions.pop(session_id, None)
    return {"status": "reset", "session_id": session_id, "memory_updated": memory_updated}


if __name__ == "__main__":
    import uvicorn
    print("=" * 50)
    print("  Factory HQ Assistant Server")
    print("  Port: 3002")
    print("=" * 50)
    uvicorn.run(app, host="127.0.0.1", port=3002, log_level="info")
