"""Projects — View registered projects, bootstrapped projects, and steering info."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Projects — Factory Control Center", page_icon="📦", layout="wide")

st.title("Projects")
reader = StoreReader()

projects = reader.projects()
bootstrap = reader.bootstrap()
ideas = reader.ideas()
specs = reader.specs()
orchestration = reader.orchestration()
compliance_reports = reader.compliance()
a11y_reports = reader.accessibility()

# --- Project Status Groups ---
st.subheader("Project Status")

if projects:
    # Group by status
    active_projects = [p for p in projects if p.get("active", False)]
    inactive_projects = [p for p in projects if not p.get("active", False)]

    STATUS_ORDER = ["active", "mvp-complete", "planning", "released", "paused", "archived"]

    status_groups = {}
    for p in projects:
        s = p.get("status", "unknown")
        status_groups.setdefault(s, []).append(p)

    status_icons = {
        "active": "🟢", "mvp-complete": "✅", "planning": "📝",
        "released": "🚀", "paused": "⏸️", "archived": "📦",
    }

    group_cols = st.columns(min(len(status_groups), 4))
    for i, status in enumerate(sorted(status_groups.keys(), key=lambda s: STATUS_ORDER.index(s) if s in STATUS_ORDER else 99)):
        group = status_groups[status]
        icon = status_icons.get(status, "⚪")
        with group_cols[i % len(group_cols)]:
            st.metric(f"{icon} {status}", len(group))
            for p in group:
                st.caption(f"{p.get('name', p.get('id', '?'))} ({p.get('platform', '?')})")

    st.markdown("---")
else:
    st.info("No projects registered yet.")

# --- Detailed Project Cards ---
st.subheader("Registered Projects")
st.caption(f"{len(projects)} registered projects")

if projects:
    for p in projects:
        pid = p.get("id", "?")
        name = p.get("name", pid)
        platform = p.get("platform", "?")
        status = p.get("status", "?")
        active = p.get("active", False)
        icon = "🟢" if active else "⚪"

        # Linked data counts
        proj_ideas = [i for i in ideas if i.get("project") == pid]
        proj_specs = [s for s in specs if s.get("project") == pid]
        proj_plans = [pl for pl in orchestration if pl.get("project") == pid]
        proj_compliance = [c for c in compliance_reports if c.get("project") == pid]
        proj_a11y = [r for r in a11y_reports if r.get("project") == pid]

        with st.expander(f"{icon} {name} — {platform} — {status}"):
            c1, c2, c3 = st.columns(3)
            c1.markdown(f"**ID**: `{pid}`")
            c2.markdown(f"**Platform**: `{platform}`")
            c3.markdown(f"**Status**: `{status}`")

            if p.get("description"):
                st.markdown(f"**Description**: {p['description']}")

            # Steering metrics
            st.markdown("---")
            m1, m2, m3, m4, m5 = st.columns(5)

            inbox_count = sum(1 for i in proj_ideas if i.get("status") == "inbox")
            m1.metric("Ideas", len(proj_ideas), f"{inbox_count} inbox" if inbox_count else None)

            open_specs = sum(1 for s in proj_specs if s.get("status") in ("draft", "review", "approved", "in-progress"))
            m2.metric("Specs", len(proj_specs), f"{open_specs} open" if open_specs else None)

            active_plans = sum(1 for pl in proj_plans if pl.get("status") in ("draft", "approved", "executing"))
            m3.metric("Plans", len(proj_plans), f"{active_plans} active" if active_plans else None)

            open_comp = sum(1 for c in proj_compliance if c.get("status") not in ("dismissed", "accepted"))
            m4.metric("Compliance", len(proj_compliance),
                       f"{open_comp} open" if open_comp else None,
                       delta_color="inverse" if open_comp else "off")

            open_a11y = sum(1 for r in proj_a11y if r.get("status") in ("new", "acknowledged"))
            m5.metric("A11Y", len(proj_a11y),
                       f"{open_a11y} open" if open_a11y else None,
                       delta_color="inverse" if open_a11y else "off")

            # Next phase hint
            if proj_plans:
                latest_plan = proj_plans[-1]
                phase = latest_plan.get("recommended_phase", "—")
                readiness = latest_plan.get("readiness_status", "—")
                next_run = latest_plan.get("suggested_next_run_type", "—")
                st.markdown(f"**Latest Plan**: `{latest_plan.get('plan_id', '?')}` — "
                            f"phase: `{phase}` — readiness: `{readiness}` — next run: `{next_run}`")

            if p.get("notes"):
                st.markdown(f"**Notes**: {p['notes']}")

# --- Bootstrapped Projects ---
st.markdown("---")
st.subheader("Bootstrapped Projects")
st.caption(f"{len(bootstrap)} bootstrapped projects")

if bootstrap:
    for bp in bootstrap:
        bp_status = bp.get("status", "?")
        active = bp_status not in ("paused", "archived")
        icon = "🟢" if active else "⚪"

        with st.expander(f"{icon} {bp.get('project_id', '?')} — {bp.get('name', 'Untitled')} — {bp_status}"):
            c1, c2, c3 = st.columns(3)
            c1.markdown(f"**Category**: `{bp.get('category', '?')}`")
            c2.markdown(f"**Platform**: `{bp.get('platform', '?')}`")
            c3.markdown(f"**Status**: `{bp_status}`")

            if bp.get("secondary_platforms"):
                st.markdown(f"**Secondary Platforms**: {', '.join(bp['secondary_platforms'])}")
            if bp.get("linked_idea"):
                st.markdown(f"**Linked Idea**: `{bp['linked_idea']}`")
            if bp.get("description"):
                st.markdown(f"**Description**: {bp['description']}")
            if bp.get("created_at"):
                st.caption(f"Created: {bp['created_at']}")
else:
    st.info("No bootstrapped projects yet.")
