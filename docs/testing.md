# Testing

## Overview

This repository currently has no automated test suite. Testing is manual and verification-based. This document describes current practices and recommended future test strategy.

## Current Testing Practices

### Build Verification
```bash
# Full pipeline test
bash makepkgs.sh

# Verify all packages built
ls repo/*.pkg.tar.zst

# Verify databases
repo-add --verify repo/hmlendea.db.tar.gz
repo-add --verify repo/hmlendea-x86_64.db.tar.gz
repo-add --verify repo/hmlendea-i686.db.tar.gz

# Query package metadata
for pkg in grub2-theme-nuci hori-fonts image-optimiser plex-video-optimiser; do
    pacman -Si --dbpath repo/ "$pkg"
done
```

### Package Installation Test
```bash
# Install from local repo
sudo pacman -U repo/image-optimiser-1.1.0-1-any.pkg.tar.zst

# Test CLI
image-optimiser --help
image-optimiser test-image.jpg

# Uninstall
sudo pacman -R image-optimiser
```

### CLI Tool Manual Testing

#### image-optimiser
```bash
# Create test images
convert -size 100x100 xc:white test.png
convert -size 100x100 xc:white test.jpg

# Run optimiser
image-optimiser test.png test.jpg

# Verify size reduction
ls -lh test.png test.jpg
```

#### plex-video-optimiser
```bash
# Requires test video file (MKV with various tracks)
# Test interactively
plex-video-optimiser test-video.mkv
# Follow prompts, verify output
```

## Recommended Test Strategy

### Unit Tests (PKGBUILD Validation)
```bash
# Syntax validation
for pkg in pkg/*/; do
    bash -n "$pkg/PKGBUILD"
done

# Static analysis
for pkg in pkg/*/; do
    namcap "$pkg/PKGBUILD"
done

# Check required fields
for pkg in pkg/*/; do
    grep -q "^pkgname=" "$pkg/PKGBUILD" || echo "Missing pkgname: $pkg"
    grep -q "^pkgver=" "$pkg/PKGBUILD" || echo "Missing pkgver: $pkg"
    grep -q "^pkgrel=" "$pkg/PKGBUILD" || echo "Missing pkgrel: $pkg"
    grep -q "^arch=" "$pkg/PKGBUILD" || echo "Missing arch: $pkg"
    grep -q "^depends=" "$pkg/PKGBUILD" || echo "Missing depends: $pkg"
    grep -q "^source=" "$pkg/PKGBUILD" || echo "Missing source: $pkg"
    grep -q "^sha512sums=" "$pkg/PKGBUILD" || echo "Missing sha512sums: $pkg"
done
```

### Integration Tests (Build Pipeline)
```bash
# Test in clean container
docker run --rm -v $(pwd):/build -w /build archlinux:base-devel \
    bash -c "pacman -Sy --noconfirm && bash makepkgs.sh"

# Verify outputs
docker run --rm -v $(pwd):/build -w /build archlinux:base-devel \
    bash -c "repo-add --verify repo/hmlendea.db.tar.gz"
```

### CLI Tool Tests

#### image-optimiser Test Cases
| Test Case | Input | Expected |
|-----------|-------|----------|
| Single JPEG | test.jpg | Size reduced, progressive |
| Single PNG | test.png | Size reduced, optimised |
| Directory | testdir/ | All images processed |
| Multiple paths | a.jpg b.png dir/ | All processed |
| Non-existent | missing.jpg | Warning, continue |
| Unsupported | test.gif | Warning, continue |
| Read-only file | readonly.jpg | Error handled |
| Empty directory | emptydir/ | No images processed |

#### plex-video-optimiser Test Cases
| Test Case | Input | Expected |
|-----------|-------|----------|
| HEVC video | video.hevc.mkv | Converted to H.264 |
| AAC audio | video.aac.mkv | Copied |
| E-AC-3 audio | video.eac3.mkv | Converted to AAC |
| Multiple audio | video.multi.mkv | Priority logic applied |
| Subtitles | video.subs.mkv | Removed, optionally extracted |
| Non-MKV | video.mp4 | Converted to MKV |
| Already optimal | video.h264.aac.mkv | "No optimisation needed" |
| TV episode | Show.S01E01.mkv | TV logic applied |
| Filename sanitisation | messy.name.mkv | Clean output name |

### Regression Tests
```bash
# Baseline artifact hashes (store after known-good build)
sha256sum repo/*.pkg.tar.zst > baseline.sha256

# Later: compare
sha256sum -c baseline.sha256
```

### Database Content Tests
```bash
# Verify package count
pacman -Sl --dbpath repo/ | wc -l

# Verify specific package exists
pacman -Si --dbpath repo/ image-optimiser | grep "Version.*1.1.0"

# Verify file lists
pacman -Ql --dbpath repo/ image-optimiser | grep "/usr/bin/image-optimiser"
```

## Test Automation (Future)

### GitHub Actions Workflow
```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]
jobs:
  build-test:
    runs-on: ubuntu-latest
    container: archlinux:base-devel
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: pacman -Sy --noconfirm base-devel jpegoptim oxipng mkvtoolnix-cli ffmpeg perl-rename
      - name: Build packages
        run: bash makepkgs.sh
      - name: Verify databases
        run: |
          repo-add --verify repo/hmlendea.db.tar.gz
          repo-add --verify repo/hmlendea-x86_64.db.tar.gz
          repo-add --verify repo/hmlendea-i686.db.tar.gz
      - name: Test package metadata
        run: |
          for pkg in grub2-theme-nuci hori-fonts image-optimiser plex-video-optimiser; do
            pacman -Si --dbpath repo/ "$pkg"
          done
```

### Container-Based Testing
```dockerfile
# Dockerfile.test
FROM archlinux:base-devel
RUN pacman -Sy --noconfirm jpegoptim oxipng mkvtoolnix-cli ffmpeg perl-rename
WORKDIR /build
COPY . .
RUN bash makepkgs.sh
```

## Test Data

### Sample Images (image-optimiser)
- JPEG: Various quality levels, progressive/baseline
- PNG: Different colour depths, alpha channel, palette
- Large files: >10MB for performance testing
- Edge cases: Corrupted, zero-byte, read-only

### Sample Videos (plex-video-optimiser)
- HEVC + E-AC-3 (common remux)
- H.264 + AAC (already optimal)
- VP9 + Opus (web download)
- Multiple audio tracks (multi-language)
- Subtitle tracks (SRT, ASS, forced, SDH)
- TV episode naming patterns
- Non-MKV containers (MP4, AVI)

## Coverage Goals

| Area | Current | Target |
|------|---------|--------|
| PKGBUILD syntax | Manual | 100% automated |
| Build pipeline | Manual | 100% automated |
| Database generation | Manual | 100% automated |
| image-optimiser CLI | Manual | 80% automated |
| plex-video-optimiser CLI | Manual | 50% automated (interactive) |
| Regression detection | None | 100% automated |

## Test Execution

### Local Development
```bash
# Quick validation
for pkg in pkg/*/; do bash -n "$pkg/PKGBUILD"; done

# Full build test
bash makepkgs.sh

# Database verification
repo-add --verify repo/hmlendea.db.tar.gz
```

### Pre-Commit
```bash
# Add to .git/hooks/pre-commit
#!/bin/bash
for pkg in pkg/*/; do
    bash -n "$pkg/PKGBUILD" || exit 1
    namcap "$pkg/PKGBUILD" || exit 1
done
```

### Pre-Release
```bash
# Full test suite
bash makepkgs.sh
repo-add --verify repo/hmlendea.db.tar.gz
repo-add --verify repo/hmlendea-x86_64.db.tar.gz
repo-add --verify repo/hmlendea-i686.db.tar.gz

# Install test each package
for pkg in repo/*.pkg.tar.zst; do
    sudo pacman -U --noconfirm "$pkg"
    # Test CLI if applicable
    sudo pacman -R --noconfirm $(basename "$pkg" .pkg.tar.zst | sed 's/-[0-9].*//')
done
```

## Limitations

- No test framework for bash scripts
- Interactive CLI tools hard to automate
- No hardware for multi-arch testing (i686, aarch64)
- No upstream source mirroring (network dependency)
- No performance benchmarks