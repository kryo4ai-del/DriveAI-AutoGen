"""Backend Assembly Line -- generates FastAPI service scaffolding.

Produces a complete backend project structure:
- main.py (FastAPI app with routes)
- models.py (Pydantic models)
- database.py (Firebase/Firestore connection)
- auth.py (Authentication middleware)
- config.py (Environment settings)
- requirements.txt
- Dockerfile
- .env.example
"""

import json
import logging
import os
import re
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[3]


@dataclass
class BackendSpec:
    """Specification for a backend service."""
    project_name: str
    endpoints: list = field(default_factory=list)
    models: list = field(default_factory=list)
    database: str = "firebase"
    auth_method: str = "firebase"
    deployment: str = "cloud_run"


@dataclass
class BackendGenerationResult:
    """Result of generating a backend project."""
    success: bool
    project_dir: str
    files_created: list = field(default_factory=list)
    total_files: int = 0
    error: str = ""

    def summary(self) -> str:
        if self.success:
            return f"Backend: {self.total_files} files in {self.project_dir}"
        return f"Backend FAILED: {self.error}"


class BackendAssemblyLine:
    """Generates FastAPI backend service scaffolding."""

    def __init__(self, output_dir: str = None):
        self._output_dir = Path(output_dir) if output_dir else None

    def generate(self, spec: BackendSpec,
                 output_dir: str = None) -> BackendGenerationResult:
        """Generate complete backend project from spec."""
        out = Path(output_dir) if output_dir else self._output_dir
        if not out:
            out = PROJECT_ROOT / "projects" / f"{spec.project_name}_backend"
        out.mkdir(parents=True, exist_ok=True)

        files = []
        try:
            # Core files
            for fname, generator in [
                ("main.py", self._generate_main_py),
                ("models.py", self._generate_models_py),
                ("database.py", self._generate_database_py),
                ("auth.py", self._generate_auth_py),
                ("config.py", self._generate_config_py),
                ("requirements.txt", self._generate_requirements_txt),
                ("Dockerfile", self._generate_dockerfile),
                (".env.example", self._generate_env_example),
            ]:
                content = generator(spec)
                self._save_file(content, out / fname)
                files.append(fname)

            return BackendGenerationResult(
                success=True,
                project_dir=str(out),
                files_created=files,
                total_files=len(files),
            )
        except Exception as e:
            logger.error("Backend generation failed: %s", e)
            return BackendGenerationResult(
                success=False,
                project_dir=str(out),
                files_created=files,
                total_files=len(files),
                error=str(e),
            )

    def _generate_main_py(self, spec: BackendSpec) -> str:
        """Generate main.py content."""
        lines = [
            '"""',
            f"{spec.project_name} Backend API",
            '"""',
            "",
            "from fastapi import FastAPI",
            "from fastapi.middleware.cors import CORSMiddleware",
            "",
            "from config import settings",
        ]

        # Import auth if needed
        if spec.auth_method:
            lines.append("from auth import get_current_user")

        # Import database
        lines.append("from database import get_db")

        # Import models
        if spec.models:
            model_names = ", ".join(m.get("name", "Model") for m in spec.models)
            lines.append(f"from models import {model_names}")

        lines.extend([
            "",
            f'app = FastAPI(title="{spec.project_name}", version="1.0.0")',
            "",
            "app.add_middleware(",
            "    CORSMiddleware,",
            '    allow_origins=settings.cors_origins.split(","),',
            "    allow_credentials=True,",
            '    allow_methods=["*"],',
            '    allow_headers=["*"],',
            ")",
            "",
            "",
            '@app.get("/health")',
            "async def health_check():",
            '    return {"status": "healthy", "service": settings.project_name}',
        ])

        # Generate route stubs from endpoints
        for ep in spec.endpoints:
            method = ep.get("method", "get").lower()
            path = ep.get("path", "/")
            desc = ep.get("description", "")
            auth_req = ep.get("auth_required", False)
            fn_name = self._path_to_fn(path)

            lines.append("")
            lines.append("")
            lines.append(f'@app.{method}("{path}")')

            params = []
            if auth_req and spec.auth_method:
                params.append("user=Depends(get_current_user)")
            if method in ("post", "put", "patch"):
                # Find matching model
                model_name = self._find_model_for_endpoint(ep, spec.models)
                if model_name:
                    params.append(f"payload: {model_name}")

            sig = ", ".join(params)
            lines.append(f"async def {fn_name}({sig}):")
            if desc:
                lines.append(f'    """{desc}"""')
            lines.append(f"    # TODO: implement {fn_name}")
            lines.append(f'    return {{"endpoint": "{path}", "status": "not_implemented"}}')

        lines.append("")
        lines.append("")
        lines.append('if __name__ == "__main__":')
        lines.append("    import uvicorn")
        lines.append('    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)')
        lines.append("")

        return "\n".join(lines)

    def _generate_models_py(self, spec: BackendSpec) -> str:
        """Generate Pydantic models from spec.models."""
        lines = [
            '"""Pydantic models for API request/response validation."""',
            "",
            "from datetime import datetime",
            "from typing import Optional",
            "",
            "from pydantic import BaseModel, Field",
            "",
        ]

        if not spec.models:
            lines.extend([
                "",
                "class HealthResponse(BaseModel):",
                "    status: str",
                "    service: str",
                "",
            ])
            return "\n".join(lines)

        for model in spec.models:
            name = model.get("name", "Item")
            model_fields = model.get("fields", [])

            lines.append("")
            lines.append(f"class {name}(BaseModel):")
            if not model_fields:
                lines.append("    pass")
            else:
                for f in model_fields:
                    fname = f.get("name", "value")
                    ftype = f.get("type", "str")
                    required = f.get("required", True)

                    # Map common type names
                    ftype = self._map_type(ftype)

                    if not required:
                        lines.append(
                            f"    {fname}: Optional[{ftype}] = None")
                    else:
                        lines.append(f"    {fname}: {ftype}")
            lines.append("")

        # Generate Response wrappers
        lines.append("")
        lines.append("class SuccessResponse(BaseModel):")
        lines.append("    success: bool = True")
        lines.append("    message: str = \"\"")
        lines.append("")
        lines.append("")
        lines.append("class ErrorResponse(BaseModel):")
        lines.append("    success: bool = False")
        lines.append("    error: str")
        lines.append("    detail: Optional[str] = None")
        lines.append("")

        return "\n".join(lines)

    def _generate_database_py(self, spec: BackendSpec) -> str:
        """Generate database connection."""
        if spec.database == "firebase":
            return self._generate_firebase_db(spec)
        elif spec.database == "postgresql":
            return self._generate_postgres_db(spec)
        return self._generate_firebase_db(spec)

    def _generate_firebase_db(self, spec: BackendSpec) -> str:
        return "\n".join([
            '"""Firebase/Firestore database connection."""',
            "",
            "import firebase_admin",
            "from firebase_admin import credentials, firestore",
            "",
            "from config import settings",
            "",
            "",
            "def _init_firebase():",
            '    """Initialize Firebase Admin SDK."""',
            "    if not firebase_admin._apps:",
            "        if settings.firebase_credentials_path:",
            "            cred = credentials.Certificate(settings.firebase_credentials_path)",
            "            firebase_admin.initialize_app(cred)",
            "        else:",
            "            firebase_admin.initialize_app()",
            "",
            "",
            "_init_firebase()",
            "db = firestore.client()",
            "",
            "",
            "def get_db():",
            '    """Get Firestore client (dependency injection)."""',
            "    return db",
            "",
        ])

    def _generate_postgres_db(self, spec: BackendSpec) -> str:
        return "\n".join([
            '"""PostgreSQL database connection."""',
            "",
            "from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession",
            "from sqlalchemy.orm import sessionmaker",
            "",
            "from config import settings",
            "",
            "",
            "engine = create_async_engine(settings.database_url, echo=False)",
            "async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)",
            "",
            "",
            "async def get_db():",
            '    """Get database session (dependency injection)."""',
            "    async with async_session() as session:",
            "        yield session",
            "",
        ])

    def _generate_auth_py(self, spec: BackendSpec) -> str:
        """Generate auth middleware."""
        if spec.auth_method == "firebase":
            return self._generate_firebase_auth()
        elif spec.auth_method == "jwt":
            return self._generate_jwt_auth()
        return self._generate_firebase_auth()

    def _generate_firebase_auth(self) -> str:
        return "\n".join([
            '"""Firebase Authentication middleware."""',
            "",
            "from fastapi import Depends, HTTPException, status",
            "from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials",
            "from firebase_admin import auth",
            "",
            "",
            "security = HTTPBearer()",
            "",
            "",
            "async def get_current_user(",
            "    creds: HTTPAuthorizationCredentials = Depends(security),",
            ") -> dict:",
            '    """Verify Firebase ID token and return user info."""',
            "    try:",
            "        decoded = auth.verify_id_token(creds.credentials)",
            "        return {",
            '            "uid": decoded["uid"],',
            '            "email": decoded.get("email", ""),',
            '            "name": decoded.get("name", ""),',
            "        }",
            "    except Exception as e:",
            "        raise HTTPException(",
            "            status_code=status.HTTP_401_UNAUTHORIZED,",
            '            detail=f"Invalid token: {e}",',
            "        )",
            "",
        ])

    def _generate_jwt_auth(self) -> str:
        return "\n".join([
            '"""JWT Authentication middleware."""',
            "",
            "from fastapi import Depends, HTTPException, status",
            "from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials",
            "from jose import jwt, JWTError",
            "",
            "from config import settings",
            "",
            "",
            "security = HTTPBearer()",
            "",
            "",
            "async def get_current_user(",
            "    creds: HTTPAuthorizationCredentials = Depends(security),",
            ") -> dict:",
            '    """Verify JWT and return user info."""',
            "    try:",
            "        payload = jwt.decode(",
            "            creds.credentials,",
            "            settings.jwt_secret,",
            '            algorithms=["HS256"],',
            "        )",
            '        return {"uid": payload.get("sub"), "email": payload.get("email", "")}',
            "    except JWTError as e:",
            "        raise HTTPException(",
            "            status_code=status.HTTP_401_UNAUTHORIZED,",
            '            detail=f"Invalid token: {e}",',
            "        )",
            "",
        ])

    def _generate_config_py(self, spec: BackendSpec) -> str:
        """Generate settings with pydantic BaseSettings."""
        lines = [
            '"""Application configuration via environment variables."""',
            "",
            "from pydantic_settings import BaseSettings",
            "",
            "",
            "class Settings(BaseSettings):",
            f'    project_name: str = "{spec.project_name}"',
            '    cors_origins: str = "http://localhost:3000,http://localhost:8080"',
            '    log_level: str = "INFO"',
        ]

        if spec.database == "firebase":
            lines.append('    firebase_credentials_path: str = ""')
        elif spec.database == "postgresql":
            lines.append('    database_url: str = "postgresql+asyncpg://user:pass@localhost/db"')

        if spec.auth_method == "jwt":
            lines.append('    jwt_secret: str = "change-me-in-production"')

        lines.extend([
            "",
            "    class Config:",
            '        env_file = ".env"',
            "",
            "",
            "settings = Settings()",
            "",
        ])

        return "\n".join(lines)

    def _generate_requirements_txt(self, spec: BackendSpec) -> str:
        """Generate requirements.txt based on what's used."""
        deps = [
            "fastapi>=0.110.0",
            "uvicorn[standard]>=0.27.0",
            "pydantic>=2.0.0",
            "pydantic-settings>=2.0.0",
        ]

        if spec.database == "firebase" or spec.auth_method == "firebase":
            deps.append("firebase-admin>=6.0.0")
        if spec.database == "postgresql":
            deps.extend([
                "sqlalchemy>=2.0.0",
                "asyncpg>=0.29.0",
            ])
        if spec.auth_method == "jwt":
            deps.append("python-jose[cryptography]>=3.3.0")

        deps.append("python-dotenv>=1.0.0")

        return "\n".join(sorted(deps)) + "\n"

    def _generate_dockerfile(self, spec: BackendSpec) -> str:
        """Generate Dockerfile for Cloud Run deployment."""
        return "\n".join([
            "FROM python:3.11-slim",
            "",
            "WORKDIR /app",
            "",
            "COPY requirements.txt .",
            "RUN pip install --no-cache-dir -r requirements.txt",
            "",
            "COPY . .",
            "",
            "EXPOSE 8000",
            "",
            'CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]',
            "",
        ])

    def _generate_env_example(self, spec: BackendSpec) -> str:
        """Generate .env.example with required environment variables."""
        lines = [
            f"# {spec.project_name} Backend Environment Variables",
            "",
            f'PROJECT_NAME="{spec.project_name}"',
            'CORS_ORIGINS="http://localhost:3000"',
            'LOG_LEVEL="INFO"',
        ]

        if spec.database == "firebase" or spec.auth_method == "firebase":
            lines.extend([
                "",
                "# Firebase",
                'FIREBASE_CREDENTIALS_PATH="service-account.json"',
            ])
        if spec.database == "postgresql":
            lines.extend([
                "",
                "# PostgreSQL",
                'DATABASE_URL="postgresql+asyncpg://user:password@localhost:5432/dbname"',
            ])
        if spec.auth_method == "jwt":
            lines.extend([
                "",
                "# JWT",
                'JWT_SECRET="your-secret-key-change-in-production"',
            ])

        lines.append("")
        return "\n".join(lines)

    def _save_file(self, content: str, path: Path):
        """Save content to file, create dirs as needed."""
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        logger.info("Generated: %s (%d bytes)", path.name, len(content))

    def generate_from_roadbook(self, roadbook_dir: str, project_name: str,
                               output_dir: str = None) -> BackendGenerationResult:
        """Generate backend from CD Roadbook."""
        from factory.asset_forge.pdf_reader import PDFReader

        reader = PDFReader()
        pdf_dir = Path(roadbook_dir)
        if not pdf_dir.exists():
            return BackendGenerationResult(
                success=False, project_dir="",
                error=f"Roadbook dir not found: {roadbook_dir}")

        all_text = []
        for pdf in sorted(pdf_dir.glob("*.pdf")):
            try:
                doc = reader.read_pdf(str(pdf))
                text = doc.full_text if hasattr(doc, "full_text") else str(doc)
                all_text.append(f"--- {pdf.name} ---\n{text}")
            except Exception as e:
                logger.warning("PDF read error %s: %s", pdf.name, e)

        combined = "\n\n".join(all_text)
        if len(combined) > 15000:
            combined = combined[:15000] + "\n... (truncated)"

        spec = self._extract_backend_spec_via_llm(combined, project_name)
        return self.generate(spec, output_dir)

    def _extract_backend_spec_via_llm(self, roadbook_text: str,
                                      project_name: str) -> BackendSpec:
        """LLM call to extract backend requirements from roadbook."""
        system = """You analyze CD Roadbooks and extract backend API requirements.
Return ONLY a JSON object:
{
  "endpoints": [{"method": "GET", "path": "/api/...", "description": "...", "auth_required": true}],
  "models": [{"name": "ModelName", "fields": [{"name": "field", "type": "str", "required": true}]}],
  "database": "firebase",
  "auth_method": "firebase"
}
Keep it concise: max 10 endpoints, max 8 models. Focus on the core API."""

        user = (f"Extract backend API requirements for {project_name} "
                f"from this CD Roadbook:\n\n{roadbook_text}")

        raw = self._call_llm(system, user, max_tokens=4096)
        return self._parse_spec_response(raw, project_name)

    def _parse_spec_response(self, raw: str, project_name: str) -> BackendSpec:
        """Parse LLM response into BackendSpec."""
        text = raw.strip()
        text = re.sub(r"```json\s*", "", text)
        text = re.sub(r"```\s*$", "", text)
        text = text.strip()

        try:
            data = json.loads(text)
        except json.JSONDecodeError:
            # Try finding JSON object
            start = text.find("{")
            end = text.rfind("}")
            if start != -1 and end > start:
                try:
                    data = json.loads(text[start:end + 1])
                except json.JSONDecodeError:
                    data = {}
            else:
                data = {}

        return BackendSpec(
            project_name=project_name,
            endpoints=data.get("endpoints", []),
            models=data.get("models", []),
            database=data.get("database", "firebase"),
            auth_method=data.get("auth_method", "firebase"),
        )

    def _call_llm(self, system: str, user: str, max_tokens: int = 4096) -> str:
        """TheBrain/Anthropic fallback."""
        try:
            from dotenv import load_dotenv
            load_dotenv(PROJECT_ROOT / ".env")
        except ImportError:
            pass

        try:
            from factory.the_brain.brain import TheBrain
            brain = TheBrain()
            result = brain.call(
                agent_id="backend_assembly_line",
                task_type="code_generation",
                prompt=f"{system}\n\n{user}",
                max_tokens=max_tokens,
            )
            text = result.get("text", "")
            if text:
                return text
        except Exception as e:
            logger.debug("TheBrain fallback: %s", e)

        import anthropic
        client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
        resp = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=max_tokens,
            system=system,
            messages=[{"role": "user", "content": user}],
        )
        return resp.content[0].text

    @staticmethod
    def _path_to_fn(path: str) -> str:
        """Convert API path to function name.
        /api/users/{id} -> get_user_by_id
        /api/levels -> get_levels
        """
        cleaned = path.strip("/").replace("/", "_").replace("{", "").replace("}", "")
        cleaned = re.sub(r"[^a-zA-Z0-9_]", "", cleaned)
        return cleaned or "root"

    @staticmethod
    def _find_model_for_endpoint(endpoint: dict, models: list) -> str:
        """Try to match an endpoint to a model name."""
        path = endpoint.get("path", "").lower()
        for model in models:
            name = model.get("name", "").lower()
            if name in path or path.rstrip("s").endswith(name):
                return model.get("name", "")
        return ""

    @staticmethod
    def _map_type(ftype: str) -> str:
        """Map common type names to Python types."""
        mapping = {
            "string": "str",
            "integer": "int",
            "number": "float",
            "boolean": "bool",
            "array": "list",
            "object": "dict",
        }
        return mapping.get(ftype.lower(), ftype)
