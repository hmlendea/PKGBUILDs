# Security

## Threat Model

### Assets
- Package source code and build recipes (PKGBUILDs)
- Built package artifacts (`.pkg.tar.zst`)
- Repository databases (`.db`, `.files`)
- GitHub repository and releases
- Target systems installing packages

### Actors
- **Maintainer**: Authorised to modify PKGBUILDs, trigger builds, publish releases
- **Contributors**: Submit PRs with PKGBUILD changes
- **Users**: Install packages via pacman from GitHub Releases
- **Attackers**: Network adversaries, compromised dependencies, malicious PRs

### Trust Boundaries
```
[Maintainer Machine] → [GitHub Repo] → [GitHub Actions] → [GitHub Releases] → [User Machine]
       ↑                    ↑                  ↑                    ↑                ↑
   Trusted              Trusted            Trusted              Public           Trusts
   Environment          Source             Build                Distribution     Repository
```

## Current Security Posture

### Supply Chain
| Component | Status | Risk |
|-----------|--------|------|
| Source verification | `sha512sums` in PKGBUILD | Medium — manual update required |
| Build reproducibility | Not enforced | High — no reproducible builds |
| Dependency pinning | Version ranges in `depends` | Medium — floating versions |
| Build isolation | `makepkg -C` (clean chroot) | Low — clean build per package |
| Artifact signing | **None** | High — unsigned packages |
| Database signing | **None** | High — unsigned databases |

### Distribution
| Component | Status | Risk |
|-----------|--------|------|
| Transport | HTTPS (GitHub Releases) | Low — TLS |
| Integrity verification | None (PackageOptional) | High — no signature verification |
| Repository authentication | None | High — anyone can spoof |
| Key management | None | N/A |

### Runtime (Installed Packages)
| Package | Attack Surface | Mitigations |
|---------|----------------|-------------|
| `grub2-theme-nuci` | Theme files in `/boot/grub/themes/` | Read-only, no execution |
| `hori-fonts` | Font files in `/usr/share/fonts/` | Read-only, no execution |
| `image-optimiser` | Bash script, calls `jpegoptim`, `oxipng` | User-run, no privileges |
| `plex-video-optimiser` | Bash script, calls `ffmpeg`, `mkvtoolnix` | User-run, no privileges |

## Vulnerabilities

### Known Issues

1. **Unsigned Packages** — No GPG signatures on packages or databases
   - Impact: MITM can replace packages
   - Mitigation: `SigLevel = PackageOptional` (current), migrate to `PackageRequired`

2. **No Reproducible Builds** — Build output not deterministic
   - Impact: Cannot verify binary matches source
   - Mitigation: Use `makepkg --reproducible` (requires SOURCE_DATE_EPOCH)

3. **Floating Dependencies** — `depends=('ffmpeg')` not pinned
   - Impact: Dependency updates may break packages
   - Mitigation: Pin versions where critical

4. **Checksum Maintenance** — Manual `updpkgsums` required
   - Impact: Stale checksums cause build failures or accept changed sources
   - Mitigation: Automate in CI

5. **No SBOM** — No Software Bill of Materials
   - Impact: Cannot track transitive dependencies
   - Mitigation: Generate from PKGBUILD `depends`/`makedepends`

### Potential Attack Vectors

| Vector | Likelihood | Impact | Current Defence |
|--------|------------|--------|-----------------|
| Malicious PR modifying PKGBUILD | Medium | High | Code review required |
| Compromised upstream source | Low | High | sha512sums verification |
| GitHub Actions compromise | Low | High | GitHub security |
| MITM on GitHub Releases | Low | High | HTTPS only |
| Malicious package install | Low | Medium | User trusts repo |

## Hardening Recommendations

### Immediate (High Priority)

1. **Sign Packages and Databases**
   ```bash
   # Generate key
   gpg --gen-key

   # Sign packages
   gpg --detach-sign *.pkg.tar.zst

   # Sign databases
   repo-add --sign --key <keyid> database.db.tar.gz package.pkg.tar.zst

   # Target system
   SigLevel = PackageRequired
   pacman-key --add pubkey.gpg
   pacman-key --lsign-key <keyid>
   ```

2. **Enable Reproducible Builds**
   ```bash
   # In makepkgs.sh
   export SOURCE_DATE_EPOCH=$(date +%s)
   makepkg -Csrf --noconfirm --reproducible
   ```

3. **Pin Critical Dependencies**
   ```bash
   # In PKGBUILD
   depends=('ffmpeg>=6.0' 'ffmpeg<7.0')
   ```

### Short Term (Medium Priority)

4. **Automate Checksum Updates**
   ```yaml
   # GitHub Actions
   - name: Update checksums
     run: |
       for pkg in pkg/*/; do
         cd "$pkg"
         updpkgsums
       done
   ```

5. **Add SBOM Generation**
   ```bash
   # Extract dependencies from all PKGBUILDs
   grep -h "^depends=" pkg/*/PKGBUILD | sort -u
   ```

6. **CI Security Scanning**
   ```yaml
   # GitHub Actions
   - name: Scan for secrets
     uses: trufflesecurity/trufflehog@main
   - name: Check PKGBUILD syntax
     run: |
       for pkg in pkg/*/; do
         bash -n "$pkg/PKGBUILD"
         namcap "$pkg/PKGBUILD"
       done
   ```

### Long Term (Low Priority)

7. **Supply Chain Attestation**
   - SLSA Level 1: Build scripted, provenance generated
   - SLSA Level 2: Tamper-resistant build service
   - SLSA Level 3: Hardened build platform

8. **Dependency Monitoring**
   - Renovate/Dependabot for PKGBUILD dependencies
   - CVE scanning for packaged software

## Secure Development Practices

### PKGBUILD Review Checklist
- [ ] `source` URLs use HTTPS
- [ ] `sha512sums` present for all sources
- [ ] No hardcoded secrets or tokens
- [ ] `depends`/`makedepends` minimal and correct
- [ ] `package()` function only installs to `$pkgdir`
- [ ] No arbitrary code execution in `build()`/`package()`
- [ ] Version bump includes `pkgrel` increment

### Release Process
- [ ] Build on clean machine or CI
- [ ] Verify all packages build successfully
- [ ] Verify databases generate correctly
- [ ] Sign artifacts (when implemented)
- [ ] Tag release with semantic version
- [ ] Publish to GitHub Releases
- [ ] Verify `pacman -Sy` works on test machine

### Key Management (Future)
- Offline master key
- Online signing subkey
- Key rotation policy
- Revocation procedure

## Incident Response

### Compromised Package
1. Remove from GitHub Releases
2. Delete Git tag
3. Fix PKGBUILD
4. Rebuild and re-release with incremented `pkgrel`
5. Notify users if critical

### Compromised Signing Key
1. Revoke key
2. Generate new key
3. Re-sign all packages
4. Publish new public key
5. Users must re-import key

### Malicious PR Merged
1. Revert commit
2. Audit all changes by that contributor
3. Rebuild affected packages
4. Force-push corrected tag (if released)

## Compliance

### Arch Linux Packaging Standards
- Follows [Arch Packaging Standards](https://wiki.archlinux.org/title/Arch_packaging_standards)
- Uses `makepkg` for building
- PKGBUILD format compliant
- Database format compatible with `pacman`

### Licensing
- Each package declares `license` in PKGBUILD
- Source licenses included where required
- No license conflicts in dependencies

## Security Contacts

- Repository maintainer: GitHub issues
- No dedicated security email
- No bug bounty program