"""Document Secretary — transforms raw agent reports into professional PDF documents.

Usage:
    python -m factory.document_secretary.secretary --type ceo-p1 --run-dir factory/pre_production/output/003_echomatch
    python -m factory.document_secretary.secretary --type ceo-p2 --run-dir factory/market_strategy/output/001_echomatch
    python -m factory.document_secretary.secretary --type marketing --p1-dir ... --p2-dir ...
    python -m factory.document_secretary.secretary --type investor --p1-dir ... --p2-dir ...
    python -m factory.document_secretary.secretary --type tech-brief --p1-dir ... --p2-dir ...
    python -m factory.document_secretary.secretary --type legal --p1-dir ... --p2-dir ...
    python -m factory.document_secretary.secretary --type features --k4-dir factory/mvp_scope/output/001_echomatch
    python -m factory.document_secretary.secretary --type mvp-scope --k4-dir ...
    python -m factory.document_secretary.secretary --type screens --k4-dir ...
    python -m factory.document_secretary.secretary --type all --p1-dir ... --p2-dir ... --k4-dir ...
"""

from datetime import date
from pathlib import Path

from factory.document_secretary.pdf_builder import PdfBuilder
from factory.document_secretary.email_service import send_document
from factory.document_secretary.templates import (
    ceo_briefing_p1, ceo_briefing_p2, marketing_konzept,
    investor_summary, tech_brief, legal_summary,
    feature_list, mvp_scope, screen_architecture,
)

OUTPUT_DIR = Path(__file__).resolve().parent / "output"

PHASE1_FILES = {
    "concept_brief": "concept_brief.md",
    "trend_report": "trend_report.md",
    "competitive_report": "competitive_report.md",
    "audience_profile": "audience_profile.md",
    "legal_report": "legal_report.md",
    "risk_assessment": "risk_assessment.md",
}

PHASE2_FILES = {
    "platform_strategy": "platform_strategy.md",
    "monetization_report": "monetization_report.md",
    "marketing_strategy": "marketing_strategy.md",
    "release_plan": "release_plan.md",
    "cost_calculation": "cost_calculation.md",
}

K4_FILES = {
    "feature_list": "feature_list.md",
    "feature_prioritization": "feature_prioritization.md",
    "screen_architecture": "screen_architecture.md",
}


def _load_reports(run_dir: str, file_map: dict) -> dict:
    """Load report files from a run directory."""
    run_path = Path(run_dir).resolve()
    data = {}
    for key, filename in file_map.items():
        filepath = run_path / filename
        if filepath.exists():
            data[key] = filepath.read_text(encoding="utf-8")
        else:
            data[key] = ""
            print(f"[DocumentSecretary] WARNING: {filename} not found in {run_dir}")
    return data


def _extract_title(run_dir: str) -> str:
    """Extract idea title from run directory name."""
    name = Path(run_dir).name
    parts = name.split("_", 1)
    return parts[1].replace("_", " ").title() if len(parts) > 1 else name


def _save_pdf(builder: PdfBuilder, filename: str, send_email: bool, subject: str, body: str) -> str:
    """Save PDF and optionally send via email."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    filepath = str(OUTPUT_DIR / filename)
    builder.save_pdf(filepath)
    print(f"[DocumentSecretary] Saved: {filepath}")
    if send_email:
        send_document(filepath, subject=subject, body=body)
    return filepath


# --- Phase 1 + 2 generators (unchanged) ---

def generate_ceo_briefing_p1(phase1_run_dir: str, send_email: bool = False) -> str:
    print("[DocumentSecretary] Generating CEO Briefing Phase 1...")
    title = _extract_title(phase1_run_dir)
    data = _load_reports(phase1_run_dir, PHASE1_FILES)
    builder = PdfBuilder(title=f"CEO Briefing: {title}", subtitle="Phase 1 — Pre-Production Analysis")
    ceo_briefing_p1.generate(data, builder)
    return _save_pdf(builder, f"CEO_Briefing_Phase1_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"CEO Briefing Phase 1: {title}", f"CEO Briefing fuer {title} (Phase 1).")


def generate_ceo_briefing_p2(phase2_run_dir: str, phase1_run_dir: str = None, send_email: bool = False) -> str:
    print("[DocumentSecretary] Generating CEO Briefing Phase 2...")
    title = _extract_title(phase2_run_dir)
    data = _load_reports(phase2_run_dir, PHASE2_FILES)
    builder = PdfBuilder(title=f"CEO Briefing: {title}", subtitle="Phase 2 — Strategie & Positionierung")
    ceo_briefing_p2.generate(data, builder)
    return _save_pdf(builder, f"CEO_Briefing_Phase2_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"CEO Briefing Phase 2: {title}", f"CEO Briefing fuer {title} (Phase 2).")


def generate_marketing_konzept(phase1_run_dir: str, phase2_run_dir: str, send_email: bool = False) -> str:
    print("[DocumentSecretary] Generating Marketing Konzept...")
    title = _extract_title(phase1_run_dir)
    p1 = _load_reports(phase1_run_dir, PHASE1_FILES)
    p2 = _load_reports(phase2_run_dir, PHASE2_FILES)
    builder = PdfBuilder(title=f"Marketing-Konzept: {title}", subtitle="Vollstaendiges Marketing-Konzept fuer App-Launch")
    marketing_konzept.generate(p1, p2, builder)
    return _save_pdf(builder, f"Marketing_Konzept_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Marketing-Konzept: {title}", f"Marketing-Konzept fuer {title}.")


def generate_investor_summary(phase1_run_dir: str, phase2_run_dir: str, send_email: bool = False) -> str:
    print("[DocumentSecretary] Generating Investor Summary...")
    title = _extract_title(phase1_run_dir)
    p1 = _load_reports(phase1_run_dir, PHASE1_FILES)
    p2 = _load_reports(phase2_run_dir, PHASE2_FILES)
    builder = PdfBuilder(title=f"Investment Summary: {title}", subtitle="DriveAI Swarm Factory")
    investor_summary.generate(p1, p2, builder)
    return _save_pdf(builder, f"Investor_Summary_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Investment Summary: {title}", f"Investment Summary fuer {title}.")


def generate_tech_brief(phase1_run_dir: str, phase2_run_dir: str, send_email: bool = False) -> str:
    print("[DocumentSecretary] Generating Tech Brief...")
    title = _extract_title(phase1_run_dir)
    p1 = _load_reports(phase1_run_dir, PHASE1_FILES)
    p2 = _load_reports(phase2_run_dir, PHASE2_FILES)
    builder = PdfBuilder(title=f"Technical Brief: {title}", subtitle="Development Architecture & Timeline")
    tech_brief.generate(p1, p2, builder)
    return _save_pdf(builder, f"Tech_Brief_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Technical Brief: {title}", f"Technical Brief fuer {title}.")


def generate_legal_summary(phase1_run_dir: str, phase2_run_dir: str, send_email: bool = False) -> str:
    print("[DocumentSecretary] Generating Legal Summary...")
    title = _extract_title(phase1_run_dir)
    p1 = _load_reports(phase1_run_dir, PHASE1_FILES)
    p2 = _load_reports(phase2_run_dir, PHASE2_FILES)
    builder = PdfBuilder(title=f"Legal & Compliance Summary: {title}",
                         subtitle="Rechtliche Ersteinschaetzung — zur Vorlage bei Rechtsberatung")
    legal_summary.generate(p1, p2, builder)
    return _save_pdf(builder, f"Legal_Summary_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Legal Summary: {title}", f"Legal Summary fuer {title}.")


# --- Kapitel 4 generators (NEW) ---

def generate_feature_list(k4_run_dir: str, send_email: bool = False) -> str:
    """Generate Feature-Liste PDF from Kapitel 4 output."""
    print("[DocumentSecretary] Generating Feature-Liste PDF...")
    title = _extract_title(k4_run_dir)
    data = _load_reports(k4_run_dir, K4_FILES)
    builder = PdfBuilder(title=f"Feature-Liste: {title}",
                         subtitle="Vollstaendige Feature-Extraction mit Tech-Stack-Check")
    feature_list.generate(data, builder)
    return _save_pdf(builder, f"Feature_Liste_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Feature-Liste: {title}", f"Feature-Liste fuer {title}.")


def generate_mvp_scope(k4_run_dir: str, send_email: bool = False) -> str:
    """Generate MVP Scope PDF from Kapitel 4 output."""
    print("[DocumentSecretary] Generating MVP Scope PDF...")
    title = _extract_title(k4_run_dir)
    data = _load_reports(k4_run_dir, K4_FILES)
    builder = PdfBuilder(title=f"MVP Feature Scope: {title}",
                         subtitle="Phase A (Soft-Launch) & Phase B (Full Production)")
    mvp_scope.generate(data, builder)
    return _save_pdf(builder, f"MVP_Scope_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"MVP Scope: {title}", f"MVP Scope fuer {title}.")


def generate_screen_architecture(k4_run_dir: str, send_email: bool = False) -> str:
    """Generate Screen Architecture PDF from Kapitel 4 output."""
    print("[DocumentSecretary] Generating Screen Architecture PDF...")
    title = _extract_title(k4_run_dir)
    data = _load_reports(k4_run_dir, K4_FILES)
    builder = PdfBuilder(title=f"Screen-Architektur: {title}",
                         subtitle="Phase A MVP — Screens, Navigation & User Flows")
    screen_architecture.generate(data, builder)
    return _save_pdf(builder, f"Screen_Architecture_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Screen-Architektur: {title}", f"Screen-Architektur fuer {title}.")


# --- Generate ALL ---

def generate_all(phase1_run_dir: str, phase2_run_dir: str, k4_run_dir: str = None, send_email: bool = False) -> list[str]:
    """Generate ALL document types."""
    print("[DocumentSecretary] Generating ALL documents...\n")
    files = []
    files.append(generate_ceo_briefing_p1(phase1_run_dir, send_email=send_email))
    files.append(generate_ceo_briefing_p2(phase2_run_dir, send_email=send_email))
    files.append(generate_marketing_konzept(phase1_run_dir, phase2_run_dir, send_email=send_email))
    files.append(generate_investor_summary(phase1_run_dir, phase2_run_dir, send_email=send_email))
    files.append(generate_tech_brief(phase1_run_dir, phase2_run_dir, send_email=send_email))
    files.append(generate_legal_summary(phase1_run_dir, phase2_run_dir, send_email=send_email))
    if k4_run_dir:
        files.append(generate_feature_list(k4_run_dir, send_email=send_email))
        files.append(generate_mvp_scope(k4_run_dir, send_email=send_email))
        files.append(generate_screen_architecture(k4_run_dir, send_email=send_email))
    return files


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI Document Secretary — Professional PDF Generator")
    parser.add_argument("--type", type=str, required=True,
                        choices=["ceo-p1", "ceo-p2", "marketing", "investor", "tech-brief", "legal",
                                 "features", "mvp-scope", "screens", "all"],
                        help="Document type to generate")
    parser.add_argument("--run-dir", type=str, help="Run directory (for ceo-p1 or ceo-p2)")
    parser.add_argument("--p1-dir", type=str, help="Phase 1 run directory")
    parser.add_argument("--p2-dir", type=str, help="Phase 2 run directory")
    parser.add_argument("--k4-dir", type=str, help="Kapitel 4 run directory")
    parser.add_argument("--send-email", action="store_true", help="Send document via email")
    args = parser.parse_args()

    if args.type == "ceo-p1":
        if not args.run_dir:
            parser.error("--run-dir required for ceo-p1")
        filepath = generate_ceo_briefing_p1(args.run_dir, send_email=args.send_email)
        print(f"\nDokument erstellt: {filepath}")

    elif args.type == "ceo-p2":
        if not args.run_dir:
            parser.error("--run-dir required for ceo-p2")
        filepath = generate_ceo_briefing_p2(args.run_dir, send_email=args.send_email)
        print(f"\nDokument erstellt: {filepath}")

    elif args.type in ("marketing", "investor", "tech-brief", "legal"):
        p1 = args.p1_dir or args.run_dir
        p2 = args.p2_dir or args.run_dir
        if not p1 or not p2:
            parser.error("--p1-dir and --p2-dir required")
        funcs = {
            "marketing": generate_marketing_konzept,
            "investor": generate_investor_summary,
            "tech-brief": generate_tech_brief,
            "legal": generate_legal_summary,
        }
        filepath = funcs[args.type](p1, p2, send_email=args.send_email)
        print(f"\nDokument erstellt: {filepath}")

    elif args.type in ("features", "mvp-scope", "screens"):
        k4 = args.k4_dir
        if not k4:
            parser.error("--k4-dir required for features/mvp-scope/screens")
        funcs = {
            "features": generate_feature_list,
            "mvp-scope": generate_mvp_scope,
            "screens": generate_screen_architecture,
        }
        filepath = funcs[args.type](k4, send_email=args.send_email)
        print(f"\nDokument erstellt: {filepath}")

    elif args.type == "all":
        p1 = args.p1_dir
        p2 = args.p2_dir
        k4 = args.k4_dir
        if not p1 or not p2:
            parser.error("--p1-dir and --p2-dir required for --type all")
        files = generate_all(p1, p2, k4_run_dir=k4, send_email=args.send_email)
        print(f"\n{len(files)} Dokumente erstellt:")
        for f in files:
            print(f"  {f}")
