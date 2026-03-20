"""Document Secretary — transforms raw agent reports into professional PDF documents.

Usage:
    python -m factory.document_secretary.secretary --type ceo-p1 --run-dir factory/pre_production/output/003_echomatch
    python -m factory.document_secretary.secretary --type ceo-p2 --run-dir factory/market_strategy/output/001_echomatch
    python -m factory.document_secretary.secretary --type marketing --p1-dir ... --p2-dir ...
    python -m factory.document_secretary.secretary --type investor --p1-dir ... --p2-dir ...
    python -m factory.document_secretary.secretary --type tech-brief --p1-dir ... --p2-dir ...
    python -m factory.document_secretary.secretary --type legal --p1-dir ... --p2-dir ...
    python -m factory.document_secretary.secretary --type all --p1-dir ... --p2-dir ...
"""

from datetime import date
from pathlib import Path

from factory.document_secretary.pdf_builder import PdfBuilder
from factory.document_secretary.email_service import send_document
from factory.document_secretary.templates import (
    ceo_briefing_p1, ceo_briefing_p2, marketing_konzept,
    investor_summary, tech_brief, legal_summary,
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


def generate_ceo_briefing_p1(phase1_run_dir: str, send_email: bool = False) -> str:
    """Generate CEO Briefing for Phase 1."""
    print("[DocumentSecretary] Generating CEO Briefing Phase 1...")
    title = _extract_title(phase1_run_dir)
    phase1_data = _load_reports(phase1_run_dir, PHASE1_FILES)

    builder = PdfBuilder(title=f"CEO Briefing: {title}", subtitle="Phase 1 — Pre-Production Analysis")
    ceo_briefing_p1.generate(phase1_data, builder)

    return _save_pdf(builder, f"CEO_Briefing_Phase1_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"CEO Briefing Phase 1: {title}", f"Anbei das CEO Briefing fuer {title} (Phase 1).")


def generate_ceo_briefing_p2(phase2_run_dir: str, phase1_run_dir: str = None, send_email: bool = False) -> str:
    """Generate CEO Briefing for Phase 2."""
    print("[DocumentSecretary] Generating CEO Briefing Phase 2...")
    title = _extract_title(phase2_run_dir)
    phase2_data = _load_reports(phase2_run_dir, PHASE2_FILES)

    builder = PdfBuilder(title=f"CEO Briefing: {title}", subtitle="Phase 2 — Strategie & Positionierung")
    ceo_briefing_p2.generate(phase2_data, builder)

    return _save_pdf(builder, f"CEO_Briefing_Phase2_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"CEO Briefing Phase 2: {title}", f"Anbei das CEO Briefing fuer {title} (Phase 2).")


def generate_marketing_konzept(phase1_run_dir: str, phase2_run_dir: str, send_email: bool = False) -> str:
    """Generate standalone Marketing Konzept."""
    print("[DocumentSecretary] Generating Marketing Konzept...")
    title = _extract_title(phase1_run_dir)
    phase1_data = _load_reports(phase1_run_dir, PHASE1_FILES)
    phase2_data = _load_reports(phase2_run_dir, PHASE2_FILES)

    builder = PdfBuilder(title=f"Marketing-Konzept: {title}", subtitle="Vollstaendiges Marketing-Konzept fuer App-Launch")
    marketing_konzept.generate(phase1_data, phase2_data, builder)

    return _save_pdf(builder, f"Marketing_Konzept_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Marketing-Konzept: {title}", f"Anbei das Marketing-Konzept fuer {title}.")


def generate_investor_summary(phase1_run_dir: str, phase2_run_dir: str, send_email: bool = False) -> str:
    """Generate Investor Pitch Summary."""
    print("[DocumentSecretary] Generating Investor Summary...")
    title = _extract_title(phase1_run_dir)
    phase1_data = _load_reports(phase1_run_dir, PHASE1_FILES)
    phase2_data = _load_reports(phase2_run_dir, PHASE2_FILES)

    builder = PdfBuilder(title=f"Investment Summary: {title}", subtitle="DriveAI Swarm Factory")
    investor_summary.generate(phase1_data, phase2_data, builder)

    return _save_pdf(builder, f"Investor_Summary_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Investment Summary: {title}", f"Anbei das Investment Summary fuer {title}.")


def generate_tech_brief(phase1_run_dir: str, phase2_run_dir: str, send_email: bool = False) -> str:
    """Generate Technical Brief."""
    print("[DocumentSecretary] Generating Tech Brief...")
    title = _extract_title(phase1_run_dir)
    phase1_data = _load_reports(phase1_run_dir, PHASE1_FILES)
    phase2_data = _load_reports(phase2_run_dir, PHASE2_FILES)

    builder = PdfBuilder(title=f"Technical Brief: {title}", subtitle="Development Architecture & Timeline")
    tech_brief.generate(phase1_data, phase2_data, builder)

    return _save_pdf(builder, f"Tech_Brief_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Technical Brief: {title}", f"Anbei das Technical Brief fuer {title}.")


def generate_legal_summary(phase1_run_dir: str, phase2_run_dir: str, send_email: bool = False) -> str:
    """Generate Legal & Compliance Summary."""
    print("[DocumentSecretary] Generating Legal Summary...")
    title = _extract_title(phase1_run_dir)
    phase1_data = _load_reports(phase1_run_dir, PHASE1_FILES)
    phase2_data = _load_reports(phase2_run_dir, PHASE2_FILES)

    builder = PdfBuilder(
        title=f"Legal & Compliance Summary: {title}",
        subtitle="Rechtliche Ersteinschaetzung — zur Vorlage bei Rechtsberatung",
    )
    legal_summary.generate(phase1_data, phase2_data, builder)

    return _save_pdf(builder, f"Legal_Summary_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Legal Summary: {title}", f"Anbei die Legal Summary fuer {title}.")


def generate_all(phase1_run_dir: str, phase2_run_dir: str, send_email: bool = False) -> list[str]:
    """Generate ALL 6 document types."""
    print("[DocumentSecretary] Generating ALL documents...\n")
    files = []
    files.append(generate_ceo_briefing_p1(phase1_run_dir, send_email=send_email))
    files.append(generate_ceo_briefing_p2(phase2_run_dir, send_email=send_email))
    files.append(generate_marketing_konzept(phase1_run_dir, phase2_run_dir, send_email=send_email))
    files.append(generate_investor_summary(phase1_run_dir, phase2_run_dir, send_email=send_email))
    files.append(generate_tech_brief(phase1_run_dir, phase2_run_dir, send_email=send_email))
    files.append(generate_legal_summary(phase1_run_dir, phase2_run_dir, send_email=send_email))
    return files


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI Document Secretary — Professional PDF Generator")
    parser.add_argument("--type", type=str, required=True,
                        choices=["ceo-p1", "ceo-p2", "marketing", "investor", "tech-brief", "legal", "all"],
                        help="Document type to generate")
    parser.add_argument("--run-dir", type=str, help="Run directory (for ceo-p1 or ceo-p2)")
    parser.add_argument("--p1-dir", type=str, help="Phase 1 run directory")
    parser.add_argument("--p2-dir", type=str, help="Phase 2 run directory")
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
            parser.error("--p1-dir and --p2-dir required (or --run-dir for single-phase types)")
        funcs = {
            "marketing": generate_marketing_konzept,
            "investor": generate_investor_summary,
            "tech-brief": generate_tech_brief,
            "legal": generate_legal_summary,
        }
        filepath = funcs[args.type](p1, p2, send_email=args.send_email)
        print(f"\nDokument erstellt: {filepath}")

    elif args.type == "all":
        p1 = args.p1_dir
        p2 = args.p2_dir
        if not p1 or not p2:
            parser.error("--p1-dir and --p2-dir required for --type all")
        files = generate_all(p1, p2, send_email=args.send_email)
        print(f"\n{len(files)} Dokumente erstellt:")
        for f in files:
            print(f"  {f}")
