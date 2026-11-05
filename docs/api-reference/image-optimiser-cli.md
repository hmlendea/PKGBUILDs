# image-optimiser CLI Reference

## Overview

Lossless JPEG and PNG image optimisation tool. Processes files or directories recursively.

## Installation

```bash
pacman -S image-optimiser
```

## Usage

```bash
image-optimiser [PATH...]
```

## Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `PATH` | string | Yes | File or directory to optimise. Multiple paths accepted. |

## Options

| Option | Description |
|--------|-------------|
| `--help` | Show help message (not implemented, shows usage error) |

## Supported Formats

| Format | Optimiser | Fallback |
|--------|-----------|----------|
| PNG | `oxipng -o max --preserve --alpha` | `zopflipng -y -m` |
| JPEG/JPG | `jpegoptim --preserve --preserve-perms --all-progressive -o --strip-all` | None |

## Behaviour

### File Discovery
- Recursively finds `*.jpg`, `*.jpeg`, `*.png` files in given paths
- Processes each file in-place (overwrites original)
- Skips non-existent paths with warning
- Skips unsupported formats with warning

### Optimisation Process
1. Calculate original file size
2. Run appropriate optimiser based on extension
3. Calculate final file size
4. Report per-file and total savings

### Output Format
```
File #1: '/path/to/image.jpg'
Size: 2.5M -> 1.8M

File #2: '/path/to/image.png'
Size: 512K -> 384K

Finished processing 2 images
Size: 3.0M -> 2.2M
```

## Dependencies

### Required
- `jpegoptim` — JPEG optimisation
- `oxipng` — PNG optimisation (preferred)

### Optional
- `zopfli` — PNG optimisation fallback (if `oxipng` unavailable)
- `coreutils` — `numfmt`, `du`, `find`, `awk` (standard)

## Exit Codes

| Code | Condition |
|------|-----------|
| 0 | Success (even if some files skipped) |
| 1 | General error (not explicitly used) |
| 130 | Interrupted (SIGINT) |

## Examples

### Optimise Single File
```bash
image-optimiser photo.jpg
```

### Optimise Directory Recursively
```bash
image-optimiser ~/Pictures/
```

### Optimise Multiple Paths
```bash
image-optimiser photo1.jpg photo2.png ~/Pictures/vacation/
```

## Error Handling

| Scenario | Behaviour |
|----------|-----------|
| Path does not exist | Warning printed, continues |
| Unsupported format | Warning printed, continues |
| `oxipng` not found | Falls back to `zopflipng` |
| `zopflipng` not found | PNG files skipped |
| `jpegoptim` not found | JPEG files fail (no fallback) |
| Permission denied | Error from underlying tool |
| Disk full | Error from underlying tool |

## Performance

- **Parallelisation**: None (sequential file processing)
- **Memory**: Minimal (streaming)
- **Disk I/O**: Reads and writes each file once
- **Typical speedup**: 10-40% size reduction for JPEG, 5-20% for PNG

## Limitations

- No dry-run mode
- No quality/aggressiveness options
- No backup of original files
- No progress bar for large batches
- No EXIF preservation control (jpegoptim `--preserve` keeps all)
- No recursive directory exclusion patterns

## Integration

### In Scripts
```bash
#!/bin/bash
image-optimiser /path/to/images/
# Check exit code
if [ $? -eq 0 ]; then
    echo "Optimisation complete"
fi
```

### With find
```bash
# Only JPEG files
find /path -name '*.jpg' -exec image-optimiser {} +

# Only PNG files
find /path -name '*.png' -exec image-optimiser {} +
```

## Troubleshooting

### "command not found: oxipng"
```bash
pacman -S oxipng
# or
pacman -S zopfli  # fallback
```

### "command not found: jpegoptim"
```bash
pacman -S jpegoptim
```

### No size reduction
- File already optimised
- Format not supported (check extension case-sensitivity)
- Tool version too old

### Permission denied
```bash
# Ensure write permission on files
chmod u+w /path/to/images/*
```