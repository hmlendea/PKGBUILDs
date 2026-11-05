# Concurrency and Scheduling

## Overview

This repository follows a strictly sequential, single-threaded execution model. No parallelism, async operations, or scheduling mechanisms are employed.

## Build Pipeline Concurrency

### Package-Level: Sequential
```bash
for PKGDIR in pkg/*/; do
    # Process one package at a time
    # Next package starts only after current completes
done
```
- No parallel package builds
- No dependency-aware ordering (alphabetical by directory name)
- Independent packages (`hori-fonts`, `image-optimiser`) still build sequentially

### Architecture-Level: Sequential
```bash
for PKGARCH in ${PKGARCHES}; do
    # Build for one architecture at a time
    CARCH="${PKGARCH}" makepkg -Csrf --noconfirm
done
```
- No parallel architecture builds
- Even for `arch=(any)`, loop runs once (single iteration)

### Repository Generation: Sequential
```bash
for ARCH in "any" "aarch64" "i686" "x86_64"; do
    # Generate one database at a time
    for PKGFILE in ${REPODIR}/*-${ARCH}.pkg.tar.zst; do
        repo-add ...
    done
done
```
- Databases generated one architecture at a time
- Package registration within database: sequential

## Resource Usage

### CPU
- Single core utilised at a time
- `makepkg` may use multiple cores internally (via `MAKEFLAGS`)
- No control over `makepkg` parallelism from `makepkgs.sh`

### Memory
- Minimal baseline (bash script overhead)
- `makepkg` spawns build processes (compilers, linkers)
- `repo-add` loads package metadata in memory

### Disk I/O
- Sequential: download → verify → build → package → copy
- No overlapping I/O operations
- `repo/` directory: sequential reads/writes

### Network
- Sequential source downloads per package
- No parallel downloads
- `makepkg -s` installs dependencies sequentially

## Scheduling

### No Scheduler
- No cron, systemd timers, or GitHub Actions scheduled runs
- Builds triggered manually: `bash makepkgs.sh`
- Releases triggered manually: git tag + GitHub Release creation

### No Queue
- No build queue or job management
- Single invocation = single build run
- No retry logic or backoff

## Concurrency Control

### File Locking
- `makepkg` uses lock files in build directory
- `repo-add` creates `.db.lock` during database writes
- No cross-process coordination in `makepkgs.sh`

### Race Conditions
- **Possible**: Two `makepkgs.sh` runs simultaneously
  - Both may try to build same package
  - Both may run `repo-add` on same database
  - Result: Corrupted databases, duplicate builds
- **Mitigation**: Don't run concurrently (manual process)

### Idempotency as Concurrency Control
- Artifact existence check prevents duplicate builds
- `if [ ! -f "${REPODIR}/${PACKAGE_FILE_NAME}" ]; then`
- Partial protection: Second run skips completed packages

## Future Concurrency Options

### Package-Level Parallelism
```bash
# GNU parallel example
find pkg -name PKGBUILD -printf '%h\n' | parallel -j4 bash -c 'cd {} && makepkg -Csrf'
```
**Challenges**: Shared `repo/` directory, dependency resolution, resource contention

### Architecture-Level Parallelism
```bash
# Build all architectures for a package in parallel
for PKGARCH in ${PKGARCHES}; do
    ( CARCH="${PKGARCH}" makepkg -Csrf --noconfirm ) &
done
wait
```
**Challenges**: Shared source directory, `makepkg` not designed for concurrent same-package builds

### Repository Generation Parallelism
```bash
# Generate databases in parallel
for ARCH in any aarch64 i686 x86_64; do
    ( generate_db_for_arch "$ARCH" ) &
done
wait
```
**Feasible**: Databases independent, separate files. Low risk.

## Scheduling Enhancements

### GitHub Actions (Future)
```yaml
# .github/workflows/scheduled.yml
on:
  schedule:
    - cron: '0 2 * * 0'  # Weekly Sunday 2AM
  workflow_dispatch:
```

### Dependency-Triggered Builds
- Monitor upstream releases (RSS, API)
- Trigger rebuild on dependency update
- Requires external scheduling service

### Incremental Build Detection
```bash
# Only build packages with changed PKGBUILD
git diff --name-only HEAD~1 | grep '^pkg/.*/PKGBUILD$'
```

## Current Limitations

| Limitation | Impact | Workaround |
|------------|--------|------------|
| No parallel builds | Slow full rebuild | Run manually per-package |
| No build queue | Manual orchestration | Script per package |
| No retry | Transient failures fail build | Re-run script |
| No timeout | Hanging builds block | Ctrl+C, re-run |
| No resource limits | OOM possible on large builds | Monitor manually |

## Monitoring

### No Built-in Monitoring
- No metrics collection
- No build duration tracking
- No resource usage logging
- Manual observation only

### Ad-hoc Measurement
```bash
time bash makepkgs.sh  # Wall clock time
# Per-package: add timing in script
```