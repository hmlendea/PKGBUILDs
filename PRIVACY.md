# Privacy and Personal Data

This document describes how the PKGBUILDs repository at https://github.com/hmlendea/PKGBUILDs handles personal data. It covers the repository behaviour and verified integrations described below. Where the software is self-hosted, the instance operator may have separate responsibilities described below.

## 📑 Table of Contents

- [What This Document Covers](#what-this-document-covers)
- [Self-Hosted Deployments](#self-hosted-deployments)
- [Data We Handle](#data-we-handle)
  - [Data Provided to the Application](#data-provided-to-the-application)
  - [Data Generated or Collected by the Application](#data-generated-or-collected-by-the-application)
  - [Data Received from Integrations](#data-received-from-integrations)
- [Processing and Use](#processing-and-use)
- [Storage, Retention, and Deletion](#storage-retention-and-deletion)
- [External Processing and Integrations](#external-processing-and-integrations)
- [Document Changes](#document-changes)
- [Contact](#contact)

## 🔎 What This Document Covers

This document describes how the PKGBUILDs repository at https://github.com/hmlendea/PKGBUILDs handles personal data. It covers the repository behaviour and verified integrations described below. Where the software is self-hosted, the instance operator may have separate responsibilities described below.

## 🏠 Self-Hosted Deployments

This repository provides PKGBUILD scripts and built packages for Arch Linux. Users who add the repository to their `/etc/pacman.conf` operate their own package manager instance. The repository maintainers do not control user systems, local package caches, pacman logs, or system configurations. No data is sent from a user's system to the repository maintainers or external services by the packages or repository infrastructure. Package downloads occur directly from GitHub Releases; GitHub's own privacy policy applies to that traffic.

## 📥 Data We Handle

### Data Provided to the Application

No personal data is requested, collected, or processed by the repository, the build scripts, or the distributed packages.

### Data Generated or Collected by the Application

No personal data is generated or collected automatically by the repository, the build scripts, or the distributed packages.

### Data Received from Integrations

No personal data is received from integrations or third parties.

## 🧭 Processing and Use

The repository and its packages do not process personal data. The sole function is building and distributing Arch Linux packages.

## 🗄️ Storage, Retention, and Deletion

No personal data is stored by the repository, the build scripts, or the distributed packages. GitHub stores repository metadata (commits, issues, releases) according to its own policies. Users' local package caches and pacman databases are controlled entirely by the system operator.

## 🔗 External Processing and Integrations

The repository uses GitHub Actions for continuous integration and GitHub Releases for package distribution. GitHub processes repository metadata and release assets according to its privacy policy. No additional external services process data on behalf of this repository.

| Service or integration | Purpose | Data involved | Configuration or documentation |
|-----------------------|---------|---------------|--------------------------------|
| GitHub Actions | Continuous integration builds | Repository source code, build logs | https://docs.github.com/en/actions |
| GitHub Releases | Package distribution | Built package artifacts | https://docs.github.com/en/repositories/releasing-projects-on-github |

## 🔄 Document Changes

Update this document when repository data flows, storage, integrations, or deployment responsibilities change. The current version is published at https://github.com/hmlendea/PKGBUILDs/blob/main/PRIVACY.md.

## 📬 Contact

For questions about repository data handling, contact the project maintainers via GitHub Issues at https://github.com/hmlendea/PKGBUILDs/issues. For a self-hosted package manager instance, contact the system operator. Include the package name and repository URL if relevant; do not send passwords, access tokens, or other secrets.