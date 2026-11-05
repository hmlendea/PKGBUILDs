# PKGBUILDs Documentation

Master index and navigation for the PKGBUILDs repository documentation.

## Repository Summary

This repository provides a personal Arch Linux package repository containing custom and unofficial packages. The architecture encompasses the build pipeline (`makepkgs.sh`), package definitions (`pkg/*/PKGBUILD`), and the distribution mechanism via GitHub Releases. Four packages are currently maintained: `grub2-theme-nuci`, `hori-fonts`, `image-optimiser`, and `plex-video-optimiser`.

## Root Document Map

- [ARCHITECTURE.md](../ARCHITECTURE.md) — High-level architecture overview
- [SECURITY.md](../SECURITY.md) — Security policy and vulnerability reporting
- [PRIVACY.md](../PRIVACY.md) — Privacy and personal data handling
- [CODE_OF_CONDUCT.md](../CODE_OF_CONDUCT.md) — Community conduct guidelines
- [CONTRIBUTING.md](../CONTRIBUTING.md) — Contribution guidelines
- [README.md](../README.md) — Project overview and usage instructions

## Documentation Catalogue

### Architecture & Design
- [Architecture](./architecture.md) — Detailed architectural elaboration complementing root ARCHITECTURE.md
- [Design Decisions](./design-decisions.md) — Key architectural choices and rationale
- [Repository Structure](./repository-structure.md) — Source tree layout and module organisation
- [Data Model](./data-model.md) — Domain entities, relationships, and persistence

### Build & Deployment
- [Build and Deployment](./build-and-deployment.md) — Build pipeline, deployment, environments
- [Configuration](./configuration.md) — Configuration schema, sources, precedence
- [Dependencies](./dependencies.md) — External and internal dependencies

### Components & Flows
- [Components](./components/) — Per-component deep dives
  - [Build Pipeline](./components/build-pipeline.md) — makepkgs.sh orchestration
  - [Package Definitions](./components/package-definitions.md) — PKGBUILD structure and conventions
  - [Repository Generation](./components/repository-generation.md) — repo-add database creation
- [Flows](./flows/) — End-to-end execution flows
  - [Package Build Flow](./flows/package-build.md) — Single package build process
  - [Repository Generation Flow](./flows/repository-generation.md) — Database regeneration process
  - [Release Distribution Flow](./flows/release-distribution.md) — GitHub Releases publication

### Operations & Maintenance
- [Change Guide](./change-guide.md) — How to modify common areas safely
- [Testing](./testing.md) — Test strategy, organisation, coverage
- [Troubleshooting](./troubleshooting.md) — Common issues and solutions
- [Documentation Maintenance](./documentation-maintenance.md) — How to keep docs current, ownership

### Reference
- [API Reference Index](./api-reference/INDEX.md) — Package CLI reference (not HTTP API)
- [Invariants](./invariants.md) — System-wide invariants and contracts
- [Error Handling](./error-handling.md) — Error taxonomy, handling patterns, recovery
- [Logging](./logging.md) — Logging framework, levels, structured fields, correlation
- [Security](./security.md) — Security model elaboration complementing root SECURITY.md
- [FAQ](./faq.md) — Frequently asked questions
- [Quick Start](./quick-start.md) — Getting started guide for newcomers
- [Ambiguities and Open Questions](./ambiguities-and-open-questions.md) — Unresolved items, TODOs, known gaps

## Navigation Aids

- **Start here** (newcomers): [Quick Start](./quick-start.md) → [Repository Overview](./repository-overview.md) → [Build and Deployment](./build-and-deployment.md)
- **Deep dive** (component owners): [Components](./components/) → [Flows](./flows/) → [Data Model](./data-model.md)
- **Flows** (debuggers): [Flows](./flows/) → [Error Handling](./error-handling.md) → [Troubleshooting](./troubleshooting.md)

## Maintenance Metadata

- Last reviewed: 2026-11-05
- Owner: hmlendea
- Coverage status: Initial generation complete