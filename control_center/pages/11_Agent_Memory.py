"""Agent Memory Explorer — Browse decisions, architecture notes, and insights from pipeline runs."""

import streamlit as st
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from store_reader import StoreReader

st.set_page_config(page_title="Agent Memory — Factory Control Center", page_icon="🧠", layout="wide")

st.title("Agent Memory Explorer")
reader = StoreReader()

memory = reader.memory()
total_entries = sum(len(v) for v in memory.values())

st.caption(f"{total_entries} memory entries across {len(memory)} categories — last updated {reader.memory_mtime()}")

if not memory:
    st.info("No agent memory recorded yet. Memory entries are created during pipeline runs as agents log decisions, architecture notes, and review findings.")
    st.stop()

# --- Extract filter options ---
all_entries = []
for category, entries in memory.items():
    for entry in entries:
        note = entry.get("note", "")
        # Extract agent name from "[agent_name] ..." prefix
        agent = "unknown"
        if note.startswith("[") and "]" in note:
            agent = note[1:note.index("]")]
        all_entries.append({
            "category": category,
            "agent": agent,
            "note": note,
            "timestamp": entry.get("timestamp", ""),
        })

categories = sorted(memory.keys())
agents = sorted({e["agent"] for e in all_entries})

# --- Filters ---
col1, col2, col3 = st.columns(3)

with col1:
    sel_category = st.selectbox("Category", ["all"] + categories)
with col2:
    sel_agent = st.selectbox("Agent", ["all"] + agents)
with col3:
    search_term = st.text_input("Search", placeholder="keyword...")

# Apply filters
filtered = all_entries
if sel_category != "all":
    filtered = [e for e in filtered if e["category"] == sel_category]
if sel_agent != "all":
    filtered = [e for e in filtered if e["agent"] == sel_agent]
if search_term:
    term_lower = search_term.lower()
    filtered = [e for e in filtered if term_lower in e["note"].lower()]

# Sort by timestamp descending
filtered.sort(key=lambda e: e["timestamp"], reverse=True)

st.markdown("---")

# --- Category Summary ---
st.subheader("Categories")
cat_cols = st.columns(len(categories)) if categories else []
for i, cat in enumerate(categories):
    cat_count = len(memory[cat])
    cat_cols[i].metric(cat.replace("_", " ").title(), cat_count)

st.markdown("---")
st.caption(f"Showing {len(filtered)} of {total_entries} entries")

# --- Entry Display ---
CATEGORY_ICONS = {
    "decisions": "⚖️",
    "architecture_notes": "🏗️",
    "implementation_notes": "🔧",
    "review_notes": "📝",
}

# Show entries in batches
PAGE_SIZE = 50
if len(filtered) > PAGE_SIZE:
    show_count = st.slider("Entries to show", min_value=PAGE_SIZE, max_value=len(filtered), value=PAGE_SIZE, step=PAGE_SIZE)
else:
    show_count = len(filtered)

prev_date = None

for entry in filtered[:show_count]:
    ts = entry["timestamp"]
    entry_date = ts[:10] if len(ts) >= 10 else ts

    if entry_date != prev_date:
        st.markdown(f"### {entry_date}")
        prev_date = entry_date

    cat_icon = CATEGORY_ICONS.get(entry["category"], "📌")
    cat_label = entry["category"].replace("_", " ").title()
    agent = entry["agent"]
    note_text = entry["note"]

    # Strip the [agent] prefix for cleaner display
    if note_text.startswith(f"[{agent}]"):
        note_text = note_text[len(agent) + 3:].strip()

    with st.container():
        c1, c2 = st.columns([1, 4])
        with c1:
            st.caption(f"{ts[11:19] if len(ts) >= 19 else ts}")
            st.caption(f"{cat_icon} {cat_label}")
        with c2:
            st.markdown(f"**{agent}** — {note_text[:200]}{'...' if len(note_text) > 200 else ''}")
