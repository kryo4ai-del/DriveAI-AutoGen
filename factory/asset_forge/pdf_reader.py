"""PDF Reader for Asset Forge — extracts text, tables, and sections from Roadbook PDFs.

Uses pymupdf (fitz) for text extraction and pdfplumber for table extraction.
All operations are deterministic — no LLM calls.
"""

import logging
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

from factory.asset_forge.section_patterns import (
    CD_ROADBOOK_SECTIONS,
    DESIGN_VISION_SECTIONS,
    NUMBERED_SECTION,
)

logger = logging.getLogger(__name__)


@dataclass
class PDFPage:
    page_number: int
    text: str
    tables: list[list[list[str]]] = field(default_factory=list)


@dataclass
class PDFDocument:
    path: str
    filename: str
    total_pages: int
    pages: list[PDFPage]
    full_text: str
    total_chars: int


@dataclass
class ExtractedSections:
    asset_table: str = ""
    ki_warnings: str = ""
    screen_architecture: str = ""
    style_guide_cd: str = ""
    full_design_vision: str = ""
    color_palette: str = ""
    illustration_style: str = ""
    anti_rules: str = ""
    ceo_summary: str = ""
    total_chars: int = 0
    sections_found: list[str] = field(default_factory=list)
    sections_missing: list[str] = field(default_factory=list)

    def summary(self) -> str:
        lines = ["Extracted Sections Summary:"]
        for name in [
            "asset_table", "ki_warnings", "screen_architecture",
            "style_guide_cd", "full_design_vision", "color_palette",
            "illustration_style", "anti_rules", "ceo_summary",
        ]:
            text = getattr(self, name, "")
            status = f"{len(text)} chars" if text else "MISSING"
            lines.append(f"  {name}: {status}")
        lines.append(f"  Total: {self.total_chars} chars")
        lines.append(f"  Found: {', '.join(self.sections_found) if self.sections_found else 'none'}")
        lines.append(f"  Missing: {', '.join(self.sections_missing) if self.sections_missing else 'none'}")
        return "\n".join(lines)


class PDFReader:

    def read_pdf(self, pdf_path: str) -> PDFDocument:
        path = Path(pdf_path)
        if not path.exists():
            logger.warning("PDF not found: %s", pdf_path)
            return PDFDocument(str(path), path.name, 0, [], "", 0)

        pages = self._extract_text_pymupdf(str(path))
        if not pages:
            pages = self._extract_text_pdfplumber(str(path))

        # Table extraction via pdfplumber (overlay onto pages)
        tables_by_page = self._extract_tables_pdfplumber(str(path))
        for p in pages:
            if p.page_number in tables_by_page:
                p.tables = tables_by_page[p.page_number]

        full_text = "\n".join(p.text for p in pages)
        return PDFDocument(
            path=str(path),
            filename=path.name,
            total_pages=len(pages),
            pages=pages,
            full_text=full_text,
            total_chars=len(full_text),
        )

    def _extract_text_pymupdf(self, pdf_path: str) -> list[PDFPage]:
        try:
            import fitz
            doc = fitz.open(pdf_path)
            pages = []
            for i, page in enumerate(doc):
                text = page.get_text("text")
                pages.append(PDFPage(page_number=i, text=text))
            doc.close()
            return pages
        except ImportError:
            logger.warning("pymupdf not available, trying pdfplumber")
            return []
        except Exception as e:
            logger.warning("pymupdf failed on %s: %s", pdf_path, e)
            return []

    def _extract_text_pdfplumber(self, pdf_path: str) -> list[PDFPage]:
        try:
            import pdfplumber
            pages = []
            with pdfplumber.open(pdf_path) as pdf:
                for i, page in enumerate(pdf.pages):
                    text = page.extract_text() or ""
                    pages.append(PDFPage(page_number=i, text=text))
            return pages
        except ImportError:
            logger.warning("pdfplumber not available")
            return []
        except Exception as e:
            logger.warning("pdfplumber failed on %s: %s", pdf_path, e)
            return []

    def _extract_tables_pdfplumber(self, pdf_path: str) -> dict[int, list[list[list[str]]]]:
        result: dict[int, list] = {}
        try:
            import pdfplumber
            with pdfplumber.open(pdf_path) as pdf:
                for i, page in enumerate(pdf.pages):
                    tables = page.extract_tables()
                    if tables:
                        cleaned = []
                        for tbl in tables:
                            cleaned.append([
                                [str(cell) if cell is not None else "" for cell in row]
                                for row in tbl
                            ])
                        result[i] = cleaned
        except ImportError:
            pass
        except Exception as e:
            logger.warning("Table extraction failed: %s", e)
        return result

    # ------------------------------------------------------------------
    # Directory scanning
    # ------------------------------------------------------------------

    def read_roadbook_dir(self, roadbook_dir: str) -> dict[str, PDFDocument]:
        d = Path(roadbook_dir)
        if not d.exists():
            logger.warning("Directory not found: %s", roadbook_dir)
            return {}

        pdfs = sorted(d.glob("*.pdf"))
        if not pdfs:
            logger.warning("No PDFs found in %s", roadbook_dir)
            return {}

        docs: dict[str, PDFDocument] = {}
        for pdf_path in pdfs:
            name_lower = pdf_path.stem.lower()
            if "cd_roadbook" in name_lower or "cd_technical" in name_lower or "creative_director" in name_lower:
                key = "cd_roadbook"
            elif "design_vision" in name_lower or "design-vision" in name_lower:
                key = "design_vision"
            elif "ceo_roadbook" in name_lower or "ceo_strategic" in name_lower or "ceo_briefing" in name_lower:
                key = "ceo_roadbook"
            elif "visual_audit" in name_lower:
                key = "visual_audit"
            elif "asset_discovery" in name_lower:
                key = "asset_discovery"
            elif "asset_strategy" in name_lower:
                key = "asset_strategy"
            else:
                key = pdf_path.stem.lower()

            if key not in docs:
                logger.info("Reading %s as '%s'", pdf_path.name, key)
                docs[key] = self.read_pdf(str(pdf_path))

        # Fallback: if cd_roadbook not found, largest PDF is likely it
        if "cd_roadbook" not in docs and pdfs:
            largest = max(pdfs, key=lambda p: p.stat().st_size)
            logger.info("No CD Roadbook detected, using largest PDF: %s", largest.name)
            docs["cd_roadbook"] = self.read_pdf(str(largest))

        return docs

    # ------------------------------------------------------------------
    # Section extraction
    # ------------------------------------------------------------------

    def extract_sections(self, documents: dict[str, PDFDocument]) -> ExtractedSections:
        sections = ExtractedSections()

        # CD Roadbook
        cd = documents.get("cd_roadbook")
        if cd and cd.full_text:
            text = cd.full_text

            sections.asset_table = self._find_section(text, CD_ROADBOOK_SECTIONS["asset_table"])
            if sections.asset_table:
                sections.sections_found.append("asset_table")
            else:
                sections.sections_missing.append("asset_table")

            sections.ki_warnings = self._find_section(text, CD_ROADBOOK_SECTIONS["ki_warnings"])
            if sections.ki_warnings:
                sections.sections_found.append("ki_warnings")
            else:
                sections.sections_missing.append("ki_warnings")

            sections.screen_architecture = self._find_section(text, CD_ROADBOOK_SECTIONS["screen_architecture"])
            if sections.screen_architecture:
                sections.sections_found.append("screen_architecture")
            else:
                sections.sections_missing.append("screen_architecture")

            sections.style_guide_cd = self._find_section(text, CD_ROADBOOK_SECTIONS["style_guide"])
            if sections.style_guide_cd:
                sections.sections_found.append("style_guide_cd")
            else:
                sections.sections_missing.append("style_guide_cd")

        # Design Vision
        dv = documents.get("design_vision")
        if dv and dv.full_text:
            sections.full_design_vision = dv.full_text
            sections.sections_found.append("full_design_vision")

            sections.color_palette = self._find_section(dv.full_text, DESIGN_VISION_SECTIONS["color_palette"])
            if sections.color_palette:
                sections.sections_found.append("color_palette")

            sections.illustration_style = self._find_section(dv.full_text, DESIGN_VISION_SECTIONS["illustration_style"])
            if sections.illustration_style:
                sections.sections_found.append("illustration_style")

            sections.anti_rules = self._find_section(dv.full_text, DESIGN_VISION_SECTIONS["anti_rules"])
            if sections.anti_rules:
                sections.sections_found.append("anti_rules")

        # CEO Roadbook
        ceo = documents.get("ceo_roadbook")
        if ceo and ceo.full_text:
            sections.ceo_summary = ceo.full_text
            sections.sections_found.append("ceo_summary")

        # Total chars
        sections.total_chars = sum(
            len(getattr(sections, f, ""))
            for f in [
                "asset_table", "ki_warnings", "screen_architecture",
                "style_guide_cd", "full_design_vision", "color_palette",
                "illustration_style", "anti_rules", "ceo_summary",
            ]
        )

        return sections

    def _find_section(self, full_text: str, patterns: list[str],
                      end_patterns: list[str] = None) -> str:
        start_pos = -1
        for pat in patterns:
            m = re.search(pat, full_text, re.IGNORECASE)
            if m:
                start_pos = m.start()
                break
        if start_pos < 0:
            return ""

        # Find end: next numbered section or end_patterns
        search_from = start_pos + 10
        end_pos = len(full_text)

        if end_patterns:
            for ep in end_patterns:
                em = re.search(ep, full_text[search_from:], re.IGNORECASE)
                if em:
                    end_pos = min(end_pos, search_from + em.start())
        else:
            nm = NUMBERED_SECTION.search(full_text[search_from:])
            if nm:
                end_pos = search_from + nm.start()

        return full_text[start_pos:end_pos].strip()

    def _merge_tables_into_text(self, pages: list[PDFPage],
                                start_page: int, end_page: int) -> str:
        lines = []
        for p in pages:
            if p.page_number < start_page or p.page_number > end_page:
                continue
            for table in p.tables:
                for row in table:
                    lines.append("| " + " | ".join(row) + " |")
                lines.append("")
        return "\n".join(lines)


def read_and_extract(roadbook_dir: str) -> ExtractedSections:
    """One-liner: read all PDFs from directory and extract sections."""
    reader = PDFReader()
    docs = reader.read_roadbook_dir(roadbook_dir)
    return reader.extract_sections(docs)
