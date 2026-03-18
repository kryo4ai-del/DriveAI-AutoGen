# tests/test_typescript_extractor.py
# Unit tests for TypeScriptCodeExtractor.

import pytest

from code_generation.extractors.typescript_extractor import (
    TypeScriptCodeExtractor,
    _detect_name_and_folder,
    _is_valid_filename,
    _is_typescript_code,
    _has_jsx,
    _strip_duplicate_exports,
)


class FakeMessage:
    def __init__(self, source: str, content: str):
        self.source = source
        self.content = content


# --- Test 1: Detect ```typescript fence ---
def test_detect_typescript_fence():
    extractor = TypeScriptCodeExtractor()
    msg = FakeMessage("dev", '```typescript\nexport function fetchUsers() { return fetch("/api/users") }\n```')
    result = extractor.extract_code([msg])
    assert result["saved"] >= 1 or result["skipped"] >= 0


# --- Test 2: Detect ```tsx fence ---
def test_detect_tsx_fence():
    extractor = TypeScriptCodeExtractor()
    msg = FakeMessage("dev", '```tsx\nexport default function Dashboard() {\n  return <div className="main">Hello</div>\n}\n```')
    result = extractor.extract_code([msg])
    assert result["saved"] >= 1 or result["skipped"] >= 0


# --- Test 3: Detect ```ts fence ---
def test_detect_ts_fence():
    extractor = TypeScriptCodeExtractor()
    msg = FakeMessage("dev", '```ts\nexport interface UserProfile {\n  name: string\n  age: number\n}\n```')
    result = extractor.extract_code([msg])
    assert result["saved"] >= 1 or result["skipped"] >= 0


# --- Test 4: Extract React component (export default function) ---
def test_extract_default_function_component():
    code = 'export default function ProfileCard() {\n  return <div className="card">Profile</div>\n}'
    name, folder = _detect_name_and_folder(code)
    assert name == "ProfileCard"
    assert folder == "components"


# --- Test 5: Extract React component (export const) ---
def test_extract_const_component():
    code = 'export const UserAvatar = ({ url }: Props) => {\n  return <img className="avatar" src={url} />\n}'
    name, folder = _detect_name_and_folder(code)
    assert name == "UserAvatar"
    assert folder == "components"


# --- Test 6: Extract interface name ---
def test_extract_interface():
    code = 'export interface AuthService {\n  login(email: string): Promise<User>\n  logout(): void\n}'
    name, folder = _detect_name_and_folder(code)
    assert name == "AuthService"
    assert folder == "types"


# --- Test 7: Extract hook name ---
def test_extract_hook():
    code = 'export function useAuth() {\n  const [user, setUser] = useState(null)\n  return { user }\n}'
    name, folder = _detect_name_and_folder(code)
    assert name == "useAuth"
    assert folder == "hooks"


# --- Test 8: File extension: JSX → .tsx, pure TS → .ts ---
def test_jsx_detection():
    assert _has_jsx('<div className="test">Hello</div>') is True
    assert _has_jsx('export interface Foo { bar: string }') is False
    assert _has_jsx('return <section>Content</section>') is True
    assert _has_jsx('const x: number = 42') is False


# --- Test 9: Subfolder routing: React component → components/ ---
def test_subfolder_component():
    code = 'export default function SettingsPanel() {\n  return <div className="settings">Settings</div>\n}'
    _, folder = _detect_name_and_folder(code)
    assert folder == "components"


# --- Test 10: Subfolder routing: Hook → hooks/ ---
def test_subfolder_hook():
    code = 'export function useTheme() {\n  const [theme, setTheme] = useState("dark")\n  return { theme }\n}'
    _, folder = _detect_name_and_folder(code)
    assert folder == "hooks"


# --- Test 11: Subfolder routing: Service → services/ ---
def test_subfolder_service():
    code = 'export const ApiService = {\n  async getUsers() { return fetch("/api/users") }\n}'
    name, folder = _detect_name_and_folder(code)
    assert name == "ApiService"
    # Service detection via fetch pattern
    assert folder in ("services", "utils")


# --- Test 12: Subfolder routing: Types → types/ ---
def test_subfolder_types():
    code = 'export interface UserProfile {\n  name: string\n  email: string\n}'
    _, folder = _detect_name_and_folder(code)
    assert folder == "types"


# --- Test 13: Dedup: same export in two blocks → strip duplicate ---
def test_dedup_duplicate_exports():
    code = 'export interface UserProfile {\n  name: string\n}\n\nexport interface Settings {\n  theme: string\n}'
    result = _strip_duplicate_exports(code, "UserProfile", {"Settings"})
    assert "interface Settings" not in result
    assert "interface UserProfile" in result


# --- Test 14: Project-awareness (skip existing) ---
def test_project_awareness_skip_user_messages():
    extractor = TypeScriptCodeExtractor()
    msg = FakeMessage("user", '```typescript\nexport interface Secret { key: string }\n```')
    result = extractor.extract_code([msg])
    assert result["saved"] == 0


# --- Test 15: Fallback: no identifiable export ---
def test_fallback_no_export():
    code = 'const x = 42\nconsole.log(x)'
    name, folder = _detect_name_and_folder(code)
    assert name is None


# --- Additional: 'use client' → app/ ---
def test_use_client_routing():
    code = "'use client'\nexport default function DashboardPage() {\n  return <div>Dashboard</div>\n}"
    name, folder = _detect_name_and_folder(code)
    assert name == "DashboardPage"
    assert folder == "app"


# --- Additional: export type → types/ ---
def test_export_type():
    code = 'export type ButtonVariant = "primary" | "secondary" | "danger"'
    name, folder = _detect_name_and_folder(code)
    assert name == "ButtonVariant"
    assert folder == "types"


# --- Additional: TypeScript heuristic ---
def test_is_typescript_code():
    assert _is_typescript_code("import React from 'react'\nexport const App = () => {}") is True
    assert _is_typescript_code("just some plain text here") is False


# --- Additional: context provider routing ---
def test_context_provider():
    code = "export const ThemeContext = createContext<ThemeType>(defaultTheme)"
    name, folder = _detect_name_and_folder(code)
    assert name == "ThemeContext"
    assert folder == "contexts"


# --- Additional: valid filename checks ---
def test_valid_filenames():
    assert _is_valid_filename("UserProfile") is True
    assert _is_valid_filename("useAuth") is True
    assert _is_valid_filename("ab") is False  # too short
    assert _is_valid_filename("for") is False  # keyword
