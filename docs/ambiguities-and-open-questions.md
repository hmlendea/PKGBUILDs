# Ambiguities and Open Questions

## Build Pipeline

### Architecture Support
- **Question**: Should `aarch64` be actively supported or removed from the architecture loop?
- **Context**: Loop includes `aarch64` but no PKGBUILD declares it. No build infrastructure for ARM.
- **Options**: Remove from loop, add cross-compilation support, document as future work.

### Parallel Builds
- **Question**: Should package builds run in parallel?
- **Context**: Current sequential execution. Independent packages could build concurrently.
- **Constraints**: `makepkg` resource usage, disk I/O, dependency resolution.

### Incremental Builds
- **Question**: Should `makepkgs.sh` support incremental builds (only changed packages)?
- **Context**: Current full rebuild or artifact-existence check. No git-diff-based detection.
- **Options**: Git diff PKGBUILDs, timestamp comparison, content hashing.

## Package Definitions

### hori-fonts Licensing
- **Ambiguity**: Redistribution rights for some fonts unclear.
- **Context**: Sources from dafont.com, fontles.com, 1001fonts.com, GitHub. Licenses vary (OFL, shareware, custom).
- **Risk**: Potential license violation if redistributed via public repo.
- **Action needed**: Audit each font license, document permissions, remove non-redistributable.

### plex-video-optimiser Hardcoded Preferences
- **Ambiguity**: Audio/subtitle preferences hardcoded as constants.
- **Context**: `KEEP_ORIGINAL_AUDIO_TRACKS_FOR_TVSHOWS=false`, `KEEP_FORCED_SUBTITLES=false`, `KEEP_SDH_SUBTITLES=false`.
- **Question**: Should these be CLI flags or config file?
- **Impact**: Limits usability for different preferences.

### grub2-theme-nuci Architecture Limitation
- **Question**: Why only `x86_64` and `i686`? Can GRUB themes be `any`?
- **Context**: Theme is text/images. GRUB loads theme at runtime. Architecture may not matter.
- **Investigation needed**: Test on aarch64, check GRUB module compatibility.

## Repository Management

### Versioning Strategy
- **Ambiguity**: Single repo version tag vs per-package versioning.
- **Context**: Each package has independent `pkgver`/`pkgrel`. Repo uses single tag (e.g., `v1.0.0`).
- **Question**: How to handle partial updates? Tag per package? Monorepo version?

### Release Automation
- **Question**: Manual release process vs GitHub Actions automation.
- **Context**: Current process manual. No CI/CD configured.
- **Options**: GitHub Actions on tag push, scheduled builds, PR-based preview builds.

### Database Signing Keys
- **Question**: Key management strategy for package signing.
- **Context**: No signing currently. Need offline master key, online signing subkey.
- **Decisions needed**: Key rotation period, revocation process, key storage.

## CLI Tools

### plex-video-optimiser Non-Interactive Mode
- **Question**: Should batch/automated mode be added?
- **Context**: Currently requires 3 interactive prompts. Unsuitable for automation.
- **Options**: `--yes` flag, config file, environment variables, expect wrapper.

### image-optimiser Dry Run
- **Question**: Should dry-run mode show savings without modifying?
- **Context**: In-place modification with no backup. Risk of unwanted changes.
- **Options**: `--dry-run` flag, `--backup` flag, output to different directory.

### Filename Sanitisation Aggressiveness
- **Ambiguity**: `plex-video-optimiser` removes many patterns aggressively.
- **Context**: Removes release groups, quality, codecs, sources, audio info, years.
- **Question**: Configurable patterns? Preserve option? User-reported over-sanitisation?

## Infrastructure

### CI/CD Platform
- **Question**: GitHub Actions vs other CI?
- **Context**: Repository on GitHub. GitHub Actions natural fit.
- **Considerations**: Build time limits, ARM runners, artifact storage, secrets management.

### Artifact Retention
- **Question**: How long to keep old package versions in GitHub Releases?
- **Context**: Current: only latest release assets. Old versions inaccessible.
- **Options**: Keep N versions, keep all, separate archive repository.

### Multi-Architecture Build Infrastructure
- **Question**: How to build for `i686` and `aarch64`?
- **Context**: Maintainer likely on `x86_64`. Cross-compilation or remote builders needed.
- **Options**: Docker multi-arch, GitHub Actions matrix, dedicated builders, drop unsupported arches.

## Documentation

### Audience Scope
- **Question**: Documentation for maintainer only, or also for users/contributors?
- **Context**: Current docs technical, implementation-focused.
- **Options**: Separate user guide, contributor guide, maintainer guide.

### API Reference Completeness
- **Question**: Document `makepkgs.sh` as API?
- **Context**: Build script has no formal API. Used manually.
- **Options**: Document as internal tool, create stable CLI interface.

## Testing

### Test Strategy
- **Question**: What testing approach for PKGBUILDs and CLI tools?
- **Context**: No automated tests. Manual verification only.
- **Options**: Container-based build tests, CLI integration tests, pacman install tests.

### Regression Detection
- **Question**: How to detect regressions in package builds?
- **Context**: No baseline. Each build independent.
- **Options**: Artifact comparison, metadata validation, install verification.

## Maintenance

### Dependency Update Policy
- **Question**: How to handle upstream dependency updates?
- **Context**: `depends` arrays use unversioned names. `pacman -Syu` may break packages.
- **Options**: Version pinning, rebuild on dependency update, automated testing.

### End-of-Life Packages
- **Question**: Process for retiring packages?
- **Context**: No policy. Packages accumulate.
- **Options**: Archive directory, removal with notice, migration path.

## Security

### Threat Model Completeness
- **Question**: Is current threat model sufficient?
- **Context**: Basic model documented. No formal assessment.
- **Gaps**: Supply chain (upstream sources), build environment, key compromise.

### Incident Response Plan
- **Question**: Documented incident response for compromised package/key?
- **Context**: High-level steps in security.md. No runbooks.
- **Needed**: Step-by-step procedures, communication templates, contacts.