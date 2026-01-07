# Nix LaTeX Template

A reproducible LaTeX development environment using Nix Flakes. It features background compilation (`latexmk`), process management, and SVG support via Inkscape.

## Requirements

* **[Nix](https://nixos.org/download.html)** with **Flakes** enabled
* **[direnv](https://direnv.net/)** (recommended for auto-loading)

## Usage

1. **Enter the shell:**
   ```bash
   direnv allow
   ```

2. **Start compilation (watches for changes):**
   ```bash
   start
   ```
   *Default target: `main.tex`*

## Commands

| Command | Description |
| :--- | :--- |
| `start` | Start `latexmk` in the background (watch mode). |
| `stop` | Stop the background process. |
| `status`| Check if the process is running. |
| `log` | Tail the build logs (`latexmk.log`). |
| `clean` | Remove auxiliary files. |

## Configuration

Edit `flake.nix` to customize:
* **Target File:** Change `texTarget = "main.tex";`
* **Packages:** Add packages to the `pkgs.texlive.combine` list.
