"""
DriveAI Mac Factory — File Logger

Tees stdout/stderr to log files.
- server.log: append mode, all server output
- builds/<project>_<timestamp>.log: per-build log
"""

import os
import sys
from pathlib import Path
from datetime import datetime, timezone


class TeeWriter:
    """Writes to multiple streams simultaneously."""
    def __init__(self, *streams):
        self.streams = list(streams)

    def write(self, data):
        for s in self.streams:
            try:
                s.write(data)
                s.flush()
            except Exception:
                pass

    def flush(self):
        for s in self.streams:
            try:
                s.flush()
            except Exception:
                pass

    def add(self, stream):
        if stream not in self.streams:
            self.streams.append(stream)

    def remove(self, stream):
        if stream in self.streams:
            self.streams.remove(stream)


class FileLogger:
    def __init__(self, log_dir: str = None):
        self.log_dir = Path(log_dir) if log_dir else Path(__file__).parent / "logs"
        self.log_dir.mkdir(parents=True, exist_ok=True)
        (self.log_dir / "builds").mkdir(parents=True, exist_ok=True)

        self.original_stdout = sys.stdout
        self.original_stderr = sys.stderr

        self.server_log = None
        self.build_log = None
        self.tee_stdout = None
        self.tee_stderr = None

    def start_server_log(self):
        """Tees stdout/stderr to logs/server.log (append)."""
        try:
            log_path = self.log_dir / "server.log"
            self.server_log = open(log_path, "a", buffering=1, encoding="utf-8")

            self.tee_stdout = TeeWriter(self.original_stdout, self.server_log)
            self.tee_stderr = TeeWriter(self.original_stderr, self.server_log)
            sys.stdout = self.tee_stdout
            sys.stderr = self.tee_stderr

            ts = datetime.now(timezone.utc).isoformat()
            self.server_log.write(f"\n=== [Logger] Server log started: {ts} ===\n")
            self.server_log.flush()
            print(f"[Logger] Server log: {log_path}")
        except Exception as e:
            print(f"[Logger] start_server_log failed: {e}")

    def start_build_log(self, project_name: str):
        """Adds an additional build-specific log file to the tee."""
        try:
            ts = int(datetime.now(timezone.utc).timestamp())
            safe_name = project_name.replace("/", "_").replace(" ", "_")
            log_path = self.log_dir / "builds" / f"{safe_name}_{ts}.log"
            self.build_log = open(log_path, "w", buffering=1, encoding="utf-8")

            ts_iso = datetime.now(timezone.utc).isoformat()
            self.build_log.write(f"=== Build log: {project_name} @ {ts_iso} ===\n")
            self.build_log.flush()

            if self.tee_stdout:
                self.tee_stdout.add(self.build_log)
            if self.tee_stderr:
                self.tee_stderr.add(self.build_log)

            print(f"[Logger] Build log: {log_path.name}")
            return str(log_path)
        except Exception as e:
            print(f"[Logger] start_build_log failed: {e}")
            return ""

    def end_build_log(self):
        """Closes the current build log."""
        if self.build_log:
            try:
                ts = datetime.now(timezone.utc).isoformat()
                self.build_log.write(f"\n=== Build log ended: {ts} ===\n")

                if self.tee_stdout:
                    self.tee_stdout.remove(self.build_log)
                if self.tee_stderr:
                    self.tee_stderr.remove(self.build_log)

                self.build_log.close()
                print(f"[Logger] Build log closed")
            except Exception as e:
                print(f"[Logger] end_build_log failed: {e}")
            finally:
                self.build_log = None

    def stop(self):
        """Restores original stdout/stderr."""
        try:
            sys.stdout = self.original_stdout
            sys.stderr = self.original_stderr
            if self.server_log:
                self.server_log.close()
                self.server_log = None
        except Exception:
            pass


# Global instance for the agent.py server
_logger_instance = None


def get_logger() -> FileLogger:
    global _logger_instance
    if _logger_instance is None:
        _logger_instance = FileLogger()
    return _logger_instance
