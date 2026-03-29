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

from factory.brand.brand_loader import load_brand_context, get_logo_path, get_brand_info
from factory.document_secretary.pdf_builder import PdfBuilder
from factory.document_secretary.email_service import send_document
from factory.document_secretary.templates import (
    ceo_briefing_p1, ceo_briefing_p2, marketing_konzept,
    investor_summary, tech_brief, legal_summary,
    feature_list, mvp_scope, screen_architecture,
    asset_discovery_pdf, asset_strategy_pdf, visual_audit_pdf,
    design_vision_pdf,
    ceo_roadbook_pdf, cd_roadbook_pdf,
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

K5_FILES = {
    "asset_discovery": "asset_discovery.md",
    "asset_strategy": "asset_strategy.md",
    "visual_consistency": "visual_consistency.md",
}

K45_FILES = {
    "trend_breaker_report": "trend_breaker_report.md",
    "emotion_architect_report": "emotion_architect_report.md",
    "design_vision_document": "design_vision_document.md",
}

K6_FILES = {
    "ceo_strategic_roadbook": "ceo_strategic_roadbook.md",
    "cd_technical_roadbook": "cd_technical_roadbook.md",
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


# --- Kapitel 5 generators ---

def generate_asset_discovery(k5_run_dir: str, send_email: bool = False) -> str:
    """Generate Asset Discovery PDF from Kapitel 5 output."""
    print("[DocumentSecretary] Generating Asset Discovery PDF...")
    title = _extract_title(k5_run_dir)
    data = _load_reports(k5_run_dir, K5_FILES)
    builder = PdfBuilder(title=f"Asset-Discovery: {title}",
                         subtitle="Vollstaendige visuelle Asset-Liste")
    asset_discovery_pdf.generate(data, builder)
    return _save_pdf(builder, f"Asset_Discovery_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Asset-Discovery: {title}", f"Asset-Discovery fuer {title}.")


def generate_asset_strategy(k5_run_dir: str, send_email: bool = False) -> str:
    """Generate Asset Strategy PDF from Kapitel 5 output."""
    print("[DocumentSecretary] Generating Asset Strategy PDF...")
    title = _extract_title(k5_run_dir)
    data = _load_reports(k5_run_dir, K5_FILES)
    builder = PdfBuilder(title=f"Asset-Strategie: {title}",
                         subtitle="Stil-Guide, Beschaffung & Uebergabe-Protokoll")
    asset_strategy_pdf.generate(data, builder)
    return _save_pdf(builder, f"Asset_Strategy_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Asset-Strategie: {title}", f"Asset-Strategie fuer {title}.")


def generate_visual_audit(k5_run_dir: str, send_email: bool = False) -> str:
    """Generate Visual Audit Report PDF from Kapitel 5 output."""
    print("[DocumentSecretary] Generating Visual Audit PDF...")
    title = _extract_title(k5_run_dir)
    data = _load_reports(k5_run_dir, K5_FILES)
    builder = PdfBuilder(title=f"Visual Audit Report: {title}",
                         subtitle="Ampel-Bewertung, KI-Warnungen & Handlungsanweisungen")
    visual_audit_pdf.generate(data, builder)
    return _save_pdf(builder, f"Visual_Audit_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Visual Audit: {title}", f"Visual Audit Report fuer {title}.")


# --- Kapitel 4.5 generator ---

def generate_design_vision(k45_run_dir: str, send_email: bool = False) -> str:
    """Generate Design Vision PDF from Kapitel 4.5 output."""
    print("[DocumentSecretary] Generating Design Vision PDF...")
    title = _extract_title(k45_run_dir)
    data = _load_reports(k45_run_dir, K45_FILES)
    builder = PdfBuilder(title=f"Design Vision: {title}",
                         subtitle="Verbindliches Design-Dokument fuer die Produktionslinie")
    design_vision_pdf.generate(data, builder)
    return _save_pdf(builder, f"Design_Vision_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"Design Vision: {title}", f"Design Vision fuer {title}.")


# --- Kapitel 6 generators ---

def generate_ceo_roadbook(k6_run_dir: str, send_email: bool = False) -> str:
    print("[DocumentSecretary] Generating CEO Roadbook PDF...")
    title = _extract_title(k6_run_dir)
    data = _load_reports(k6_run_dir, K6_FILES)
    builder = PdfBuilder(title=f"CEO Strategic Roadbook: {title}", subtitle="Strategisches Gesamtdokument")
    ceo_roadbook_pdf.generate(data, builder)
    return _save_pdf(builder, f"CEO_Roadbook_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"CEO Strategic Roadbook: {title}", f"CEO Roadbook fuer {title}.")


def generate_cd_roadbook(k6_run_dir: str, send_email: bool = False) -> str:
    print("[DocumentSecretary] Generating CD Roadbook PDF...")
    title = _extract_title(k6_run_dir)
    data = _load_reports(k6_run_dir, K6_FILES)
    builder = PdfBuilder(title=f"CD Technical Roadbook: {title}",
                         subtitle="VERBINDLICH fuer alle Produktionslinien")
    cd_roadbook_pdf.generate(data, builder)
    return _save_pdf(builder, f"CD_Roadbook_{title.replace(' ', '_')}_{date.today().isoformat()}.pdf",
                     send_email, f"CD Technical Roadbook: {title}", f"CD Roadbook fuer {title}.")


# --- Generate ALL ---

def generate_all(phase1_run_dir: str, phase2_run_dir: str, k4_run_dir: str = None, k45_run_dir: str = None, k5_run_dir: str = None, k6_run_dir: str = None, send_email: bool = False) -> list[str]:
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
    if k45_run_dir:
        files.append(generate_design_vision(k45_run_dir, send_email=send_email))
    if k5_run_dir:
        files.append(generate_asset_discovery(k5_run_dir, send_email=send_email))
        files.append(generate_asset_strategy(k5_run_dir, send_email=send_email))
        files.append(generate_visual_audit(k5_run_dir, send_email=send_email))
    if k6_run_dir:
        files.append(generate_ceo_roadbook(k6_run_dir, send_email=send_email))
        files.append(generate_cd_roadbook(k6_run_dir, send_email=send_email))
    return files


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI Document Secretary — Professional PDF Generator")
    parser.add_argument("--type", type=str, required=True,
                        choices=["ceo-p1", "ceo-p2", "marketing", "investor", "tech-brief", "legal",
                                 "features", "mvp-scope", "screens", "design-vision",
                                 "asset-discovery", "asset-strategy", "visual-audit",
                                 "ceo-roadbook", "cd-roadbook", "all"],
                        help="Document type to generate")
    parser.add_argument("--run-dir", type=str, help="Run directory (for ceo-p1 or ceo-p2)")
    parser.add_argument("--p1-dir", type=str, help="Phase 1 run directory")
    parser.add_argument("--p2-dir", type=str, help="Phase 2 run directory")
    parser.add_argument("--k4-dir", type=str, help="Kapitel 4 run directory")
    parser.add_argument("--k45-dir", type=str, help="Kapitel 4.5 run directory")
    parser.add_argument("--k5-dir", type=str, help="Kapitel 5 run directory")
    parser.add_argument("--k6-dir", type=str, help="Kapitel 6 run directory")
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

    elif args.type == "design-vision":
        k45 = args.k45_dir
        if not k45:
            parser.error("--k45-dir required for design-vision")
        filepath = generate_design_vision(k45, send_email=args.send_email)
        print(f"\nDokument erstellt: {filepath}")

    elif args.type in ("ceo-roadbook", "cd-roadbook"):
        k6 = args.k6_dir
        if not k6:
            parser.error("--k6-dir required for ceo-roadbook/cd-roadbook")
        funcs = {"ceo-roadbook": generate_ceo_roadbook, "cd-roadbook": generate_cd_roadbook}
        filepath = funcs[args.type](k6, send_email=args.send_email)
        print(f"\nDokument erstellt: {filepath}")

    elif args.type in ("asset-discovery", "asset-strategy", "visual-audit"):
        k5 = args.k5_dir
        if not k5:
            parser.error("--k5-dir required for asset-discovery/asset-strategy/visual-audit")
        funcs = {
            "asset-discovery": generate_asset_discovery,
            "asset-strategy": generate_asset_strategy,
            "visual-audit": generate_visual_audit,
        }
        filepath = funcs[args.type](k5, send_email=args.send_email)
        print(f"\nDokument erstellt: {filepath}")

    elif args.type == "all":
        p1 = args.p1_dir
        p2 = args.p2_dir
        k4 = args.k4_dir
        k45 = args.k45_dir
        k5 = args.k5_dir
        k6 = args.k6_dir
        if not p1 or not p2:
            parser.error("--p1-dir and --p2-dir required for --type all")
        files = generate_all(p1, p2, k4_run_dir=k4, k45_run_dir=k45, k5_run_dir=k5, k6_run_dir=k6, send_email=args.send_email)
        print(f"\n{len(files)} Dokumente erstellt:")
        for f in files:
            print(f"  {f}")
