# Logging

## Overview

This repository uses minimal, unstructured logging. There is no centralised logging framework, log levels, or structured output.

## Build Pipeline Logging (makepkgs.sh)

### Output Streams
- **stdout**: All informational and error messages
- **stderr**: Tool errors (makepkg, repo-add, cp, rm)

### Message Types

| Phase | Example Output |
|-------|----------------|
| Package discovery | `Processing package: grub2-theme-nuci` |
| Metadata extraction | `Package ID: grub2-theme-nuci-1.0.0-1` |
| Architecture loop | `Building for x86_64...` |
| Build start | `==> Making package: grub2-theme-nuci 1.0.0-1 (x86_64)` |
| makepkg output | Full makepkg verbose output |
| Artifact copy | `Copying artifact to repo/` |
| Cleanup | `Removing old version: grub2-theme-nuci-1.0.0-1-aarch64.pkg.tar.zst` |
| Repo generation | `Registering repo/grub2-theme-nuci-1.0.0-1-x86_64.pkg.tar.zst into hmlendea-x86_64` |
| Completion | `Recommended release tag: v1.0.0` |

### Verbosity Control
- **No flags**: Default makepkg verbosity
- **No quiet mode**: Cannot suppress output
- **No debug mode**: Cannot increase verbosity

## Repository Generation Logging

### repo-add Output
```
==> Adding package 'grub2-theme-nuci-1.0.0-1-x86_64.pkg.tar.zst'
  -> Computing checksums...
  -> Creating 'desc' db entry...
  -> Creating 'depends' db entry...
==> Creating updated database file 'hmlendea-x86_64.db.tar.gz'
```

### Cleanup Messages
- No output for successful `rm` operations
- Errors printed if files not found or permission denied

## CLI Tool Logging

### image-optimiser
```
File #1: '/path/to/image.jpg'
Size: 2.5M -> 1.8M

File #2: '/path/to/image.png'
Size: 512K -> 384K

Finished processing 2 images
Size: 3.0M -> 2.2M
```
- Per-file: original size, final size
- Summary: total files, total original size, total final size
- No timestamps, no log levels

### plex-video-optimiser
```
Gathering file info for /path/video.mkv ...
Session ID: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
Input file name: Show.S01E01.1080p.WEB-DL.x264
Video format: HEVC
Audio 0: E-AC-3 (English)
Audio 1: AAC (Commentary)
Output file name: Show S01E01
Subtitles need removal!
Subtitle tracks found:
#4: ENG (English)
#5: SPA (Spanish)
Do you want to save the subtitles before removing them? [Y/n] Y
Extracting the subtitles...
Video track needs conversion!
Audio track needs conversion!
Output file: /path/Show S01E01.OPTIMISED.mkv
ffmpeg arguments:
-map 0:v:0 -c:v:0 h264 -map 0:a:0 -c:a:0 aac ...
Are you sure you want to optimise the video with the mentioned settings? [Y/n] Y
Optimising /path/video.mkv...
>>> DONE!
Size before: 4.2G
Size after: 2.8G
Do you want to replace the original file? [Y/n] Y
```
- Session ID for traceability
- Step-by-step analysis output
- Interactive prompts interleaved
- ffmpeg command shown before execution
- Size comparison before/after

## Log Format Characteristics

| Aspect | Implementation |
|--------|----------------|
| Timestamps | None |
| Log levels | None (all messages same priority) |
| Structured fields | None |
| Correlation IDs | Session ID (plex-video-optimiser only) |
| Output destination | stdout/stderr only |
| Rotation | None |
| Retention | None (ephemeral) |

## Integration with External Logging

### Systemd Journal (if run as service)
```bash
# Not applicable - no services
```

### CI/CD Logs (GitHub Actions)
```yaml
# Capture all output
- name: Build packages
  run: bash makepkgs.sh
  # Output appears in workflow log
```

### Log Aggregation
- Not supported natively
- Redirect output: `bash makepkgs.sh 2>&1 | tee build.log`
- Parse with grep/awk for metrics

## Metrics Extraction

### Build Duration
```bash
time bash makepkgs.sh 2>&1 | tee build.log
# Real time from 'time' output
```

### Package Count
```bash
grep -c "Processing package:" build.log
```

### Artifact Count
```bash
ls repo/*.pkg.tar.zst | wc -l
```

### Size Savings (image-optimiser)
```bash
image-optimiser /path 2>&1 | grep "Finished processing"
# Output: "Finished processing 42 images Size: 1.2G -> 850M"
```

## Limitations

- No correlation between build steps
- No machine-parseable format
- No log levels for filtering
- No persistent storage
- No alerting on errors
- No audit trail
- Interactive prompts break automation

## Recommendations for Enhancement

### Structured Logging (Future)
```bash
# JSON lines format
{"timestamp":"2024-01-15T10:30:00Z","level":"INFO","phase":"build","package":"grub2-theme-nuci","arch":"x86_64","status":"started"}
{"timestamp":"2024-01-15T10:30:45Z","level":"INFO","phase":"build","package":"grub2-theme-nuci","arch":"x86_64","status":"completed","duration":45}
```

### Log Levels
- `DEBUG`: Detailed makepkg output
- `INFO`: Phase transitions, artifact copies
- `WARN`: Skipped architectures, fallback tools
- `ERROR`: Build failures, copy failures

### Correlation
- Build ID per `makepkgs.sh` invocation
- Propagate to all sub-commands
- Link artifacts to build ID