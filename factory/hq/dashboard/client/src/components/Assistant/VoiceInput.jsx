import { useState, useEffect, useRef } from 'react';
import { Mic, MicOff } from 'lucide-react';

const SpeechRecognition = typeof window !== 'undefined'
  ? (window.SpeechRecognition || window.webkitSpeechRecognition)
  : null;

export default function VoiceInput({ onTranscript, onSend, disabled }) {
  const [isListening, setIsListening] = useState(false);
  const [isSupported] = useState(!!SpeechRecognition);
  const [error, setError] = useState(null);
  const [showPrivacy, setShowPrivacy] = useState(false);
  const recognitionRef = useRef(null);
  const silenceTimer = useRef(null);
  const hasShownPrivacy = useRef(false);

  useEffect(() => {
    return () => {
      if (recognitionRef.current) {
        recognitionRef.current.abort();
      }
      if (silenceTimer.current) {
        clearTimeout(silenceTimer.current);
      }
    };
  }, []);

  function startListening() {
    if (!isSupported || disabled) return;

    // Show privacy notice on first use
    if (!hasShownPrivacy.current) {
      setShowPrivacy(true);
      hasShownPrivacy.current = true;
      setTimeout(() => setShowPrivacy(false), 5000);
    }

    setError(null);
    const recognition = new SpeechRecognition();
    recognition.lang = 'de-DE';
    recognition.continuous = false;
    recognition.interimResults = true;
    recognition.maxAlternatives = 1;
    recognitionRef.current = recognition;

    recognition.onstart = () => setIsListening(true);

    recognition.onresult = (event) => {
      const result = event.results[event.results.length - 1];
      const text = result[0].transcript;

      if (onTranscript) onTranscript(text);

      // Reset silence timer
      if (silenceTimer.current) clearTimeout(silenceTimer.current);

      if (result.isFinal) {
        // Final result — send after short delay
        silenceTimer.current = setTimeout(() => {
          if (text.trim()) {
            onSend(text.trim());
          }
          setIsListening(false);
        }, 500);
      } else {
        // Interim — set silence timeout
        silenceTimer.current = setTimeout(() => {
          recognition.stop();
        }, 2000);
      }
    };

    recognition.onerror = (event) => {
      switch (event.error) {
        case 'not-allowed':
          setError('Mikrofon-Zugriff verweigert');
          break;
        case 'no-speech':
          break; // Silent stop
        case 'network':
          setError('Netzwerk-Fehler');
          break;
        default:
          setError(`Fehler: ${event.error}`);
      }
      setIsListening(false);
    };

    recognition.onend = () => {
      setIsListening(false);
      recognitionRef.current = null;
    };

    try {
      recognition.start();
    } catch (e) {
      setError('Start fehlgeschlagen');
      setIsListening(false);
    }
  }

  function stopListening() {
    if (recognitionRef.current) {
      recognitionRef.current.stop();
    }
    if (silenceTimer.current) {
      clearTimeout(silenceTimer.current);
    }
    setIsListening(false);
  }

  function toggle() {
    if (isListening) {
      stopListening();
    } else {
      startListening();
    }
  }

  if (!isSupported) {
    return (
      <button disabled className="text-factory-text-secondary opacity-30 cursor-not-allowed" title="Browser unterstuetzt keine Spracheingabe">
        <MicOff size={18} />
      </button>
    );
  }

  return (
    <div className="relative">
      <button
        onClick={toggle}
        disabled={disabled}
        title={isListening ? 'Stopp (Ctrl+M)' : 'Spracheingabe (Ctrl+M)'}
        className={`transition-all ${
          isListening
            ? 'text-factory-error animate-pulse'
            : 'text-factory-text-secondary hover:text-factory-accent'
        } ${disabled ? 'opacity-30 cursor-not-allowed' : ''}`}
      >
        {isListening ? (
          <div className="relative">
            <Mic size={18} />
            {/* Pulse rings */}
            <span className="absolute -inset-1 rounded-full bg-factory-error/20 animate-ping" />
          </div>
        ) : (
          <Mic size={18} />
        )}
      </button>

      {/* Wave animation when listening */}
      {isListening && (
        <div className="absolute -top-6 left-1/2 -translate-x-1/2 flex items-end gap-0.5 h-4">
          {[1, 2, 3].map(i => (
            <div
              key={i}
              className="w-0.5 bg-factory-error rounded-full"
              style={{
                animation: `wave 0.6s ease-in-out ${i * 0.1}s infinite alternate`,
                height: '4px',
              }}
            />
          ))}
        </div>
      )}

      {/* Privacy notice */}
      {showPrivacy && (
        <div className="absolute bottom-full right-0 mb-2 w-64 p-2 bg-factory-bg border border-factory-border rounded-lg text-[10px] text-factory-text-secondary z-10">
          Spracheingabe nutzt die Browser-Spracherkennung. Audio wird nicht von DriveAI gespeichert.
        </div>
      )}

      {/* Error */}
      {error && (
        <div className="absolute bottom-full right-0 mb-2 p-2 bg-factory-error/20 border border-factory-error/30 rounded-lg text-[10px] text-factory-error z-10 whitespace-nowrap">
          {error}
        </div>
      )}

      <style>{`
        @keyframes wave {
          from { height: 4px; }
          to { height: 14px; }
        }
      `}</style>
    </div>
  );
}
