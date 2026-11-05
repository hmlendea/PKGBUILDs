# Documentation Maintenance

## Overview

Guidelines for maintaining documentation in this repository. Documentation lives in `docs/` and complements root-level files (`README.md`, `ARCHITECTURE.md`, `SECURITY.md`, `PRIVACY.md`).

## Documentation Structure

```
docs/
├── INDEX.md                      # Navigation hub
├── architecture.md               # System architecture (complements root ARCHITECTURE.md)
├── repository-overview.md        # High-level repository description
├── repository-structure.md       # Directory/file layout
├── build-and-deployment.md       # Build pipeline and deployment
├── configuration.md              # Configuration reference
├── dependencies.md               # Dependency graph
├── data-model.md                 # Data structures
├── invariants.md                 # System invariants
├── error-handling.md             # Error handling patterns
├── logging.md                    # Logging approach
├── security.md                   # Security posture (complements root SECURITY.md)
├── faq.md                        # Frequently asked questions
├── quick-start.md                # Getting started guide
├── ambiguities-and-open-questions.md  # Known unknowns
├── change-guide.md               # How to make changes
├── testing.md                    # Testing strategy
├── troubleshooting.md            # Common issues and fixes
├── documentation-maintenance.md  # This file
├── design-decisions.md           # Architectural decision records
├── concurrency-and-scheduling.md # Concurrency model
├── state-and-persistence.md      # State management
├── integrations.md               # External integrations
├── api-reference/
│   ├── INDEX.md
│   ├── image-optimiser-cli.md
│   └── plex-video-optimiser-cli.md
├── behaviour/
│   ├── browse-and-search.md
│   └── inspect-edit-delete.md
├── components/
│   ├── build-pipeline.md
│   ├── package-definitions.md
│   └── repository-generation.md
└── flows/
    ├── package-build.md
    ├── repository-generation.md
    └── release-distribution.md
```

## Maintenance Principles

### 1. Complement, Don't Duplicate
- Root `ARCHITECTURE.md` → High-level overview
- `docs/architecture.md` → Technical detail
- Root `SECURITY.md` → Policy and contacts
- `docs/security.md` → Technical implementation

### 2. Single Source of Truth
- Each fact documented in one place
- Cross-reference with links, don't copy
- Update all affected docs when facts change

### 3. British English Spelling
- Use `-ise` not `-ize` (optimise, realise)
- Use `-our` not `-or` (colour, behaviour)
- Use `-re` not `-er` (centre, metre)
- Use `programme` (noun), `program` (verb/computing)

### 4. Kebab-Case Filenames
- `build-pipeline.md` not `buildPipeline.md` or `build_pipeline.md`
- Consistent across all `docs/` files

## Update Triggers

### When to Update Documentation

| Event | Docs to Review |
|-------|----------------|
| New package added | `repository-overview.md`, `repository-structure.md`, `components/package-definitions.md`, `data-model.md`, `dependencies.md`, `api-reference/INDEX.md` |
| Package version bump | `components/package-definitions.md` (version table), `data-model.md` |
| Build script change | `build-and-deployment.md`, `components/build-pipeline.md`, `flows/package-build.md`, `flows/repository-generation.md` |
| CLI tool change | `api-reference/<tool>-cli.md`, `quick-start.md`, `troubleshooting.md` |
| Architecture change | `architecture.md`, `repository-structure.md`, `design-decisions.md` |
| Security improvement | `security.md`, `SECURITY.md` |
| New dependency | `dependencies.md`, `data-model.md` |
| Bug fix | `troubleshooting.md`, `change-guide.md` |
| Process change | `change-guide.md`, `testing.md`, `flows/*.md` |

## Review Checklist

### Per Change
- [ ] All affected files updated
- [ ] Cross-references valid (links work)
- [ ] British English spelling
- [ ] Kebab-case filenames
- [ ] No duplication with root docs
- [ ] Code examples tested
- [ ] Version numbers current

### Quarterly Review
- [ ] All links resolve (internal and external)
- [ ] Version references match reality
- [ ] Outdated information removed
- [ ] Open questions resolved or updated
- [ ] Architecture diagrams current

## Link Validation

### Internal Links
```bash
# Check all .md files for broken internal links
find docs -name "*.md" -exec grep -l "](.*\.md)" {} \; | while read f; do
    grep -o "](.*\.md)" "$f" | sed 's/]\(.*\)/\1/' | while read link; do
        # Resolve relative to file directory
        target=$(dirname "$f")/"$link"
        [ -f "$target" ] || echo "BROKEN: $f -> $link"
    done
done
```

### External Links
```bash
# Check external URLs (requires curl)
grep -r "https://" docs/ | grep -o "https://[^)]*" | sort -u | while read url; do
    curl -s -o /dev/null -w "%{http_code} $url\n" "$url" | grep -v "^200"
done
```

## Style Guide

### Headings
- `#` for document title (once per file)
- `##` for major sections
- `###` for subsections
- `####` for detail items

### Code Blocks
- Language tag for syntax highlighting: ```bash, ```yaml, ```ini
- Shell commands: include `$` prompt for user commands
- Output: no prompt, separate block

### Tables
- Use for structured data (dependencies, versions, error codes)
- Header row required
- Align columns for readability in source

### Cross-References
- Relative links: `[text](../components/build-pipeline.md)`
- Anchor links: `[section](#section-name)`
- Root docs: `[ARCHITECTURE.md](../../ARCHITECTURE.md)`

### Emphasis
- **Bold** for UI elements, key terms
- *Italic* for emphasis, first use of terms
- `Code` for commands, paths, variables

## Versioning

### Documentation Version
- No separate versioning — tied to repository tag
- `docs/` updated in same commit as code changes
- Release tag implies documentation snapshot

### Changelog
- No separate CHANGELOG.md
- Git history serves as changelog
- `git log --oneline docs/` for doc changes

## Tools

### Recommended Editors
- VS Code with Markdown extensions
- `markdownlint` for style checking
- `vale` for prose linting (British English)

### Validation Commands
```bash
# Markdown linting
npx markdownlint docs/**/*.md

# Spell check (British English)
npx cspell docs/**/*.md --locale en-GB

# Link check
npx markdown-link-check docs/**/*.md
```

## Contribution Guidelines

### For Contributors
1. Update docs in same PR as code
2. Follow style guide
3. Test code examples
4. Update `INDEX.md` if new files added

### For Maintainers
1. Review doc changes with code changes
2. Enforce style guide
3. Run validation tools periodically
4. Archive obsolete docs (move to `docs/archive/`)

## Archive Policy

### When to Archive
- Feature removed
- Process replaced
- Information superseded

### How to Archive
```bash
mkdir -p docs/archive
mv docs/old-file.md docs/archive/
# Update any remaining links
```

### Archive Index
- `docs/archive/INDEX.md` lists archived files with reason and date

## Metrics

### Documentation Health Indicators
- Link rot rate (broken links / total links)
- Coverage (documented features / total features)
- Freshness (days since last update per file)
- Consistency (style violations per file)

### Target Metrics
- Zero broken internal links
- 100% feature coverage
- Max 90 days since update for active files
- Zero style violations