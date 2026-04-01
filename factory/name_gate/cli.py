"""Name Gate CLI — Command-line interface for name validation.

Usage:
    python -m factory.name_gate validate --name EchoMatch --idea "Social matching app"
    python -m factory.name_gate alternatives --idea "Social matching app"
    python -m factory.name_gate lock --name EchoMatch
    python -m factory.name_gate status --name EchoMatch
"""

from __future__ import annotations

import argparse
import json
import sys

from factory.name_gate.orchestrator import NameGateOrchestrator


def _cmd_validate(args: argparse.Namespace) -> None:
    """Run full name validation and print JSON report."""
    orch = NameGateOrchestrator(profile=args.profile, use_stubs=args.stubs)
    report = orch.validate_name(args.name, args.idea, args.template or "")
    print(json.dumps(report.to_dict(), indent=2, ensure_ascii=False))


def _cmd_alternatives(args: argparse.Namespace) -> None:
    """Generate and validate alternative names."""
    rejected = args.rejected.split(",") if args.rejected else []
    orch = NameGateOrchestrator(profile=args.profile, use_stubs=args.stubs)
    reports = orch.request_alternatives(
        args.idea, args.template or "", rejected,
    )
    output = [r.to_dict() for r in reports]
    print(json.dumps(output, indent=2, ensure_ascii=False))


def _cmd_lock(args: argparse.Namespace) -> None:
    """Lock a validated name for project creation."""
    orch = NameGateOrchestrator(profile=args.profile, use_stubs=args.stubs)

    # Check if already locked
    existing = orch.get_status(args.name)
    if existing and existing.get("locked"):
        print(json.dumps(existing, indent=2, ensure_ascii=False))
        return

    result = orch.lock_from_saved(args.name)
    print(json.dumps(result, indent=2, ensure_ascii=False))


def _cmd_generate(args: argparse.Namespace) -> None:
    """Generate name suggestions and validate each."""
    orch = NameGateOrchestrator(profile=args.profile, use_stubs=args.stubs)
    result = orch.generate_and_validate(
        args.idea, args.template or "", args.count,
    )
    print(json.dumps(result, indent=2, ensure_ascii=False))


def _cmd_status(args: argparse.Namespace) -> None:
    """Check if a name is locked."""
    orch = NameGateOrchestrator(profile=args.profile, use_stubs=args.stubs)
    status = orch.get_status(args.name)
    if status is None:
        print(json.dumps({"name": args.name, "locked": False}))
    else:
        print(json.dumps(status, indent=2, ensure_ascii=False))


def build_parser() -> argparse.ArgumentParser:
    """Build the argument parser."""
    parser = argparse.ArgumentParser(
        prog="name_gate",
        description="Name Gate — Pre-Pipeline Name Validation (NGO-01)",
    )
    parser.add_argument(
        "--profile", default="dev",
        help="LLM profile (default: dev)",
    )
    parser.add_argument(
        "--stubs", action="store_true", default=False,
        help="Use deterministic stubs instead of real agents",
    )

    subs = parser.add_subparsers(dest="command", required=True)

    # validate
    p_val = subs.add_parser("validate", help="Validate a project name")
    p_val.add_argument("--name", required=True, help="Name to validate")
    p_val.add_argument("--idea", required=True, help="Project idea description")
    p_val.add_argument("--template", default="", help="Project template type")

    # alternatives
    p_alt = subs.add_parser("alternatives", help="Generate alternative names")
    p_alt.add_argument("--idea", required=True, help="Project idea description")
    p_alt.add_argument("--template", default="", help="Project template type")
    p_alt.add_argument("--rejected", default="", help="Comma-separated rejected names")

    # generate
    p_gen = subs.add_parser("generate", help="Generate and validate name suggestions")
    p_gen.add_argument("--idea", required=True, help="Project idea description")
    p_gen.add_argument("--template", default="", help="Project template type")
    p_gen.add_argument("--count", type=int, default=3, help="Number of suggestions (default: 3)")

    # lock
    p_lock = subs.add_parser("lock", help="Lock a validated name")
    p_lock.add_argument("--name", required=True, help="Name to lock")

    # status
    p_st = subs.add_parser("status", help="Check name lock status")
    p_st.add_argument("--name", required=True, help="Name to check")

    return parser


def main(argv: list | None = None) -> None:
    """CLI entry point."""
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.command == "validate":
        _cmd_validate(args)
    elif args.command == "alternatives":
        _cmd_alternatives(args)
    elif args.command == "generate":
        _cmd_generate(args)
    elif args.command == "lock":
        _cmd_lock(args)
    elif args.command == "status":
        _cmd_status(args)
    else:
        parser.print_help()
        sys.exit(1)
