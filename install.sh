#!/bin/bash
# =============================================================================
# Script: install.sh
# Projekt: SPARBS - Simple Personal Auto-Rice Bootstrapping Script
# Autor: Dein Name
# Version: 0.1
# =============================================================================
# SYNOPSIS:
#     ./install.sh [--help]
#
# BESCHREIBUNG:
#     Automatisiertes Setup für Arch-basierte Systeme (inkl. CachyOS).
#     Installiert Basis-Pakete aus packages.txt und verlinkt Dotfiles.
#
# OPTIONS:
#     --help     Zeigt diese Hilfe an.
#
# USAGE:
#     ./install.sh
#
# =============================================================================

set -euo pipefail
# -e           → Script bricht bei jedem Fehler ab
# -u           → Fehler bei nicht gesetzten Variablen
# -o pipefail  → Pipeline-Fehler werden erkannt

# --- Hilfe-Funktion ---
if [[ "${1:-}" == "--help" ]]; then
  grep '^#' "$0" | sed 's/^#//'
  exit 0
fi

echo "🚀 Starte SPARBS Setup..."

# --- Liste bekannter Arch-Derivate ---
ARCH_LIKE_IDS=("arch" "manjaro" "cachyos" "endeavouros")

# --- Prüfen, ob /etc/os-release existiert ---
if [ -f /etc/os-release ]; then
  . /etc/os-release

  is_arch=false
  for id in "${ARCH_LIKE_IDS[@]}"; do
    if [[ "$ID" == "$id" ]]; then
      is_arch=true
      break
    fi
  done

  if [ "$is_arch" = false ]; then
    echo "❌ Kein unterstütztes Arch-basiertes System erkannt (ID=$ID)"
    exit 1
  fi

  echo "✅ Arch-basiertes System erkannt: $NAME ($ID)"

else
  echo "❌ /etc/os-release nicht gefunden. Kann Distribution nicht erkennen."
  exit 1
fi

# --- Prüfen, ob pacman installiert ist ---
if ! command -v pacman >/dev/null 2>&1; then
  echo "❌ Pacman nicht gefunden. Script kann nicht fortfahren."
  exit 1
fi

echo "📦 Pacman gefunden, System kann verwaltet werden"

# --- System aktualisieren ---
echo "📥 Aktualisiere Pakete..."
sudo pacman -Syu --noconfirm

# --- Pakete aus packages.txt installieren ---
echo "📥 Installiere Pakete aus packages.txt..."
while IFS= read -r pkg; do
  [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
  sudo pacman -S --needed --noconfirm "$pkg"
done <"$(dirname "$0")/packages.txt"

# --- Dotfiles verlinken (relativ zum Script-Verzeichnis) ---
DOTFILES_DIR="$(dirname "$0")/dotfiles"
echo "🔗 Verlinke Dotfiles aus: $DOTFILES_DIR"

for file in "$DOTFILES_DIR"/*; do
  filename="$(basename "$file")"
  ln -sf "$file" "$HOME/$filename"
  echo "  -> $filename verlinkt"
done

echo "✅ SPARBS Setup abgeschlossen!"
