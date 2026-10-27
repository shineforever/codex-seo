"""
Tests that ensure user-visible docs claim counts that match reality on disk.

The Codex port ships no plugin manifest, so the canonical counts come from
the repository itself: skills/ directories, agents/ playbooks, tracked
scripts, and the pyproject.toml version (cross-checked against CITATION.cff
and every SKILL.md metadata block).

History: this guard exists because the v1.9.7 release process suffered
two distinct skill-count drift incidents in a single release window.
Tests run via `pytest tests/` and are wired into `.github/workflows/ci.yml`.
"""
import re
import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CITATION_CFF = REPO_ROOT / "CITATION.cff"


def _count_skill_dirs() -> int:
    """Count subdirectories of skills/ that contain a SKILL.md."""
    skills_dir = REPO_ROOT / "skills"
    return sum(
        1 for d in skills_dir.iterdir()
        if d.is_dir() and (d / "SKILL.md").is_file()
    )


def _count_agent_files() -> int:
    """Count agents/seo-*.md files."""
    agents_dir = REPO_ROOT / "agents"
    return sum(
        1 for f in agents_dir.iterdir()
        if f.is_file() and f.suffix == ".md" and f.name.startswith("seo-")
    )


def _extract_count(text: str, unit: str) -> int:
    """Find the first occurrence of 'N <unit>' in text and return N."""
    match = re.search(rf"(\d+)\s+{re.escape(unit)}", text)
    if not match:
        raise AssertionError(f"No '{unit}' count claim found in text")
    return int(match.group(1))


def _pyproject_version() -> str:
    text = (REPO_ROOT / "pyproject.toml").read_text(encoding="utf-8")
    m = re.search(r'^version\s*=\s*"([^"]+)"', text, re.MULTILINE)
    assert m, "pyproject.toml has no 'version = \"...\"' line"
    return m.group(1)


def test_skill_count_claims_match_disk():
    """AGENTS.md 'N sub-skills' claim must equal the skills/ directory count."""
    claimed = _extract_count(
        (REPO_ROOT / "AGENTS.md").read_text(encoding="utf-8"), "sub-skills"
    )
    actual = _count_skill_dirs()
    assert claimed == actual, (
        f"AGENTS.md claims {claimed} sub-skills but disk has {actual}. "
        f"Update the wording to match the new count."
    )


def test_agent_count_claims_match_disk():
    """AGENTS.md 'N specialist role playbooks' claim must equal agents/ count."""
    claimed = _extract_count(
        (REPO_ROOT / "AGENTS.md").read_text(encoding="utf-8"),
        "specialist role playbooks",
    )
    actual = _count_agent_files()
    assert claimed == actual, (
        f"AGENTS.md claims {claimed} role playbooks but disk has {actual}. "
        f"Update the wording to match the new count."
    )


def test_canonical_phrasing_in_user_visible_docs():
    """README and AGENTS.md must reference the canonical sub-skills count."""
    canonical_count = _count_skill_dirs()
    target_phrase = f"{canonical_count} sub-skills"
    for filename in ["README.md", "AGENTS.md"]:
        path = REPO_ROOT / filename
        head = "\n".join(path.read_text(encoding="utf-8").splitlines()[:120])
        assert target_phrase in head, (
            f"{filename} does not reference '{target_phrase}' in its first "
            f"120 lines. Update it to match the skills/ count on disk."
        )


def test_version_triangulation():
    """pyproject.toml version must equal CITATION.cff version."""
    citation_text = CITATION_CFF.read_text(encoding="utf-8")
    citation_match = re.search(r"^version:\s*(\S+)", citation_text, re.MULTILINE)
    assert citation_match, "CITATION.cff has no 'version:' line"
    assert _pyproject_version() == citation_match.group(1), (
        f"pyproject.toml version is {_pyproject_version()} but CITATION.cff "
        f"has {citation_match.group(1)}. They must match every release."
    )


def _extract_section(text: str, heading: str) -> str:
    """Return the body of a `## <heading>` section, up to the next H2 heading or EOF."""
    pattern = rf"^## {re.escape(heading)}\b.*?(?=^## |\Z)"
    m = re.search(pattern, text, re.MULTILINE | re.DOTALL)
    return m.group(0) if m else ""


def test_orchestrator_sub_skills_list_matches_disk():
    """skills/seo/SKILL.md Sub-Skills numbered list must equal set(skills/*) minus orchestrator itself."""
    text = (REPO_ROOT / "skills" / "seo" / "SKILL.md").read_text(encoding="utf-8")
    section = _extract_section(text, "Sub-Skills")
    listed_list = re.findall(r"^\d+\.\s+\*\*(seo-[a-z-]+)\*\*", section, re.MULTILINE)
    assert len(listed_list) == len(set(listed_list)), (
        f"Duplicate entries in Sub-Skills list: "
        f"{[n for n in listed_list if listed_list.count(n) > 1]}"
    )
    listed = set(listed_list)
    on_disk = {
        d.name for d in (REPO_ROOT / "skills").iterdir()
        if d.is_dir() and (d / "SKILL.md").is_file()
    }
    expected = on_disk - {"seo"}
    assert listed == expected, (
        f"Sub-Skills list != skills/ dir. "
        f"Missing from list: {sorted(expected - listed)}. "
        f"Extra in list: {sorted(listed - expected)}."
    )


def test_orchestrator_roles_list_matches_disk():
    """skills/seo/SKILL.md Specialist Roles bullet list must equal set(agents/seo-*.md)."""
    text = (REPO_ROOT / "skills" / "seo" / "SKILL.md").read_text(encoding="utf-8")
    section = _extract_section(text, "Specialist Roles")
    listed_list = re.findall(r"^- `(seo-[a-z-]+)`", section, re.MULTILINE)
    assert len(listed_list) == len(set(listed_list)), (
        f"Duplicate entries in Specialist Roles list: "
        f"{[n for n in listed_list if listed_list.count(n) > 1]}"
    )
    listed = set(listed_list)
    on_disk = {
        p.stem for p in (REPO_ROOT / "agents").iterdir()
        if p.is_file() and p.suffix == ".md" and p.name.startswith("seo-")
    }
    assert listed == on_disk, (
        f"Specialist Roles list != agents/ dir. "
        f"Missing from list: {sorted(on_disk - listed)}. "
        f"Extra in list: {sorted(listed - on_disk)}."
    )


def _extract_frontmatter(text: str) -> str:
    """Return the YAML frontmatter block (between the first two `---` lines)."""
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    return m.group(1) if m else ""


def test_skill_metadata_versions_match_pyproject():
    """Every SKILL.md metadata.version must equal the pyproject.toml version (with community allowlist)."""
    COMMUNITY_OVERRIDES = {"seo-content-brief": "1.0.0"}

    expected_default = _pyproject_version()
    errors = []

    candidates = list((REPO_ROOT / "skills").glob("*/SKILL.md")) + list(
        (REPO_ROOT / "extensions").glob("*/skills/*/SKILL.md")
    )
    for skill_md in candidates:
        skill_name = skill_md.parent.name
        rel = skill_md.relative_to(REPO_ROOT)
        text = skill_md.read_text(encoding="utf-8")
        frontmatter = _extract_frontmatter(text)
        if not frontmatter:
            errors.append(f"{rel} has no YAML frontmatter block")
            continue
        match = re.search(
            r'^  version:\s*"([^"]+)"', frontmatter, re.MULTILINE
        )
        if not match:
            errors.append(f"{rel} has no metadata.version in frontmatter")
            continue
        actual = match.group(1)
        expected = COMMUNITY_OVERRIDES.get(skill_name, expected_default)
        if actual != expected:
            errors.append(f"{rel}: version is {actual}, expected {expected}")

    assert not errors, "Skill metadata.version drift:\n  " + "\n  ".join(errors)


def test_reference_files_have_at_least_one_link():
    """Every skills/*/references/*.md file must be cited somewhere in the repo.

    Guards against orphan reference files: docs on disk that no SKILL.md,
    agent, top-level doc, or other reference file actually links to.
    """
    ref_files = list((REPO_ROOT / "skills").glob("*/references/*.md"))
    if not ref_files:
        return

    search_paths: list[Path] = []
    search_paths += list((REPO_ROOT / "skills").glob("*/SKILL.md"))
    search_paths += list((REPO_ROOT / "agents").glob("*.md"))
    search_paths += list((REPO_ROOT / "docs").glob("*.md"))
    for doc in ("README.md", "CHANGELOG.md", "AGENTS.md", "CONTRIBUTING.md"):
        candidate = REPO_ROOT / doc
        if candidate.exists():
            search_paths.append(candidate)
    search_paths += ref_files

    text_by_path = {p: p.read_text(encoding="utf-8") for p in search_paths}

    orphans = []
    for ref in ref_files:
        slug = ref.stem
        filename = ref.name
        wikilink = f"[[{slug}]]"
        found = False
        for other_path, text in text_by_path.items():
            if other_path == ref:
                continue
            if filename in text or wikilink in text:
                found = True
                break
        if not found:
            orphans.append(str(ref.relative_to(REPO_ROOT)))

    assert not orphans, (
        "Orphan reference files (on disk, not cited anywhere repo-wide):\n  "
        + "\n  ".join(orphans)
    )


def test_script_count_claims_match_tracked_scripts():
    """AGENTS.md script count claim must equal the tracked scripts/*.py files."""
    tracked = subprocess.run(
        ["git", "-C", str(REPO_ROOT), "ls-files", "scripts/*.py"],
        capture_output=True, text=True, check=True,
    ).stdout.split()
    text = (REPO_ROOT / "AGENTS.md").read_text(encoding="utf-8")
    claimed = _extract_count(text, "Python execution scripts")
    assert claimed == len(tracked), (
        f"AGENTS.md claims {claimed} scripts, {len(tracked)} tracked"
    )
