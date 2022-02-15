# PKGBUILDs
Horațiu Mlendea's Arch Linux repository

# Installation

To use this repository, add the below lines at the end of ```/etc/pacman.conf```

## Main repository

**Note:** Most packages are found in this one, and are available for the `any` architecture.

```ini
[hmlendea]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

## Extra architectures

These are **optional** extra repository databases that contain architecture-specific packages that are not found in the main `hmlendea` database.


**`aarch64` architecture:**
```ini
[hmlendea-aarch64]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

**`armv7h` architecture:**
```ini
[hmlendea-armv7h]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

**`i686` architecture:**
```ini
[hmlendea-i686]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

**`x86_64` architecture:**
```ini
[hmlendea-x86_64]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```
