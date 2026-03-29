"""DriveAI Factory — Platform-specific Store Metadata.

Three platform dataclasses (Apple, Google, Web) plus a PlatformMetadataAdapter
that converts generic StoreMetadata into platform-specific formats.

Two generation paths:
  1. LLM (TheBrain/LiteLLM) for high-quality store texts
  2. Template fallback (deterministic, no LLM)

LLM is tried first if config.use_llm_for_texts is True.
On failure -> automatic fallback to template.
"""

import json
from dataclasses import dataclass, field
from pathlib import Path

from factory.store_prep.config import StorePrepConfig
from config.model_router import get_fallback_model


# ---------------------------------------------------------------------------
# Apple App Store
# ---------------------------------------------------------------------------

@dataclass
class AppleStoreMetadata:
    """Apple App Store metadata (App Store Connect format)."""

    app_name: str = ""
    subtitle: str = ""
    promotional_text: str = ""
    description: str = ""
    keywords: str = ""
    category_primary: str = ""
    category_secondary: str = ""
    age_rating: str = "4+"
    privacy_url: str = ""
    support_url: str = ""
    marketing_url: str = ""
    whats_new: str = "Initial release"
    languages: list = field(default_factory=lambda: ["de-DE", "en-US"])
    version: str = "1.0.0"

    def to_dict(self) -> dict:
        return {
            "app_name": self.app_name,
            "subtitle": self.subtitle,
            "promotional_text": self.promotional_text,
            "description": self.description,
            "keywords": self.keywords,
            "category_primary": self.category_primary,
            "category_secondary": self.category_secondary,
            "age_rating": self.age_rating,
            "privacy_url": self.privacy_url,
            "support_url": self.support_url,
            "marketing_url": self.marketing_url,
            "whats_new": self.whats_new,
            "languages": self.languages,
            "version": self.version,
        }

    def to_json(self, path: str) -> None:
        p = Path(path)
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(json.dumps(self.to_dict(), indent=2, ensure_ascii=False),
                      encoding="utf-8")

    def validate(self) -> list[str]:
        errors = []
        if not self.app_name:
            errors.append("app_name is required")
        if len(self.app_name) > 30:
            errors.append(f"app_name exceeds 30 chars ({len(self.app_name)})")
        if len(self.subtitle) > 30:
            errors.append(f"subtitle exceeds 30 chars ({len(self.subtitle)})")
        if len(self.promotional_text) > 170:
            errors.append(f"promotional_text exceeds 170 chars ({len(self.promotional_text)})")
        if not self.description:
            errors.append("description is required")
        if len(self.description) > 4000:
            errors.append(f"description exceeds 4000 chars ({len(self.description)})")
        if len(self.keywords) > 100:
            errors.append(f"keywords exceeds 100 chars ({len(self.keywords)})")
        if not self.category_primary:
            errors.append("category_primary is required")
        if not self.privacy_url:
            errors.append("privacy_url is required for Apple")
        if not self.languages:
            errors.append("at least one language required")
        return errors


# ---------------------------------------------------------------------------
# Google Play Store
# ---------------------------------------------------------------------------

@dataclass
class GooglePlayMetadata:
    """Google Play Store metadata (Play Console format)."""

    app_name: str = ""
    short_description: str = ""
    full_description: str = ""
    category: str = ""
    content_rating: str = "Everyone"
    privacy_policy_url: str = ""
    developer_email: str = ""
    developer_phone: str = ""
    developer_website: str = ""
    whats_new: str = "Initial release"
    default_language: str = "de-DE"
    languages: list = field(default_factory=lambda: ["de-DE", "en-US"])
    version: str = "1.0.0"

    def to_dict(self) -> dict:
        return {
            "app_name": self.app_name,
            "short_description": self.short_description,
            "full_description": self.full_description,
            "category": self.category,
            "content_rating": self.content_rating,
            "privacy_policy_url": self.privacy_policy_url,
            "developer_email": self.developer_email,
            "developer_phone": self.developer_phone,
            "developer_website": self.developer_website,
            "whats_new": self.whats_new,
            "default_language": self.default_language,
            "languages": self.languages,
            "version": self.version,
        }

    def to_json(self, path: str) -> None:
        p = Path(path)
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(json.dumps(self.to_dict(), indent=2, ensure_ascii=False),
                      encoding="utf-8")

    def validate(self) -> list[str]:
        errors = []
        if not self.app_name:
            errors.append("app_name is required")
        if len(self.app_name) > 30:
            errors.append(f"app_name exceeds 30 chars ({len(self.app_name)})")
        if len(self.short_description) > 80:
            errors.append(f"short_description exceeds 80 chars ({len(self.short_description)})")
        if not self.full_description:
            errors.append("full_description is required")
        if len(self.full_description) > 4000:
            errors.append(f"full_description exceeds 4000 chars ({len(self.full_description)})")
        if not self.category:
            errors.append("category is required")
        if not self.privacy_policy_url:
            errors.append("privacy_policy_url is required for Google Play")
        if len(self.whats_new) > 500:
            errors.append(f"whats_new exceeds 500 chars ({len(self.whats_new)})")
        if not self.languages:
            errors.append("at least one language required")
        return errors


# ---------------------------------------------------------------------------
# Web / SEO
# ---------------------------------------------------------------------------

@dataclass
class WebMetadata:
    """Web metadata for SEO and PWA."""

    title: str = ""
    meta_description: str = ""
    keywords: list = field(default_factory=list)
    og_title: str = ""
    og_description: str = ""
    og_image: str = ""
    favicon_path: str = ""
    manifest: dict = field(default_factory=dict)
    robots: str = "index, follow"
    canonical_url: str = ""
    language: str = "de"
    alternate_languages: list = field(default_factory=list)

    def to_dict(self) -> dict:
        return {
            "title": self.title,
            "meta_description": self.meta_description,
            "keywords": self.keywords,
            "og_title": self.og_title,
            "og_description": self.og_description,
            "og_image": self.og_image,
            "favicon_path": self.favicon_path,
            "manifest": self.manifest,
            "robots": self.robots,
            "canonical_url": self.canonical_url,
            "language": self.language,
            "alternate_languages": self.alternate_languages,
        }

    def to_json(self, path: str) -> None:
        p = Path(path)
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(json.dumps(self.to_dict(), indent=2, ensure_ascii=False),
                      encoding="utf-8")

    def validate(self) -> list[str]:
        errors = []
        if not self.title:
            errors.append("title is required")
        if len(self.title) > 60:
            errors.append(f"title exceeds 60 chars ({len(self.title)})")
        if len(self.meta_description) > 160:
            errors.append(f"meta_description exceeds 160 chars ({len(self.meta_description)})")
        return errors


# ---------------------------------------------------------------------------
# PlatformMetadataAdapter
# ---------------------------------------------------------------------------

class PlatformMetadataAdapter:
    """Converts generic StoreMetadata into platform-specific format.

    Two generation paths:
      - LLM (TheBrain/LiteLLM) for high-quality store texts
      - Template fallback (deterministic, no LLM)

    LLM is tried first if config.use_llm_for_texts is True.
    On failure -> automatic fallback to template.
    """

    def __init__(self, config: StorePrepConfig | None = None) -> None:
        self.config = config or StorePrepConfig()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def adapt(
        self,
        generic_metadata,
        platform: str,
        enrichment: dict | None = None,
    ) -> AppleStoreMetadata | GooglePlayMetadata | WebMetadata:
        """Convert generic StoreMetadata to platform-specific format.

        Parameters:
            generic_metadata: StoreMetadata from factory/store/metadata_generator.py
            platform: "ios", "android", "web"
            enrichment: optional dict from MetadataEnricher with keys like
                        audience, usp, competitors, positioning, monetization,
                        marketing_hooks
        """
        if platform == "ios":
            return self._adapt_ios(generic_metadata, enrichment)
        elif platform == "android":
            return self._adapt_android(generic_metadata, enrichment)
        elif platform == "web":
            return self._adapt_web(generic_metadata, enrichment)
        else:
            raise ValueError(f"Unknown platform: {platform}")

    # ------------------------------------------------------------------
    # iOS
    # ------------------------------------------------------------------

    def _adapt_ios(self, meta, enrichment: dict | None) -> AppleStoreMetadata:
        if self.config.use_llm_for_texts and enrichment:
            try:
                return self._generate_ios_with_llm(meta, enrichment)
            except Exception as e:
                print(f"[Store Prep] LLM generation failed for iOS, using template: {e}")
        return self._generate_ios_from_template(meta, enrichment)

    def _generate_ios_from_template(self, meta, enrichment: dict | None) -> AppleStoreMetadata:
        promo = ""
        if enrichment and enrichment.get("usp", {}).get("raw"):
            usp_raw = enrichment["usp"]["raw"]
            first_sentence = usp_raw.split(".")[0] if "." in usp_raw else usp_raw[:150]
            promo = f"{meta.app_name} -- {first_sentence}"[:self.config.apple_promo_text_max]

        return AppleStoreMetadata(
            app_name=(meta.app_name or "")[:self.config.apple_app_name_max],
            subtitle=(getattr(meta, "subtitle", "") or "")[:self.config.apple_subtitle_max],
            promotional_text=promo,
            description=(
                getattr(meta, "description_en", "") or
                getattr(meta, "description_de", "") or ""
            )[:self.config.apple_description_max],
            keywords=self._optimize_apple_keywords(
                getattr(meta, "keywords", "") or "", meta.app_name or ""),
            category_primary=getattr(meta, "category_primary", "") or "",
            category_secondary=getattr(meta, "category_secondary", "") or "",
            age_rating=getattr(meta, "age_rating", "") or self.config.default_age_rating,
            privacy_url=getattr(meta, "privacy_url", "") or "",
            support_url=getattr(meta, "support_url", "") or "",
            whats_new=(getattr(meta, "whats_new", "") or "Initial release")[
                :self.config.apple_whats_new_max],
            version=getattr(meta, "version", "") or "1.0.0",
        )

    def _generate_ios_with_llm(self, meta, enrichment: dict) -> AppleStoreMetadata:
        """LLM-based generation for Apple store texts."""
        model, completion_fn = self._get_llm()

        audience = enrichment.get("audience", {}).get("raw", "")
        usp = enrichment.get("usp", {}).get("raw", "")
        positioning = enrichment.get("positioning", {}).get("raw", "")
        hooks = enrichment.get("marketing_hooks", {}).get("raw", "")

        system_prompt = (
            "You are an App Store Optimization (ASO) expert. "
            "Generate Apple App Store metadata. Respond ONLY with valid JSON."
        )
        user_prompt = (
            f"App: {meta.app_name}\n"
            f"Current Description: {getattr(meta, 'description_en', '') or ''}\n"
            f"USP: {usp}\n"
            f"Target Audience: {audience}\n"
            f"Positioning: {positioning}\n"
            f"Marketing Hooks: {hooks}\n\n"
            f"Generate JSON with these keys:\n"
            f'- "promotional_text": max 170 chars, compelling hook\n'
            f'- "subtitle": max 30 chars, key benefit\n'
            f'- "description": max 4000 chars, ASO-optimized, use line breaks\n'
            f'- "keywords": max 100 chars total, comma-separated, no spaces after commas, '
            f"do NOT include the app name\n"
        )

        response = completion_fn(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            timeout=self.config.llm_timeout_seconds,
        )

        content = response.choices[0].message.content
        data = self._parse_json_response(content)

        return AppleStoreMetadata(
            app_name=(meta.app_name or "")[:self.config.apple_app_name_max],
            subtitle=(data.get("subtitle") or "")[:self.config.apple_subtitle_max],
            promotional_text=(data.get("promotional_text") or "")[:self.config.apple_promo_text_max],
            description=(data.get("description") or "")[:self.config.apple_description_max],
            keywords=self._optimize_apple_keywords(
                data.get("keywords") or "", meta.app_name or ""),
            category_primary=getattr(meta, "category_primary", "") or "",
            category_secondary=getattr(meta, "category_secondary", "") or "",
            age_rating=getattr(meta, "age_rating", "") or self.config.default_age_rating,
            privacy_url=getattr(meta, "privacy_url", "") or "",
            support_url=getattr(meta, "support_url", "") or "",
            whats_new=(getattr(meta, "whats_new", "") or "Initial release")[
                :self.config.apple_whats_new_max],
            version=getattr(meta, "version", "") or "1.0.0",
        )

    # ------------------------------------------------------------------
    # Android
    # ------------------------------------------------------------------

    def _adapt_android(self, meta, enrichment: dict | None) -> GooglePlayMetadata:
        if self.config.use_llm_for_texts and enrichment:
            try:
                return self._generate_android_with_llm(meta, enrichment)
            except Exception as e:
                print(f"[Store Prep] LLM generation failed for Android, using template: {e}")
        return self._generate_android_from_template(meta, enrichment)

    def _generate_android_from_template(self, meta, enrichment: dict | None) -> GooglePlayMetadata:
        short_desc = ""
        if enrichment and enrichment.get("marketing_hooks", {}).get("raw"):
            raw = enrichment["marketing_hooks"]["raw"]
            short_desc = (raw.split(".")[0] if "." in raw else raw)[
                :self.config.google_short_desc_max]
        elif getattr(meta, "subtitle", ""):
            short_desc = meta.subtitle[:self.config.google_short_desc_max]

        return GooglePlayMetadata(
            app_name=(meta.app_name or "")[:self.config.google_app_name_max],
            short_description=short_desc,
            full_description=(
                getattr(meta, "description_en", "") or
                getattr(meta, "description_de", "") or ""
            )[:self.config.google_full_desc_max],
            category=getattr(meta, "category_primary", "") or "",
            privacy_policy_url=getattr(meta, "privacy_url", "") or "",
            whats_new=(getattr(meta, "whats_new", "") or "Initial release")[
                :self.config.google_whats_new_max],
            version=getattr(meta, "version", "") or "1.0.0",
        )

    def _generate_android_with_llm(self, meta, enrichment: dict) -> GooglePlayMetadata:
        """LLM-based generation for Google Play texts."""
        model, completion_fn = self._get_llm()

        audience = enrichment.get("audience", {}).get("raw", "")
        usp = enrichment.get("usp", {}).get("raw", "")
        hooks = enrichment.get("marketing_hooks", {}).get("raw", "")

        system_prompt = (
            "You are a Google Play Store optimization expert. "
            "Generate Play Store metadata. Respond ONLY with valid JSON."
        )
        user_prompt = (
            f"App: {meta.app_name}\n"
            f"Current Description: {getattr(meta, 'description_en', '') or ''}\n"
            f"USP: {usp}\n"
            f"Target Audience: {audience}\n"
            f"Marketing Hooks: {hooks}\n\n"
            f"Generate JSON with these keys:\n"
            f'- "short_description": max 80 chars, compelling one-liner\n'
            f'- "full_description": max 4000 chars, Google Play optimized, use formatting\n'
            f'- "whats_new": max 500 chars, release notes for initial version\n'
        )

        response = completion_fn(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            timeout=self.config.llm_timeout_seconds,
        )

        content = response.choices[0].message.content
        data = self._parse_json_response(content)

        return GooglePlayMetadata(
            app_name=(meta.app_name or "")[:self.config.google_app_name_max],
            short_description=(data.get("short_description") or "")[
                :self.config.google_short_desc_max],
            full_description=(data.get("full_description") or "")[
                :self.config.google_full_desc_max],
            category=getattr(meta, "category_primary", "") or "",
            privacy_policy_url=getattr(meta, "privacy_url", "") or "",
            whats_new=(data.get("whats_new") or "Initial release")[
                :self.config.google_whats_new_max],
            version=getattr(meta, "version", "") or "1.0.0",
        )

    # ------------------------------------------------------------------
    # Web
    # ------------------------------------------------------------------

    def _adapt_web(self, meta, enrichment: dict | None) -> WebMetadata:
        if self.config.use_llm_for_texts and enrichment:
            try:
                return self._generate_web_with_llm(meta, enrichment)
            except Exception as e:
                print(f"[Store Prep] LLM generation failed for Web, using template: {e}")
        return self._generate_web_from_template(meta, enrichment)

    def _generate_web_from_template(self, meta, enrichment: dict | None) -> WebMetadata:
        desc = (
            getattr(meta, "description_en", "") or
            getattr(meta, "description_de", "") or ""
        )
        return WebMetadata(
            title=(meta.app_name or "")[:self.config.web_title_max],
            meta_description=desc[:self.config.web_meta_desc_max],
            keywords=[k.strip() for k in (getattr(meta, "keywords", "") or "").split(",")
                      if k.strip()],
            og_title=meta.app_name or "",
            og_description=desc[:200],
            language="de",
            manifest={
                "name": meta.app_name or "",
                "short_name": (meta.app_name or "")[:12],
                "description": desc[:200],
                "start_url": "/",
                "display": "standalone",
                "theme_color": "#000000",
                "background_color": "#ffffff",
            },
        )

    def _generate_web_with_llm(self, meta, enrichment: dict) -> WebMetadata:
        """LLM-based generation for Web SEO metadata."""
        model, completion_fn = self._get_llm()

        usp = enrichment.get("usp", {}).get("raw", "")
        audience = enrichment.get("audience", {}).get("raw", "")

        system_prompt = (
            "You are an SEO and web metadata expert. "
            "Generate web metadata. Respond ONLY with valid JSON."
        )
        user_prompt = (
            f"App: {meta.app_name}\n"
            f"Current Description: {getattr(meta, 'description_en', '') or ''}\n"
            f"USP: {usp}\n"
            f"Target Audience: {audience}\n\n"
            f"Generate JSON with these keys:\n"
            f'- "title": max 60 chars, SEO-optimized page title\n'
            f'- "meta_description": max 160 chars, compelling snippet\n'
            f'- "og_title": Open Graph title\n'
            f'- "og_description": max 200 chars, social media preview\n'
            f'- "keywords": list of 5-10 relevant SEO keywords\n'
        )

        response = completion_fn(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            timeout=self.config.llm_timeout_seconds,
        )

        content = response.choices[0].message.content
        data = self._parse_json_response(content)

        kw_raw = data.get("keywords", [])
        keywords = kw_raw if isinstance(kw_raw, list) else [
            k.strip() for k in str(kw_raw).split(",") if k.strip()]

        return WebMetadata(
            title=(data.get("title") or meta.app_name or "")[:self.config.web_title_max],
            meta_description=(data.get("meta_description") or "")[:self.config.web_meta_desc_max],
            keywords=keywords,
            og_title=data.get("og_title") or meta.app_name or "",
            og_description=(data.get("og_description") or "")[:200],
            language="de",
            manifest={
                "name": meta.app_name or "",
                "short_name": (meta.app_name or "")[:12],
                "description": (data.get("meta_description") or "")[:200],
                "start_url": "/",
                "display": "standalone",
                "theme_color": "#000000",
                "background_color": "#ffffff",
            },
        )

    # ------------------------------------------------------------------
    # LLM helpers
    # ------------------------------------------------------------------

    def _get_llm(self) -> tuple:
        """Return (model_id, completion_function). Raises on failure."""
        # Try TheBrain first
        try:
            from factory.brain.brain import get_brain
            brain = get_brain()
            if brain:
                model = brain.get_model(
                    agent_name="store_prep",
                    task_type="creative_writing",
                    tier="mid",
                )
                from litellm import completion
                print(f"[Store Prep] Using TheBrain model: {model}")
                return model, completion
        except Exception:
            pass

        # Fallback to direct LiteLLM
        try:
            from litellm import completion
            model = get_fallback_model()
            print(f"[Store Prep] Using direct LiteLLM: {model}")
            return model, completion
        except ImportError:
            pass

        raise RuntimeError("No LLM available (TheBrain and LiteLLM both unavailable)")

    @staticmethod
    def _parse_json_response(content: str) -> dict:
        """Parse JSON from LLM response. Handles markdown code blocks."""
        text = content.strip()
        # Strip markdown code block if present
        if text.startswith("```"):
            lines = text.split("\n")
            # Remove first line (```json) and last line (```)
            lines = [l for l in lines if not l.strip().startswith("```")]
            text = "\n".join(lines).strip()
        return json.loads(text)

    # ------------------------------------------------------------------
    # Keyword optimization
    # ------------------------------------------------------------------

    @staticmethod
    def _optimize_apple_keywords(keywords_str: str, app_name: str) -> str:
        """Optimize keywords for Apple App Store.

        Rules:
        - Comma-separated, no spaces after commas
        - Remove app name words (Apple indexes them automatically)
        - Remove duplicates, preserve order
        - Total max 100 characters
        - Lowercase
        """
        if not keywords_str:
            return ""

        keywords = [k.strip().lower() for k in keywords_str.split(",") if k.strip()]

        # Remove app name words
        name_words = set(app_name.lower().split())
        keywords = [k for k in keywords if k not in name_words]

        # Remove duplicates preserving order
        seen: set[str] = set()
        unique: list[str] = []
        for k in keywords:
            if k not in seen:
                seen.add(k)
                unique.append(k)

        # Join without spaces, respect 100-char limit
        result = ",".join(unique)
        while len(result) > 100 and unique:
            unique.pop()
            result = ",".join(unique)
        return result
