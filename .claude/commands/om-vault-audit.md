# Vault Audit

Deep structural audit of the vault. Checks indexes, folder placement, frontmatter, links, Bases, and consistency. Fix what can be fixed, flag what needs user input.

**When to use**: After substantial sessions, after reorganization, or periodically to maintain vault health. For lighter end-of-session checks, use `/om-wrap-up` instead.

## Usage

```
/om-vault-audit
```

## Subagents

This command orchestrates two subagents for deep analysis:
- **`vault-librarian`** — orphan detection, broken links, frontmatter validation, stale notes, index consistency
- **`cross-linker`** — finds missing wikilinks, orphan notes, broken backlinks

Launch `vault-librarian` first for the structural audit, then `cross-linker` for link quality.

## Workflow

### 1. Check Folder Structure

Verify the vault matches the expected layout:
- `08-SECOND-CERVEAU/Home.md` exists at vault root
- `08-SECOND-CERVEAU/bases/` contains all `.base` files (none scattered elsewhere)
- `08-SECOND-CERVEAU/work/active/` contains only notes with `status: active`
- `08-SECOND-CERVEAU/work/archive/2025/` and `08-SECOND-CERVEAU/work/archive/2026/` contain only `status: completed` notes
- `08-SECOND-CERVEAU/work/incidents/` contains only notes tagged `incident`
- `08-SECOND-CERVEAU/work/1-1/` contains only 1:1 meeting notes
- `08-SECOND-CERVEAU/org/people/` contains only notes tagged `person`
- `08-SECOND-CERVEAU/org/teams/` contains only notes tagged `team`
- `08-SECOND-CERVEAU/templates/` contains only template files (with `{{placeholders}}`)
- `08-SECOND-CERVEAU/thinking/` is clean (no leftover drafts that should have been promoted)
- Nothing unexpected at vault root (allowed: `08-SECOND-CERVEAU/Home.md`, `CLAUDE.md`, `vault-manifest.json`, `CHANGELOG.md`, `CONTRIBUTING.md`, `README.md`, `LICENSE`, `.gitignore` — no user notes)

### 2. Check Indexes

Read and verify each index file:
- `08-SECOND-CERVEAU/Home.md` — do embedded Base views reference existing Bases? Are quick links valid?
- `08-SECOND-CERVEAU/work/Index.md` — are active projects still active? Are completed items in the right section? Any missing notes?
- `08-SECOND-CERVEAU/brain/Memories.md` — is the "Recent Context" section current? Any stale claims?
- `08-SECOND-CERVEAU/org/People & Context.md` — are roles, peer selections, and project assignments current?
- `08-SECOND-CERVEAU/perf/Brag Doc.md` — do PR counts and project descriptions match reality?
- `08-SECOND-CERVEAU/brain/Skills.md` — are all slash commands registered? Workflows still valid?

### 3. Check Frontmatter Completeness

For each note type, verify required properties:

**Work notes** (`08-SECOND-CERVEAU/work/active/`, `08-SECOND-CERVEAU/work/archive/`):
- Required: `date`, `quarter`, `description`, `status`, `tags: [work-note]`
- Optional: `project`, `team`

**Incident notes** (`08-SECOND-CERVEAU/work/incidents/`):
- Required: `date`, `quarter`, `description`, `tags: [work-note, incident]`
- Required for main incident notes: `ticket`, `severity`, `role`, `status`

**Person notes** (`08-SECOND-CERVEAU/org/people/`):
- Required: `date`, `title`, `description`, `tags: [person]`
- Optional but recommended: `team`

**Team notes** (`08-SECOND-CERVEAU/org/teams/`):
- Required: `date`, `description`, `tags: [team]`

**Brain notes** (`08-SECOND-CERVEAU/brain/`):
- Required: `description`, `tags: [brain]`

**1:1 notes** (`08-SECOND-CERVEAU/work/1-1/`):
- Required: `date`, `quarter`, `description`, `tags: [work-note]`

### 4. Check for Duplicate Tags

Scan all notes for duplicate entries in the `tags` array (e.g., `tags: [person, person]`). This is a known issue — fix any found.

### 5. Check Status/Folder Alignment

- Notes in `08-SECOND-CERVEAU/work/active/` must have `status: active`
- Notes in `08-SECOND-CERVEAU/work/archive/` must have `status: completed`
- No `status: active` notes in archive, no `status: completed` notes in active

### 6. Check Bases

For each `.base` file in `08-SECOND-CERVEAU/bases/`:
- Do filters still match the expected notes?
- Are templates excluded? (filters should include `!file.inFolder("templates")` where relevant)
- Do referenced properties exist in the target notes?
- Do formula references exist?

### 7. Check for Orphans

- Are there notes in `08-SECOND-CERVEAU/work/active/` or `08-SECOND-CERVEAU/work/archive/` not linked from `08-SECOND-CERVEAU/work/Index.md`?
- Are there incident notes not linked from `08-SECOND-CERVEAU/work/Index.md` Incidents section?
- Are there people notes not linked from `08-SECOND-CERVEAU/org/People & Context.md`?
- Are there notes without any inbound links at all? (Use `obsidian orphans` if available, or grep for `[[NoteName]]` references)
- Are there thinking notes that should have been promoted or deleted?

### 8. Check Links

- Scan for wikilinks that reference notes that don't exist (broken links)
- Check that bidirectional links exist where expected (work note ↔ person, work note ↔ competency)
- Verify `## Related` sections aren't empty on work notes

### 9. Check for Stale Context

- Read `08-SECOND-CERVEAU/brain/Memories.md` "Recent Context" — is anything outdated?
- Read `08-SECOND-CERVEAU/org/People & Context.md` — any roles, teams, or relationships that changed?
- Check `08-SECOND-CERVEAU/brain/Key Decisions.md`, `08-SECOND-CERVEAU/brain/Patterns.md`, `08-SECOND-CERVEAU/brain/Gotchas.md` for outdated claims
- Check `08-SECOND-CERVEAU/brain/North Star.md` — does Current Focus reflect reality?

### 10. Check for Mixed Context

Per vault rules, each note should cover ONE concept. Flag notes that:
- Mix project work with review prep
- Mix personal conversations with project evidence
- Have 3+ independent sections that don't need each other

### 11. Check Claude Config

- `.claude/settings.json` — are hooks well-formed and referencing correct paths?
- `.claude/commands/` — do all commands reference correct folder structure?
- `CLAUDE.md` — any stale instructions that contradict current vault state?

### 12. Fix and Report

- Fix what's clearly wrong (broken links, missing frontmatter, duplicate tags, wrong folder)
- For ambiguous issues, list them and ask the user
- Summarize:
  - **Fixed**: issues resolved
  - **Flagged**: needs user input
  - **Suggested**: improvements for the vault

## Important

- Don't delete anything without asking
- Don't create new notes during audit — just fix existing ones
- Preserve existing frontmatter when editing
- If a note is in the wrong folder, move it with `git mv`
- Update `08-SECOND-CERVEAU/brain/Memories.md` index if memory topics changed
- Use parallel agents for large audits (e.g., one checking work/, one checking org/, one checking perf/)
