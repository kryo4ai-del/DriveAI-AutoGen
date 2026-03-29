"""YouTube Data API v3 Adapter.

Alle Operationen sind default Dry-Run. Kein realer Upload ohne explizites dry_run=False.
"""

import json
import logging
import os
from datetime import datetime

logger = logging.getLogger("factory.marketing.adapters.youtube")


class YouTubeAdapter:
    """YouTube Data API v3 Adapter fuer Video-Upload und Metadata.

    Default: Dry-Run-Modus. Loggt was passieren wuerde, fuehrt nichts aus.
    Auch mit Credentials ist dry_run=True der Default.
    """

    STATUS = "active"
    PLATFORM = "youtube"

    def __init__(self, dry_run: bool = True):
        self.credentials_path = os.getenv("YOUTUBE_CREDENTIALS_PATH")
        self._force_dry_run = self.credentials_path is None
        self.dry_run = True if self._force_dry_run else dry_run
        self._service = None

        if self._force_dry_run:
            logger.info("YouTube Adapter: No credentials — DRY RUN enforced")
        elif self.dry_run:
            logger.info("YouTube Adapter: Credentials found but DRY RUN active")
        else:
            logger.warning("YouTube Adapter: LIVE MODE — uploads will be real!")

    def _get_service(self):
        """Lazy-init der YouTube API Service Instanz."""
        if self._service:
            return self._service
        if self._force_dry_run:
            return None
        try:
            from google.auth.transport.requests import Request
            from google_auth_oauthlib.flow import InstalledAppFlow
            from googleapiclient.discovery import build
            import pickle

            SCOPES = [
                "https://www.googleapis.com/auth/youtube.upload",
                "https://www.googleapis.com/auth/youtube",
                "https://www.googleapis.com/auth/youtube.readonly",
            ]

            creds = None
            token_path = self.credentials_path.replace(".json", "_token.pickle")

            if os.path.exists(token_path):
                with open(token_path, "rb") as token:
                    creds = pickle.load(token)

            if not creds or not creds.valid:
                if creds and creds.expired and creds.refresh_token:
                    creds.refresh(Request())
                else:
                    flow = InstalledAppFlow.from_client_secrets_file(
                        self.credentials_path, SCOPES
                    )
                    creds = flow.run_local_server(port=0)
                with open(token_path, "wb") as token:
                    pickle.dump(creds, token)

            self._service = build("youtube", "v3", credentials=creds)
            return self._service
        except Exception as e:
            logger.error(f"YouTube API init failed: {e}")
            self._force_dry_run = True
            self.dry_run = True
            return None

    def _dry_run_log(self, method: str, **kwargs) -> dict:
        """Loggt einen Dry-Run-Aufruf und gibt ein Fake-Result zurueck."""
        logger.info(f"[DRY RUN] YouTube.{method}({kwargs})")
        return {
            "dry_run": True,
            "method": method,
            "params": {k: str(v)[:100] for k, v in kwargs.items()},
            "timestamp": datetime.now().isoformat(),
            "fake_id": f"dry_run_{method}_{datetime.now().strftime('%Y%m%d%H%M%S')}",
        }

    def upload_video(
        self,
        video_path: str,
        title: str,
        description: str,
        tags: list[str] = None,
        category_id: int = 28,
        privacy: str = "private",
    ) -> dict:
        """Laedt ein Video hoch. Default privacy=private."""
        if not os.path.exists(video_path):
            logger.error(f"Video file not found: {video_path}")
            return {"error": "file_not_found", "path": video_path}

        if self.dry_run:
            return self._dry_run_log(
                "upload_video",
                video_path=video_path,
                title=title,
                description=description[:50],
                tags=tags,
                category_id=category_id,
                privacy=privacy,
            )

        service = self._get_service()
        if not service:
            return {"error": "no_service"}

        try:
            from googleapiclient.http import MediaFileUpload

            body = {
                "snippet": {
                    "title": title[:100],
                    "description": description[:5000],
                    "tags": tags or [],
                    "categoryId": str(category_id),
                },
                "status": {
                    "privacyStatus": privacy,
                    "selfDeclaredMadeForKids": False,
                },
            }

            media = MediaFileUpload(video_path, resumable=True)
            request = service.videos().insert(
                part="snippet,status", body=body, media_body=media
            )
            response = request.execute()

            logger.info(f"YouTube upload success: {response['id']}")
            return {
                "video_id": response["id"],
                "privacy": privacy,
                "dry_run": False,
            }
        except Exception as e:
            logger.error(f"YouTube upload failed: {e}")
            return {"error": str(e)}

    def set_thumbnail(self, video_id: str, thumbnail_path: str) -> dict:
        """Setzt Custom Thumbnail."""
        if self.dry_run:
            return self._dry_run_log(
                "set_thumbnail", video_id=video_id, thumbnail_path=thumbnail_path
            )
        return {"error": "not_implemented_for_live"}

    def update_metadata(
        self,
        video_id: str,
        title: str = None,
        description: str = None,
        tags: list[str] = None,
    ) -> dict:
        """Aktualisiert Video-Metadata."""
        if self.dry_run:
            return self._dry_run_log(
                "update_metadata",
                video_id=video_id,
                title=title,
                description=description,
            )
        return {"error": "not_implemented_for_live"}

    def get_video_analytics(self, video_id: str) -> dict:
        """Ruft Analytics ab (Views, Watch Time, Likes, Comments)."""
        if self.dry_run:
            return self._dry_run_log("get_video_analytics", video_id=video_id)
        return {"error": "not_implemented_for_live"}

    def get_channel_stats(self) -> dict:
        """Subscriber Count, Total Views, Video Count."""
        if self.dry_run:
            return self._dry_run_log("get_channel_stats")
        return {"error": "not_implemented_for_live"}
