# plex-video-optimiser CLI Reference

## Overview

Video optimisation tool for Plex direct streaming compatibility. Converts video/audio tracks, sanitises filenames, extracts subtitles.

## Installation

```bash
pacman -S plex-video-optimiser
```

## Usage

```bash
plex-video-optimiser <FILE>
```

## Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `FILE` | string | Yes | Single video file to optimise (MKV, MP4, etc.) |

## Options

| Option | Description |
|--------|-------------|
| `--help` | Not implemented |

## Interactive Prompts

The tool requires interactive confirmation at two stages:

1. **Subtitle extraction** (if subtitles present):
   ```
   Do you want to save the subtitles before removing them? [Y/n]
   ```

2. **Optimisation confirmation**:
   ```
   Are you sure you want to optimise the video with the mentioned settings? [Y/n]
   ```

3. **Replace original** (after successful optimisation):
   ```
   Do you want to replace the original file? [Y/n]
   ```

## Processing Pipeline

### 1. File Analysis
- Validates file exists
- Detects container format (must be Matroska/MKV for full processing)
- Identifies video track format
- Enumerates audio tracks with formats and names
- Enumerates subtitle tracks

### 2. Filename Sanitisation
Removes release group tags, quality indicators, codec info, source tags, audio tags, edition tags, and normalises:
- Release groups: `AMIABLE`, `BAE`, `BLUEBIRD`, `BluHD`, `BLUTONiUM`, `BTN`, etc.
- Quality: `720p`, `1080p`, `2160p`, `4K`, `UHD`
- Codecs: `AVC`, `HEVC`, `x264`, `x265`, `H.264`, `H.265`, `DV`, `DoVi`, `DVHE`
- Sources: `BluRay`, `WEBDL`, `WEB-DL`, `WEBRip`, `Amazon`, `AMZN`, `ATVP`, `Disney`, `DSNP`, `Vimeo`
- Audio: `AC3`, `AAC2.0`, `Atmos`, `DDP`, `DTS`, `DTS-MA`, `DTS-X`, `FLAC`, `TrueHD`, `5.1`, `7.1`
- Editions: `Director's Cut`, `Extended Edition`
- Years: `19xx`, `20xx`
- Special characters, transliteration to ASCII

### 3. TV Show Detection
- Detects `SxxExx` pattern in filename
- Sets `IS_TVSHOW_EPISODE=true` if matched

### 4. Video Track Processing
| Input Format | Action |
|--------------|--------|
| AV1 | Convert to H.264 (`-c:v h264`) |
| VP9 | Convert to H.264 (`-c:v h264`) |
| H.264 / HEVC / other | Copy (`-c:v copy`) |

### 5. Audio Track Processing

#### Priority 1: Keep AAC/MP3 as-is
- First AAC or MP3 track copied without re-encoding
- If not track 0, marks modification applied

#### Priority 2: Convert first non-commentary track to AAC
- If no AAC/MP3 track, converts first non-commentary track to AAC

#### Additional Tracks (Movies only, or TV if `KEEP_ORIGINAL_AUDIO_TRACKS_FOR_TVSHOWS=true`)
- Discardable tracks removed: AC-3, E-AC-3, MP3, Opus, PCM, commentary tracks
- Non-discardable tracks copied

### 6. Subtitle Processing
- All subtitles removed from output (`-map -0:s`)
- Optional extraction before removal (interactive prompt)
- Extracted as SRT files with language codes
- Language detection from track name or metadata
- Duplicate language handling (e.g., `CHI`, `CHI2` → `CHI`)
- Region normalisation: `FRE-Canada` → `FRE`, `POR-Brazil` → `POR`, `SPA-LatinAmerica` → `SPA`
- Optional `fix-subtitle` post-processing if available

### 7. Container Conversion
- Non-MKV containers converted to MKV
- Non-Matroska format triggers full re-encode

### 8. Optimisation Execution
- Runs `ffmpeg` with computed arguments
- Output to `<filename>.OPTIMISED.mkv`
- Reports size before/after
- Shows `mkvmerge -i` output for verification

### 9. Replacement
- Interactive confirmation to replace original
- Removes original, renames optimised to sanitised name

## Dependencies

### Required
- `mkvtoolnix-cli` — `mkvmerge`, `mkvinfo` (track analysis)
- `ffmpeg` — Transcoding
- `perl-rename` — Filename sanitisation
- `glibc` — Core utilities

### Optional
- `fix-subtitle` — Subtitle post-processing (if in PATH)

## Exit Codes

| Code | Condition |
|------|-----------|
| 0 | Success (including "no optimisation needed") |
| 1 | File not found |
| 130 | Interrupted (SIGINT) during prompts |

## Output Example

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
-map 0:v:0 -c:v:0 h264 -map 0:a:0 -c:a:0 aac -map 0:a:1 -c:a:1 copy -map -0:s ...
Are you sure you want to optimise the video with the mentioned settings? [Y/n] Y
Optimising /path/video.mkv...
>>> DONE!
Size before: 4.2G
Size after: 2.8G
Do you want to replace the original file? [Y/n] Y
```

## Configuration (Hardcoded)

| Constant | Value | Description |
|----------|-------|-------------|
| `KEEP_ORIGINAL_AUDIO_TRACKS_FOR_TVSHOWS` | `false` | Keep all audio tracks for TV episodes |
| `KEEP_FORCED_SUBTITLES` | `false` | Keep forced subtitle tracks |
| `KEEP_SDH_SUBTITLES` | `false` | Keep SDH subtitle tracks |

## Limitations

- **Single file only** — No batch/directory processing
- **Interactive only** — No non-interactive/automated mode
- **MKV output only** — Always produces MKV
- **Hardcoded preferences** — No CLI flags for audio/subtitle policies
- **No dry-run** — Must confirm before actual conversion
- **No progress bar** — ffmpeg output only
- **No resume** — Interrupted runs cannot resume
- **Filename sanitisation aggressive** — May remove desired text

## Troubleshooting

### "Cannot access file"
- Check path exists and is readable
- Quote paths with spaces: `plex-video-optimiser "My Video.mkv"`

### "No optimisation needed"
- Video already H.264 in MKV
- Audio already AAC/MP3
- No subtitles
- Container already Matroska

### ffmpeg errors
- Check `ffmpeg` version supports required codecs
- Ensure disk space for temporary output
- Verify input file not corrupted

### Subtitle extraction fails
- `mkvinfo`/`mkvmerge` version mismatch
- Subtitle format not SRT/SubStationAlpha
- Install `fix-subtitle` for post-processing

### Permission denied on replace
- Ensure write permission on file and directory
- Check file not in use by another process

## Integration

### Automated Use (Not Supported)
```bash
# No non-interactive mode currently
# Would require script modification or expect/autoexpect
```

### Batch Processing Wrapper
```bash
#!/bin/bash
for f in *.mkv; do
    echo "Processing: $f"
    # Requires manual interaction per file
    plex-video-optimiser "$f"
done
```

## Version

Current: 1.7.0 (from PKGBUILD)