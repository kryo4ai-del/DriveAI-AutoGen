import { useState, useEffect, useRef } from 'react';
import { Volume2, VolumeX, Loader2 } from 'lucide-react';

/**
 * ElevenLabs Voice Output — plays speak_text via /api/assistant/speak.
 * Falls back to browser SpeechSynthesis if ElevenLabs fails.
 */
export default function VoiceOutput({ speakText }) {
  const [isSpeaking, setIsSpeaking] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const audioRef = useRef(null);

  function stop() {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current.currentTime = 0;
      audioRef.current = null;
    }
    window.speechSynthesis?.cancel();
    setIsSpeaking(false);
    setIsLoading(false);
  }

  async function play() {
    if (!speakText) return;
    stop();
    setIsLoading(true);

    try {
      const res = await fetch('/api/assistant/speak', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text: speakText }),
      });
      const data = await res.json();

      if (data.audio_base64) {
        const blob = base64ToBlob(data.audio_base64, 'audio/mpeg');
        const url = URL.createObjectURL(blob);
        const audio = new Audio(url);
        audioRef.current = audio;

        audio.onplay = () => { setIsLoading(false); setIsSpeaking(true); };
        audio.onended = () => { setIsSpeaking(false); URL.revokeObjectURL(url); audioRef.current = null; };
        audio.onerror = () => { setIsSpeaking(false); setIsLoading(false); URL.revokeObjectURL(url); fallbackSpeak(speakText); };

        audio.play();
      } else {
        // ElevenLabs error — fallback
        setIsLoading(false);
        fallbackSpeak(speakText);
      }
    } catch {
      setIsLoading(false);
      fallbackSpeak(speakText);
    }
  }

  function fallbackSpeak(text) {
    if (!window.speechSynthesis) return;
    const utterance = new SpeechSynthesisUtterance(text);
    const voices = window.speechSynthesis.getVoices();
    const deVoice = voices.find(v => v.lang.startsWith('de'));
    if (deVoice) utterance.voice = deVoice;
    utterance.lang = 'de-DE';
    utterance.rate = 1.1;
    utterance.onstart = () => setIsSpeaking(true);
    utterance.onend = () => setIsSpeaking(false);
    utterance.onerror = () => setIsSpeaking(false);
    window.speechSynthesis.speak(utterance);
  }

  if (!speakText) return null;

  return (
    <button
      onClick={() => isSpeaking || isLoading ? stop() : play()}
      className={`inline-flex items-center gap-1 text-[10px] transition-colors ${
        isSpeaking
          ? 'text-factory-accent'
          : isLoading
            ? 'text-factory-warning'
            : 'text-factory-text-secondary hover:text-factory-accent opacity-0 group-hover:opacity-100'
      }`}
      title={isSpeaking ? 'Stopp' : isLoading ? 'Laden...' : 'Vorlesen'}
    >
      {isLoading ? <Loader2 size={12} className="animate-spin" /> : isSpeaking ? <VolumeX size={12} /> : <Volume2 size={12} />}
    </button>
  );
}

/**
 * AutoVoice — automatically plays speak_text for new messages.
 */
export function AutoVoice({ speakText, enabled, wasVoiceInput }) {
  const spokenRef = useRef(new Set());

  useEffect(() => {
    if (!enabled && !wasVoiceInput) return;
    if (!speakText) return;
    if (spokenRef.current.has(speakText)) return;

    spokenRef.current.add(speakText);
    playAuto(speakText);
  }, [speakText, enabled, wasVoiceInput]);

  return null;
}

async function playAuto(text) {
  try {
    const res = await fetch('/api/assistant/speak', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text }),
    });
    const data = await res.json();

    if (data.audio_base64) {
      const blob = base64ToBlob(data.audio_base64, 'audio/mpeg');
      const url = URL.createObjectURL(blob);
      const audio = new Audio(url);
      audio.onended = () => URL.revokeObjectURL(url);
      audio.onerror = () => { URL.revokeObjectURL(url); fallbackSpeakSimple(text); };
      audio.play();
    } else {
      fallbackSpeakSimple(text);
    }
  } catch {
    fallbackSpeakSimple(text);
  }
}

function fallbackSpeakSimple(text) {
  if (!window.speechSynthesis) return;
  const utterance = new SpeechSynthesisUtterance(text);
  const voices = window.speechSynthesis.getVoices();
  const deVoice = voices.find(v => v.lang.startsWith('de'));
  if (deVoice) utterance.voice = deVoice;
  utterance.lang = 'de-DE';
  utterance.rate = 1.1;
  window.speechSynthesis.speak(utterance);
}

function base64ToBlob(b64, mime) {
  const bytes = atob(b64);
  const arr = new Uint8Array(bytes.length);
  for (let i = 0; i < bytes.length; i++) arr[i] = bytes.charCodeAt(i);
  return new Blob([arr], { type: mime });
}
