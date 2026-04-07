"""Tier 2+3: LLM-basierte Fixes. Standalone — braucht nur litellm."""
import os
import litellm
from dotenv import load_dotenv

# .env laden
load_dotenv(os.path.join(os.path.dirname(os.path.dirname(__file__)), ".env"))


class LLMRepairer:
    def __init__(self, config: dict):
        self.tier2_model = config.get("repair_models", {}).get("tier2", "claude-sonnet-4-6")
        self.tier3_model = config.get("repair_models", {}).get("tier3", "claude-opus-4-6")
        self.total_cost = 0.0

    def fix_file(self, filepath: str, errors: list, tier: int = 2) -> bool:
        """Fix eine Swift-Datei via LLM."""
        content = open(filepath, encoding="utf-8").read()

        error_desc = "\n".join(f"Line {e.line}: {e.message}" for e in errors)
        model = self.tier2_model if tier == 2 else self.tier3_model

        # LiteLLM model format
        if "claude" in model:
            llm_model = f"anthropic/{model}"
        elif "gpt" in model:
            llm_model = model
        elif "gemini" in model:
            llm_model = f"gemini/{model}"
        else:
            llm_model = f"mistral/{model}"

        try:
            response = litellm.completion(
                model=llm_model,
                messages=[
                    {"role": "system", "content": "You are a Swift compiler error fixer. Return ONLY the complete fixed Swift file. No explanations, no markdown fences."},
                    {"role": "user", "content": f"Fix this Swift file. Xcode errors:\n\n{error_desc}\n\nFile:\n\n```swift\n{content}\n```\n\nReturn ONLY valid Swift code."},
                ],
                max_tokens=4096,
                temperature=0.0,
            )

            fixed = response.choices[0].message.content.strip()
            # Strip markdown fences
            if fixed.startswith("```"):
                fixed = fixed.split("\n", 1)[1].rsplit("```", 1)[0].strip()

            cost = litellm.completion_cost(response)
            self.total_cost += cost

            if fixed and len(fixed) > 50:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(fixed)
                print(f"      LLM Fix (Tier {tier}, {model}): {os.path.basename(filepath)} — ${cost:.4f}")
                return True

        except Exception as e:
            print(f"      LLM Error: {e}")

        return False
