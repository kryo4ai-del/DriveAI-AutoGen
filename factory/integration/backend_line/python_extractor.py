"""Python Code Extractor -- extracts and validates Python/FastAPI code from LLM output.

Follows the same pattern as Swift/Kotlin/TypeScript/C# extractors.
Identifies Python-specific constructs: classes, functions, FastAPI routes,
Pydantic models, async handlers.
"""

import ast
import re
import logging

logger = logging.getLogger(__name__)


# Python built-in types (for CompileHygiene exclusion)
PYTHON_BUILTIN_TYPES = {
    # Primitives
    "str", "int", "float", "bool", "bytes", "None", "complex",
    # Collections
    "list", "dict", "tuple", "set", "frozenset",
    # Typing
    "Optional", "Union", "Any", "List", "Dict", "Tuple", "Set",
    "Sequence", "Mapping", "Iterable", "Iterator", "Generator",
    "Callable", "Coroutine", "Awaitable", "AsyncGenerator",
    "Type", "ClassVar", "Final", "Literal",
    # Common stdlib
    "datetime", "date", "time", "timedelta",
    "UUID", "Decimal", "Path", "Enum", "IntEnum", "StrEnum",
    "dataclass", "field",
    "ABC", "abstractmethod",
    "asyncio", "json", "os", "sys", "logging",
    "Exception", "ValueError", "TypeError", "KeyError", "RuntimeError",
    "HTTPException",
}

# FastAPI/Pydantic types
FASTAPI_TYPES = {
    # FastAPI core
    "FastAPI", "APIRouter", "Request", "Response",
    "Depends", "Query", "Path", "Body", "Header", "Cookie", "Form", "File",
    "UploadFile", "BackgroundTasks", "WebSocket",
    # Responses
    "JSONResponse", "HTMLResponse", "StreamingResponse", "RedirectResponse",
    "FileResponse", "PlainTextResponse",
    # Middleware
    "CORSMiddleware", "TrustedHostMiddleware", "GZipMiddleware",
    # Pydantic
    "BaseModel", "Field", "validator", "root_validator",
    "ConfigDict", "model_validator",
    # Status
    "status",
    # Security
    "OAuth2PasswordBearer", "OAuth2PasswordRequestForm",
    "HTTPBearer", "HTTPAuthorizationCredentials",
}

# Firebase/Google Cloud types
FIREBASE_TYPES = {
    "firestore", "auth", "storage", "messaging",
    "DocumentReference", "CollectionReference",
    "DocumentSnapshot", "QuerySnapshot",
    "credentials", "initialize_app",
    "db",
}

# All known types combined
ALL_KNOWN_TYPES = PYTHON_BUILTIN_TYPES | FASTAPI_TYPES | FIREBASE_TYPES


# Patterns to identify Python file types
_FILE_PATTERNS = {
    "main": re.compile(
        r"(app\s*=\s*FastAPI|def\s+main|if\s+__name__)", re.MULTILINE),
    "model": re.compile(
        r"class\s+\w+\(BaseModel\)", re.MULTILINE),
    "router": re.compile(
        r"router\s*=\s*APIRouter|@router\.(get|post|put|delete|patch)", re.MULTILINE),
    "database": re.compile(
        r"firestore|firebase|db\s*=|collection\(|engine\s*=\s*create", re.MULTILINE),
    "auth": re.compile(
        r"OAuth2|HTTPBearer|verify_token|get_current_user|verify_id_token", re.MULTILINE),
    "config": re.compile(
        r"class\s+Settings|BaseSettings|\.env|environ\.get", re.MULTILINE),
    "test": re.compile(
        r"def\s+test_|class\s+Test|pytest|unittest|@pytest", re.MULTILINE),
}

# Route decorator pattern
_ROUTE_PATTERN = re.compile(
    r"@(?:app|router)\.(get|post|put|delete|patch)\(\s*[\"']([^\"']+)[\"']",
    re.MULTILINE,
)

# Python code block pattern
_CODE_BLOCK_RE = re.compile(
    r"```(?:python|py)\s*\n(.*?)```", re.DOTALL)

# Filename hint: # filename: xxx.py or # --- xxx.py ---
_FILENAME_HINT_RE = re.compile(
    r"#\s*(?:filename|file):\s*(\S+\.py)|#\s*---\s*(\S+\.py)\s*---")


class PythonExtractor:
    """Extracts Python code blocks from LLM output."""

    def extract_code_blocks(self, llm_output: str) -> list:
        """Extract Python code blocks from LLM output.

        Returns list of {filename, content, file_type}
        """
        blocks = []
        matches = _CODE_BLOCK_RE.findall(llm_output)

        for code in matches:
            code = code.strip()
            if not code:
                continue

            file_type = self.detect_file_type(code)

            # Try to find filename hint above the code block
            filename = self._find_filename_hint(llm_output, code)
            if not filename:
                filename = self.suggest_filename(code, file_type)

            blocks.append({
                "filename": filename,
                "content": code,
                "file_type": file_type,
            })

        return blocks

    def _find_filename_hint(self, full_output: str, code_block: str) -> str:
        """Look for filename hints near a code block."""
        # Find position of code block in output
        pos = full_output.find(code_block)
        if pos == -1:
            return ""

        # Search in the 200 chars before the code block
        prefix = full_output[max(0, pos - 200):pos]
        match = _FILENAME_HINT_RE.search(prefix)
        if match:
            return match.group(1) or match.group(2)
        return ""

    def detect_file_type(self, code: str) -> str:
        """Detect what kind of Python file this is."""
        # Check patterns in priority order
        for ftype, pattern in _FILE_PATTERNS.items():
            if pattern.search(code):
                return ftype
        return "utility"

    def suggest_filename(self, code: str, file_type: str) -> str:
        """Suggest a filename based on content."""
        if file_type == "main":
            return "main.py"
        elif file_type == "model":
            # Try to get model name
            match = re.search(r"class\s+(\w+)\(BaseModel\)", code)
            if match:
                name = self._to_snake(match.group(1))
                return f"models/{name}.py"
            return "models.py"
        elif file_type == "router":
            # Try to get router prefix
            match = re.search(r'prefix\s*=\s*["\']/?(\w+)', code)
            if match:
                return f"routers/{match.group(1)}.py"
            return "routers/api.py"
        elif file_type == "database":
            return "database.py"
        elif file_type == "auth":
            return "auth.py"
        elif file_type == "config":
            return "config.py"
        elif file_type == "test":
            # Try to find test target
            match = re.search(r"def\s+test_(\w+)", code)
            if match:
                return f"tests/test_{match.group(1).split('_')[0]}.py"
            return "tests/test_main.py"
        return "utils.py"

    def validate_syntax(self, code: str) -> tuple:
        """Basic Python syntax validation via compile()."""
        try:
            compile(code, "<string>", "exec")
            return True, ""
        except SyntaxError as e:
            return False, f"Line {e.lineno}: {e.msg}"

    def extract_imports(self, code: str) -> list:
        """Extract all import statements from code."""
        imports = []
        try:
            tree = ast.parse(code)
            for node in ast.walk(tree):
                if isinstance(node, ast.Import):
                    for alias in node.names:
                        imports.append(alias.name)
                elif isinstance(node, ast.ImportFrom):
                    module = node.module or ""
                    imports.append(module)
        except SyntaxError:
            # Fallback: regex
            for match in re.finditer(
                    r"^(?:from\s+(\S+)\s+import|import\s+(\S+))",
                    code, re.MULTILINE):
                imports.append(match.group(1) or match.group(2))
        return imports

    def extract_classes(self, code: str) -> list:
        """Extract all class names defined in code."""
        classes = []
        try:
            tree = ast.parse(code)
            for node in ast.walk(tree):
                if isinstance(node, ast.ClassDef):
                    classes.append(node.name)
        except SyntaxError:
            classes = re.findall(r"class\s+(\w+)", code)
        return classes

    def extract_functions(self, code: str) -> list:
        """Extract all function names (including async)."""
        functions = []
        try:
            tree = ast.parse(code)
            for node in ast.walk(tree):
                if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    functions.append(node.name)
        except SyntaxError:
            functions = re.findall(r"(?:async\s+)?def\s+(\w+)", code)
        return functions

    def extract_routes(self, code: str) -> list:
        """Extract FastAPI route definitions.

        Returns [{method, path, function_name}]
        """
        routes = []
        matches = _ROUTE_PATTERN.finditer(code)

        for match in matches:
            method = match.group(1)
            path = match.group(2)

            # Find the function name after the decorator
            after = code[match.end():]
            fn_match = re.search(
                r"(?:async\s+)?def\s+(\w+)", after)
            fn_name = fn_match.group(1) if fn_match else "unknown"

            routes.append({
                "method": method,
                "path": path,
                "function_name": fn_name,
            })

        return routes

    @staticmethod
    def _to_snake(name: str) -> str:
        """Convert PascalCase to snake_case."""
        s = re.sub(r"([A-Z])", r"_\1", name).lower().lstrip("_")
        return s
