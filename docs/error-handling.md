# Error Handling

## Build Pipeline Errors

### makepkg Failures

| Error Type | Cause | Detection | Recovery |
|------------|-------|-----------|----------|
| Checksum mismatch | Source file changed, PKGBUILD not updated | `makepkg` exits non-zero, prints checksum error | Run `updpkgsums` in package directory |
| Missing dependency | `depends`/`makedepends` incomplete | `makepkg` fails with "missing dependency" | Add dependency to PKGBUILD |
| Build failure | Compilation error, test failure | `makepkg` exits non-zero | Fix `build()`/`package()` function or source |
| Source download failure | Upstream URL changed, network issue | `makepkg` fails during `source` download | Update `source` URL in PKGBUILD |
| Permission denied | No write access to build directory | `makepkg` fails early | Fix directory permissions |

**Behaviour**: Script continues to next package/architecture after logging error.

### Artifact Copy Failures

| Error | Cause | Recovery |
|-------|-------|----------|
| `cp` fails | Disk full, permissions, missing source | Free space, fix permissions, rebuild |
| Artifact not found | `makepkg` succeeded but output elsewhere | Check `PKGDEST`, `BUILDDIR` env vars |

### Cleanup Failures

| Error | Cause | Impact |
|-------|-------|--------|
| `rm` fails | Permission denied, file in use | Old artifacts accumulate |
| `find`/`grep` parsing error | PKGBUILD format changed | Wrong artifacts removed/retained |

## Repository Generation Errors

### repo-add Failures

| Error | Cause | Recovery |
|-------|-------|----------|
| Database locked | Another `repo-add` running | Wait, retry |
| Corrupt package | `.pkg.tar.zst` damaged | Rebuild package |
| Disk full | No space for database | Free space, retry |
| Permission denied | No write to `repo/` | Fix permissions |

**Behaviour**: Partial database created, `.old` backup preserved. Next run cleans up.

### Database Finalization Failures

| Error | Cause | Recovery |
|-------|-------|----------|
| `cp .db.tar.gz .db` fails | Disk full, permissions | Free space, fix permissions, manual copy |

## Runtime Errors (CLI Tools)

### image-optimiser

| Error | Cause | Handling |
|-------|-------|----------|
| Path not found | Argument typo, file deleted | Warning, continue |
| Unsupported format | Non-JPEG/PNG file | Warning, continue |
| `oxipng`/`jpegoptim` missing | Dependency not installed | Fallback (PNG) or fail (JPEG) |
| Permission denied | Read-only file | Tool error, continue |
| Disk full | No space for optimised file | Tool error, continue |

### plex-video-optimiser

| Error | Cause | Handling |
|-------|-------|----------|
| File not found | Argument typo, file deleted | Exit 1 |
| Not a file | Directory given | Exit 1 |
| `mkvmerge`/`mkvinfo` missing | `mkvtoolnix-cli` not installed | Tool error during analysis |
| `ffmpeg` missing | Not installed | Tool error during conversion |
| `perl-rename` missing | Not installed | Filename sanitisation fails |
| Interactive prompt interrupted | User presses Ctrl+C | Exit 130 |
| `ffmpeg` conversion fails | Codec unsupported, corrupt input | Error output, original preserved |
| Replace fails | Permission denied, disk full | Original preserved, optimised file remains |

## Error Reporting

### Build Pipeline (makepkgs.sh)
- Errors printed to stdout/stderr inline
- No structured logging
- No error aggregation
- Exit code always 0 (script never exits on error)

### Repository Generation
- `repo-add` output shown
- Errors printed inline
- No summary at end

### CLI Tools
- `image-optimiser`: Per-file status, summary at end
- `plex-video-optimiser`: Verbose step-by-step, interactive prompts

## Recovery Strategies

### Full Rebuild
```bash
rm repo/*.pkg.tar.zst repo/*.db repo/*.files repo/*.db.tar.gz repo/*.files.tar.gz
bash makepkgs.sh
```

### Single Package Rebuild
```bash
rm repo/<package>-*.pkg.tar.zst
bash makepkgs.sh
```

### Single Architecture Rebuild
```bash
rm repo/*-x86_64.pkg.tar.zst
bash makepkgs.sh
```

### Database Only Regeneration
```bash
rm repo/*.db repo/*.files repo/*.db.tar.gz repo/*.files.tar.gz
bash makepkgs.sh
```

### Fix Checksums
```bash
cd pkg/<package>
updpkgsums
bash makepkgs.sh
```

## Error Prevention

### PKGBUILD Validation
```bash
# Syntax check
bash -n pkg/<name>/PKGBUILD

# Static analysis
namcap pkg/<name>/PKGBUILD

# Dry-run build (no package)
cd pkg/<name>
makepkg --check
```

### Pre-Commit Checks
- Run `makepkgs.sh` locally before push
- Verify all packages build
- Verify databases generate
- Test `pacman -Si --dbpath repo/`

## Monitoring

### Build Success Verification
```bash
# Check all expected packages exist
ls repo/*.pkg.tar.zst | wc -l

# Verify databases
repo-add --verify repo/hmlendea.db.tar.gz

# Query each package
for pkg in grub2-theme-nuci hori-fonts image-optimiser plex-video-optimiser; do
    pacman -Si --dbpath repo/ "$pkg"
done
```

### Artifact Integrity
```bash
# Verify package signatures (if signed)
pacman-key --verify repo/<package>.pkg.tar.zst.sig

# Check package contents
pacman -Ql --dbpath repo/ <package>
```

## Limitations

- No centralised error log
- No alerting on build failure
- No automatic retry
- Script exit code doesn't reflect build success
- Partial failures silent (continue without summary)