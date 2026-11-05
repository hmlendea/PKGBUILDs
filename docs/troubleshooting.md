# Troubleshooting

## Build Issues

### makepkg: checksum mismatch
```
==> Validating source files with sha512sums...
    source-file.tar.gz ... FAILED
==> ERROR: One or more files did not pass the validity check!
```
**Cause**: Upstream source changed, PKGBUILD checksums outdated.
**Fix**:
```bash
cd pkg/<package>
updpkgsums
bash makepkgs.sh
```

### makepkg: missing dependency
```
==> Installing missing dependencies...
error: target not found: <package>
==> ERROR: 'pacman' failed to install missing dependencies.
```
**Cause**: Dependency not in repositories or wrong name.
**Fix**:
1. Check correct package name: `pacman -Ss <name>`
2. Update `depends`/`makedepends` in PKGBUILD
3. If AUR dependency: add to `makedepends` and build manually first

### makepkg: build() failed
```
==> Starting build()...
./configure: error: something
==> ERROR: A failure occurred in build().
```
**Cause**: Compilation error, missing build tools, source issue.
**Fix**:
1. Check `build()` function in PKGBUILD
2. Ensure `base-devel` installed
3. Check upstream build instructions
4. Add missing `makedepends`

### makepkg: permission denied
```
==> Entering fakeroot environment...
==> Starting package()...
install: cannot create regular file '/usr/bin/...': Permission denied
```
**Cause**: `package()` function writing outside `$pkgdir`.
**Fix**: Ensure all install commands use `$pkgdir/` prefix.

### Artifact not copied to repo/
```
cp: cannot stat 'pkg/<name>/<name>-<ver>-<rel>-<arch>.pkg.tar.zst': No such file or directory
```
**Cause**: `makepkg` output directory changed (`PKGDEST`, `BUILDDIR` env vars).
**Fix**: Check `makepkg.conf` or environment variables. Build in clean environment.

## Repository Generation Issues

### repo-add: database locked
```
==> ERROR: Failed to lock database: File exists
```
**Cause**: Previous `repo-add` crashed, left lock file.
**Fix**:
```bash
rm repo/*.db.lock
bash makepkgs.sh
```

### repo-add: invalid package
```
==> ERROR: '<package>.pkg.tar.zst' is not a valid package file
```
**Cause**: Corrupt package file, wrong format.
**Fix**:
```bash
rm repo/<package>.pkg.tar.zst
bash makepkgs.sh
```

### Database verification fails
```
repo-add --verify repo/hmlendea.db.tar.gz
==> ERROR: Database is corrupted
```
**Cause**: Partial `repo-add` run, disk corruption.
**Fix**:
```bash
rm repo/*.db repo/*.files repo/*.db.tar.gz repo/*.files.tar.gz
bash makepkgs.sh
```

## Installation Issues (Target System)

### pacman: signature invalid
```
error: <package>: signature from "..." is invalid
error: failed to commit transaction (invalid or corrupted package)
```
**Cause**: Package signed but key not trusted, or corrupt download.
**Fix**:
```ini
# /etc/pacman.conf
[hmlendea]
SigLevel = PackageOptional
```
Or import key: `pacman-key --add key.pub && pacman-key --lsign-key <keyid>`

### pacman: database not found
```
error: failed to update hmlendea (download library error)
```
**Cause**: Repository URL wrong, network issue, release doesn't exist.
**Fix**:
1. Check URL in pacman.conf
2. Verify release exists on GitHub
3. Try `latest/download/` vs specific version

### pacman: package not found
```
error: target not found: <package>
```
**Cause**: Package not in repository for current architecture.
**Fix**:
```bash
pacman -Sl hmlendea  # List available
# Check architecture compatibility
```

### pacman: conflicting files
```
error: failed to commit transaction (conflicting files)
<package>: /usr/bin/... exists in filesystem
```
**Cause**: File owned by another package, or manual installation.
**Fix**:
```bash
pacman -Qo /usr/bin/...  # Find owner
# Remove conflicting package or file
```

## CLI Tool Issues

### image-optimiser: command not found
```
bash: image-optimiser: command not found
```
**Cause**: Package not installed, or `/usr/bin` not in PATH.
**Fix**:
```bash
pacman -Q image-optimiser  # Check installed
echo $PATH  # Check PATH
```

### image-optimiser: no size reduction
```
File #1: 'image.jpg'
Size: 2.5M -> 2.5M
```
**Cause**: Already optimised, or tool not working.
**Fix**:
1. Check `jpegoptim`/`oxipng` installed
2. Try manually: `jpegoptim --strip-all image.jpg`
3. File may already be optimal

### image-optimiser: oxipng not found
```
The 'png' file format is not supported.
```
**Cause**: Neither `oxipng` nor `zopfli` installed.
**Fix**:
```bash
pacman -S oxipng
# or
pacman -S zopfli
```

### plex-video-optimiser: ffmpeg not found
```
ffmpeg: command not found
```
**Cause**: `ffmpeg` not installed.
**Fix**:
```bash
pacman -S ffmpeg
```

### plex-video-optimiser: mkvmerge not found
```
mkvmerge: command not found
```
**Cause**: `mkvtoolnix-cli` not installed.
**Fix**:
```bash
pacman -S mkvtoolnix-cli
```

### plex-video-optimiser: perl-rename not found
```
perl-rename: command not found
```
**Cause**: `perl-rename` not installed.
**Fix**:
```bash
pacman -S perl-rename
```

### plex-video-optimiser: "No optimisation needed"
```
No optimisation needed!
```
**Cause**: File already meets criteria:
- Video: H.264 (not HEVC/VP9/AV1)
- Audio: AAC or MP3
- Container: MKV (Matroska)
- No subtitles
**Fix**: No action needed. File is already optimal.

### plex-video-optimiser: permission denied on replace
```
rm: cannot remove '...': Permission denied
```
**Cause**: File owned by root, or directory not writable.
**Fix**:
```bash
sudo chown $USER: /path/to/file
# or run with sudo (not recommended for user files)
```

### plex-video-optimiser: interrupted during prompts
```
^C
```
**Cause**: User pressed Ctrl+C at interactive prompt.
**Fix**: Re-run tool. Original file unchanged.

## Network Issues

### GitHub Releases download slow/fails
**Cause**: GitHub rate limiting, network issues, regional CDN.
**Fix**:
1. Retry: `pacman -Sy`
2. Use specific release URL instead of `latest/download/`
3. Check GitHub status page

### Source download fails during build
```
==> Downloading <package> source...
curl: (22) The requested URL returned error: 404
```
**Cause**: Upstream moved/removed source file.
**Fix**:
1. Find new source URL
2. Update `source` in PKGBUILD
3. Run `updpkgsums`
4. Rebuild

## Disk Space Issues

### No space left on device
```
write failed: No space left on device
```
**Cause**: Build artifacts, package cache, or repo directory full.
**Fix**:
```bash
# Clean pacman cache
pacman -Sc

# Clean build artifacts
rm -rf pkg/*/pkg/ pkg/*/src/

# Clean repo (will rebuild)
rm repo/*.pkg.tar.zst repo/*.db repo/*.files repo/*.db.tar.gz repo/*.files.tar.gz
```

## Debugging Tips

### Verbose Build Output
```bash
# makepkg verbose
cd pkg/<package>
makepkg -Csrf --noconfirm --verbose
```

### Inspect Package Contents
```bash
# List files
pacman -Ql --dbpath repo/ <package>

# Extract and examine
mkdir /tmp/inspect && cd /tmp/inspect
tar -xzf /path/to/package.pkg.tar.zst
cat .PKGINFO
cat .MTREE
```

### Check PKGBUILD Syntax
```bash
bash -n pkg/<package>/PKGBUILD
```

### Static Analysis
```bash
namcap pkg/<package>/PKGBUILD
```

### Test in Clean Container
```bash
docker run --rm -v $(pwd):/build -w /build archlinux:base-devel \
    bash -c "pacman -Sy --noconfirm && bash makepkgs.sh"
```

### Enable Debug Logging
```bash
# For makepkgs.sh
bash -x makepkgs.sh 2>&1 | tee debug.log

# For CLI tools
bash -x /usr/bin/image-optimiser test.jpg
bash -x /usr/bin/plex-video-optimiser test.mkv
```

## Getting Help

### Check Logs
- Build output: `makepkgs.sh` stdout/stderr
- Pacman log: `/var/log/pacman.log`
- System journal: `journalctl -u pacman`

### Search Existing Issues
- GitHub Issues on repository
- Arch Linux forums
- Package-specific upstream issues

### Report New Issue
Include:
- Command that failed
- Full error output
- `pacman -Qi <package>` output
- System info: `uname -a`, `pacman -Q pacman`