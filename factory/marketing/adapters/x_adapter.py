"""X (Twitter) API v2 Adapter.

Alle Operationen default Dry-Run.
"""

import logging
import os
from datetime import datetime

logger = logging.getLogger("factory.marketing.adapters.x")


class XAdapter:
    """X (Twitter) API v2 Adapter fuer Tweets, Threads und Polls.

    Default: Dry-Run-Modus. Kein realer Post ohne explizites dry_run=False.
    """

    STATUS = "active"
    PLATFORM = "x"
    MAX_TWEET_LENGTH = 280

    def __init__(self, dry_run: bool = True):
        self._api_key = os.getenv("X_API_KEY")
        self._api_secret = os.getenv("X_API_SECRET")
        self._access_token = os.getenv("X_ACCESS_TOKEN")
        self._access_token_secret = os.getenv("X_ACCESS_TOKEN_SECRET")

        has_all = all([self._api_key, self._api_secret,
                       self._access_token, self._access_token_secret])
        self._force_dry_run = not has_all
        self.dry_run = True if self._force_dry_run else dry_run
        self._client = None
        self._api_v1 = None

        if self._force_dry_run:
            logger.info("X Adapter: Missing credentials — DRY RUN enforced")
        elif self.dry_run:
            logger.info("X Adapter: Credentials found but DRY RUN active")
        else:
            logger.warning("X Adapter: LIVE MODE — tweets will be real!")

    def _get_client(self):
        """Lazy-init tweepy v2 Client."""
        if self._client:
            return self._client
        if self._force_dry_run:
            return None
        try:
            import tweepy

            self._client = tweepy.Client(
                consumer_key=self._api_key,
                consumer_secret=self._api_secret,
                access_token=self._access_token,
                access_token_secret=self._access_token_secret,
            )
            return self._client
        except Exception as e:
            logger.error(f"X API init failed: {e}")
            self._force_dry_run = True
            self.dry_run = True
            return None

    def _get_api_v1(self):
        """Lazy-init tweepy v1.1 API (fuer Media Upload)."""
        if self._api_v1:
            return self._api_v1
        if self._force_dry_run:
            return None
        try:
            import tweepy

            auth = tweepy.OAuth1UserHandler(
                self._api_key, self._api_secret,
                self._access_token, self._access_token_secret,
            )
            self._api_v1 = tweepy.API(auth)
            return self._api_v1
        except Exception as e:
            logger.error(f"X API v1 init failed: {e}")
            return None

    def _dry_run_log(self, method: str, **kwargs) -> dict:
        logger.info(f"[DRY RUN] X.{method}({kwargs})")
        return {
            "dry_run": True,
            "method": method,
            "params": {k: str(v)[:100] for k, v in kwargs.items()},
            "timestamp": datetime.now().isoformat(),
            "fake_id": f"dry_run_{method}_{datetime.now().strftime('%Y%m%d%H%M%S')}",
        }

    def post_tweet(self, text: str, media_paths: list[str] = None) -> dict:
        """Postet einen Tweet.

        Args:
            text: Tweet-Text (max 280 Zeichen)
            media_paths: Optionale Liste von Media-Pfaden
        """
        if len(text) > self.MAX_TWEET_LENGTH:
            return {
                "error": "text_too_long",
                "length": len(text),
                "max": self.MAX_TWEET_LENGTH,
            }

        if self.dry_run:
            return self._dry_run_log(
                "post_tweet", text=text, media_paths=media_paths
            )

        client = self._get_client()
        if not client:
            return {"error": "no_client"}

        try:
            media_ids = []
            if media_paths:
                api_v1 = self._get_api_v1()
                if api_v1:
                    for path in media_paths:
                        if os.path.exists(path):
                            media = api_v1.media_upload(path)
                            media_ids.append(media.media_id)

            kwargs = {"text": text}
            if media_ids:
                kwargs["media_ids"] = media_ids

            response = client.create_tweet(**kwargs)
            tweet_id = response.data["id"]
            logger.info(f"Tweet posted: {tweet_id}")
            return {"tweet_id": tweet_id, "dry_run": False}

        except Exception as e:
            logger.error(f"Tweet failed: {e}")
            return {"error": str(e)}

    def post_thread(self, tweets_list: list[dict]) -> list[dict]:
        """Postet einen Thread (sequentielle Reply-Chain).

        Args:
            tweets_list: [{"text": str, "media_paths": list|None}, ...]
        """
        if self.dry_run:
            results = []
            for i, tweet in enumerate(tweets_list):
                result = self._dry_run_log(
                    "post_thread",
                    thread_index=i,
                    total=len(tweets_list),
                    text=tweet.get("text", ""),
                    reply_to=f"thread_part_{i - 1}" if i > 0 else None,
                )
                results.append(result)
            return results

        client = self._get_client()
        if not client:
            return [{"error": "no_client"}]

        results = []
        reply_to_id = None

        for i, tweet in enumerate(tweets_list):
            text = tweet.get("text", "")
            if len(text) > self.MAX_TWEET_LENGTH:
                results.append({
                    "error": "text_too_long",
                    "thread_index": i,
                    "length": len(text),
                })
                break

            try:
                kwargs = {"text": text}
                if reply_to_id:
                    kwargs["in_reply_to_tweet_id"] = reply_to_id

                media_ids = []
                media_paths = tweet.get("media_paths")
                if media_paths:
                    api_v1 = self._get_api_v1()
                    if api_v1:
                        for path in media_paths:
                            if os.path.exists(path):
                                media = api_v1.media_upload(path)
                                media_ids.append(media.media_id)
                if media_ids:
                    kwargs["media_ids"] = media_ids

                response = client.create_tweet(**kwargs)
                reply_to_id = response.data["id"]
                results.append({"tweet_id": reply_to_id, "thread_index": i, "dry_run": False})

            except Exception as e:
                results.append({"error": str(e), "thread_index": i})
                break

        return results

    def create_poll(
        self, text: str, options: list[str], duration_minutes: int = 1440
    ) -> dict:
        """Erstellt einen Tweet mit Poll.

        Args:
            text: Tweet-Text
            options: 2-4 Optionen, je max 25 Zeichen
            duration_minutes: Dauer in Minuten (Default 24h)
        """
        if len(options) < 2 or len(options) > 4:
            return {"error": "poll_options_count", "count": len(options), "required": "2-4"}

        for i, opt in enumerate(options):
            if len(opt) > 25:
                return {"error": "poll_option_too_long", "index": i, "length": len(opt), "max": 25}

        if len(text) > self.MAX_TWEET_LENGTH:
            return {"error": "text_too_long", "length": len(text), "max": self.MAX_TWEET_LENGTH}

        if self.dry_run:
            return self._dry_run_log(
                "create_poll", text=text, options=options,
                duration_minutes=duration_minutes,
            )

        client = self._get_client()
        if not client:
            return {"error": "no_client"}

        try:
            response = client.create_tweet(
                text=text,
                poll_options=options,
                poll_duration_minutes=duration_minutes,
            )
            return {"tweet_id": response.data["id"], "dry_run": False}
        except Exception as e:
            logger.error(f"Poll creation failed: {e}")
            return {"error": str(e)}

    def get_tweet_analytics(self, tweet_id: str) -> dict:
        """Impressions, Engagements, Likes."""
        if self.dry_run:
            return self._dry_run_log("get_tweet_analytics", tweet_id=tweet_id)
        return {"error": "not_implemented_for_live"}

    def get_trending_topics(self, woeid: int = 1) -> dict:
        """Trending Topics (Worldwide default)."""
        if self.dry_run:
            return self._dry_run_log("get_trending_topics", woeid=woeid)
        return {"error": "not_implemented_for_live"}

    def get_account_stats(self) -> dict:
        """Followers, Following, Tweet Count."""
        if self.dry_run:
            return self._dry_run_log("get_account_stats")
        return {"error": "not_implemented_for_live"}
