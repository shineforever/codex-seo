Use the `seo` skill (the Codex SEO orchestrator, installed at ~/.agents/skills/seo/SKILL.md) to handle this request.

Arguments: $ARGUMENTS

If arguments are empty, read the skill's Quick Reference table and show the user the command menu with a one-line description per command. Otherwise route the command exactly as the skill's routing table describes (for example `/seo audit <url>` runs a full audit, `/seo technical <url>` loads the seo-technical sub-skill) and follow the skill's instructions end to end.
