import { useState, useEffect, useRef } from 'react';
import { MessageCircle, Send, X, Loader2, Volume2, VolumeX } from 'lucide-react';
import VoiceInput from './VoiceInput';
import VoiceOutput, { AutoVoice } from './VoiceOutput';

export default function ChatPanel({ isOpen, onClose }) {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [online, setOnline] = useState(null);
  const [autoSpeak, setAutoSpeak] = useState(true);
  const [lastWasVoice, setLastWasVoice] = useState(false);
  const [isVoiceListening, setIsVoiceListening] = useState(false);
  const messagesEndRef = useRef(null);
  const inputRef = useRef(null);
  const sessionId = useRef(`session_${Date.now()}`);
  const briefingSent = useRef(false);

  useEffect(() => {
    if (isOpen) {
      checkHealth();
      inputRef.current?.focus();
      // Auto-briefing: once per session
      if (!briefingSent.current && !sessionStorage.getItem('hq_briefing_sent')) {
        briefingSent.current = true;
        sessionStorage.setItem('hq_briefing_sent', 'true');
        sendBriefing();
      }
    }
  }, [isOpen]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  async function checkHealth() {
    try {
      const res = await fetch('/api/assistant/health');
      const data = await res.json();
      setOnline(data.online);
    } catch {
      setOnline(false);
    }
  }

  async function sendBriefing() {
    setLoading(true);
    try {
      const res = await fetch('/api/assistant', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: 'Gib mir ein kompaktes Willkommens-Briefing. Maximal 5-8 Zeilen.',
          session_id: sessionId.current,
        }),
      });
      const data = await res.json();
      if (data.response) {
        setMessages([{
          role: 'briefing',
          text: data.response,
          speakText: data.speak_text || null,
        }]);
      }
    } catch {
      // Silent — briefing is optional
    } finally {
      setLoading(false);
    }
  }

  async function sendMessage(text, fromVoice = false) {
    if (!text.trim()) return;

    setLastWasVoice(fromVoice);
    const userMsg = { role: 'user', text: text.trim() };
    setMessages(prev => [...prev, userMsg]);
    setInput('');
    setLoading(true);

    try {
      const res = await fetch('/api/assistant', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: text.trim(),
          session_id: sessionId.current,
        }),
      });

      const data = await res.json();
      const responseText = data.error
        ? (data.hint ? `⚠️ ${data.error}\n\n${data.hint}` : `⚠️ ${data.error}`)
        : (data.response || 'Keine Antwort erhalten.');

      const speakText = data.speak_text || null;
      setMessages(prev => [...prev, { role: 'assistant', text: responseText, speakText }]);
    } catch (err) {
      setMessages(prev => [...prev, {
        role: 'assistant',
        text: '⚠️ Verbindung zum Assistant fehlgeschlagen.\n\nStarte mit:\npython -m factory.hq.assistant.server',
      }]);
    } finally {
      setLoading(false);
    }
  }

  function handleKeyDown(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage(input);
    }
  }

  if (!isOpen) return null;

  return (
    <div className="fixed right-0 top-0 h-full w-[420px] bg-factory-surface border-l border-factory-border flex flex-col z-50 shadow-2xl">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-factory-border">
        <div className="flex items-center gap-2">
          <MessageCircle size={18} className="text-factory-accent" />
          <span className="font-semibold text-factory-text text-sm">Factory Assistant</span>
          {isVoiceListening && <span className="text-factory-error text-xs">🎤</span>}
          <span className={`w-2 h-2 rounded-full ${online ? 'bg-factory-success' : online === false ? 'bg-factory-error' : 'bg-factory-warning'}`} />
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setAutoSpeak(!autoSpeak)}
            className={`p-1 rounded transition-colors ${autoSpeak ? 'text-factory-accent' : 'text-factory-text-secondary hover:text-factory-text'}`}
            title={autoSpeak ? 'Auto-Vorlesen: AN' : 'Auto-Vorlesen: AUS'}
          >
            {autoSpeak ? <Volume2 size={14} /> : <VolumeX size={14} />}
          </button>
          <button onClick={onClose} className="text-factory-text-secondary hover:text-factory-text">
            <X size={18} />
          </button>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {messages.length === 0 && !loading && (
          <div className="text-center text-factory-text-secondary text-sm py-8">
            <p>Frag mich etwas...</p>
            <div className="mt-4 space-y-2">
              {['Was laeuft gerade?', 'Gibt es Probleme?', 'Status MemeRun'].map(q => (
                <button
                  key={q}
                  onClick={() => sendMessage(q)}
                  className="block w-full text-left px-3 py-2 rounded-lg bg-factory-bg text-factory-text-secondary hover:text-factory-accent hover:bg-factory-accent/5 text-xs transition-colors"
                >
                  {q}
                </button>
              ))}
            </div>
          </div>
        )}

        {messages.map((msg, i) => (
          <div key={i} className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}>
            <div className={`max-w-[85%] rounded-xl px-3 py-2 text-sm whitespace-pre-wrap group relative ${
              msg.role === 'user'
                ? 'bg-factory-accent/20 text-factory-accent'
                : msg.role === 'briefing'
                  ? 'bg-factory-accent/5 border border-factory-accent/20 text-factory-text'
                  : 'bg-factory-bg text-factory-text'
            }`}>
              {msg.role === 'briefing' && (
                <div className="text-[10px] text-factory-accent font-medium mb-1 uppercase tracking-wide">Tages-Briefing</div>
              )}
              {msg.text}
              {msg.role !== 'user' && msg.speakText && (
                <div className="mt-1">
                  <VoiceOutput speakText={msg.speakText} />
                </div>
              )}
              {i === messages.length - 1 && msg.role !== 'user' && msg.speakText && (
                <AutoVoice
                  speakText={msg.speakText}
                  enabled={autoSpeak}
                  wasVoiceInput={lastWasVoice}
                />
              )}
            </div>
          </div>
        ))}

        {loading && (
          <div className="flex justify-start">
            <div className="bg-factory-bg rounded-xl px-3 py-2 flex items-center gap-2 text-factory-text-secondary text-sm">
              <Loader2 size={14} className="animate-spin" />
              Denke nach...
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="border-t border-factory-border p-3">
        <div className="flex items-center gap-2">
          <VoiceInput
            disabled={loading}
            onTranscript={(t) => setInput(t)}
            onSend={(t) => sendMessage(t, true)}
          />
          <div className="flex-1 relative">
            <input
              ref={inputRef}
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder={isVoiceListening ? 'Ich hoere zu...' : 'Nachricht... (Ctrl+K)'}
              disabled={loading}
              className="w-full bg-factory-bg border border-factory-border rounded-lg px-3 py-2 pr-10 text-sm text-factory-text placeholder-factory-text-secondary focus:border-factory-accent focus:outline-none disabled:opacity-50"
            />
            <button
              onClick={() => sendMessage(input)}
              disabled={!input.trim() || loading}
              className="absolute right-2 top-1/2 -translate-y-1/2 text-factory-text-secondary hover:text-factory-accent disabled:opacity-30 transition-colors"
            >
              <Send size={16} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
