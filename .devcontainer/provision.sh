#!/usr/bin/env bash
# provision.sh — Provisioning de la distrobox "website"
#
# Installe ce dont le repo a besoin pour builder le CV :
#   - libs système nécessaires à la compilation des packages R
#   - packages R (rmarkdown, pagedown, yaml, rstudioapi)
#   - Google Chrome stable + shim --no-sandbox / --disable-dev-shm-usage
#   - Quarto (dernière version stable)
#   - prompt bash distrobox (📦) pour distinguer du shell hôte
#
# Idempotent : peut être relancé sans dommage. Chaque étape vérifie
# d'abord ce qui est déjà installé.
#
# Lancement :
#   bash $HOME/projects/website/.devcontainer/provision.sh   (depuis le conteneur)

set -euo pipefail

echo "════════════════════════════════════════════════════════"
echo "  Provisioning distrobox 'website'"
echo "════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────
# 1. Libs système pour la compilation des packages R
# ─────────────────────────────────────────────────────────────
# Ces paquets sont aussi listés dans distrobox.ini (additional_packages)
# pour être posés dès la création. Le filet ici sert si le hook initial
# n'a pas tourné, ou si on lance provision.sh sur un conteneur existant.

echo "▶ [1/5] Libs système (compilation R)"

SYS_PKGS=(
  build-essential pkg-config curl ca-certificates gnupg
  libssl-dev libxml2-dev libcurl4-openssl-dev
  libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev
  libpng-dev libtiff-dev libjpeg-dev
  zlib1g-dev libicu-dev libuv1-dev
)

MISSING=()
for p in "${SYS_PKGS[@]}"; do
  dpkg -s "$p" >/dev/null 2>&1 || MISSING+=("$p")
done

if [ "${#MISSING[@]}" -gt 0 ]; then
  echo "  → Installation de ${#MISSING[@]} paquet(s) manquant(s) : ${MISSING[*]}"
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends "${MISSING[@]}"
else
  echo "  ✓ Toutes les libs système sont présentes."
fi
echo ""

# ─────────────────────────────────────────────────────────────
# 2. Packages R (bibliothèque utilisateur, pas de sudo)
# ─────────────────────────────────────────────────────────────

echo "▶ [2/5] Packages R"

R_USER_LIB="$(R --no-save --quiet -s -e 'cat(Sys.getenv("R_LIBS_USER"))' | tail -1)"
mkdir -p "$R_USER_LIB"
echo "  Bibliothèque utilisateur : $R_USER_LIB"

R --no-save --quiet <<RSCRIPT
.libPaths(c("$R_USER_LIB", .libPaths()))
pkgs <- c("rmarkdown", "pagedown", "yaml", "rstudioapi")
missing <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(missing)) {
  cat("  → Installation :", paste(missing, collapse = ", "), "\n")
  install.packages(missing, lib = "$R_USER_LIB",
                   repos = "https://cloud.r-project.org", quiet = TRUE)
} else {
  cat("  ✓ Packages R déjà présents.\n")
}
RSCRIPT
echo ""

# ─────────────────────────────────────────────────────────────
# 3. Google Chrome stable + shim --no-sandbox
# ─────────────────────────────────────────────────────────────
# Pourquoi Chrome et pas Chromium ?
# Sur Ubuntu 26.04, le paquet `chromium-browser` est un wrapper qui
# réclame le snap chromium, et snapd ne tourne pas en conteneur.
# Notre tentative de bloquer le snap avec un paquet factice a échoué
# (le paquet officiel est réinstallé par apt update). La voie propre
# est d'utiliser le dépôt officiel Google Chrome qui fournit un vrai
# .deb signé et auto-mis-à-jour. Chrome et Chromium partagent le même
# moteur Blink — pagedown::chrome_print produit le même résultat.

echo "▶ [3/5] Google Chrome + shim --no-sandbox"

# 3a. Supprime le wrapper snap transitional s'il pollue le PATH
if dpkg -s chromium-browser >/dev/null 2>&1; then
  echo "  → Suppression du wrapper snap transitional chromium-browser"
  sudo apt-get remove -y chromium-browser
fi

# 3b. Installe Google Chrome stable depuis le dépôt officiel
if ! command -v google-chrome-stable >/dev/null 2>&1; then
  echo "  → Ajout du dépôt Google Chrome"
  if [ ! -f /usr/share/keyrings/google-chrome.gpg ]; then
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
      | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
  fi
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null

  echo "  → Installation de google-chrome-stable"
  sudo apt-get update -qq
  sudo apt-get install -y google-chrome-stable
else
  echo "  ✓ Google Chrome déjà installé : $(google-chrome-stable --version)"
fi

# 3c. Pose / met à jour le shim --no-sandbox (chemin absolu, pas de récursion)
#     Le shim ajoute les flags nécessaires en conteneur :
#       --no-sandbox            : sandbox Linux indisponible en conteneur
#       --disable-gpu           : pas de GPU exposé
#       --disable-dev-shm-usage : Chrome utilise /tmp au lieu de /dev/shm
echo "  → Pose du shim /usr/local/bin/chromium-browser"
sudo tee /usr/local/bin/chromium-browser >/dev/null <<'SHIM'
#!/usr/bin/env bash
# Shim Chrome avec flags pour conteneur. Le chemin du binaire est
# explicitement absolu pour éviter toute récursion via le PATH.
exec /usr/bin/google-chrome-stable \
  --no-sandbox \
  --disable-gpu \
  --disable-dev-shm-usage \
  "$@"
SHIM
sudo chmod +x /usr/local/bin/chromium-browser
echo "  ✓ Chrome + shim opérationnels."
echo ""

# ─────────────────────────────────────────────────────────────
# 4. Quarto (dernière version stable)
# ─────────────────────────────────────────────────────────────

echo "▶ [4/5] Quarto"

LATEST_VER="$(curl -sSL https://quarto.org/docs/download/_download.json \
              | grep -o '"version": "[^"]*' | grep -o '[^"]*$' | head -1)"

CURRENT_VER="$(quarto --version 2>/dev/null || echo none)"

if [ "$CURRENT_VER" = "$LATEST_VER" ]; then
  echo "  ✓ Quarto $CURRENT_VER déjà à jour."
else
  if [ "$CURRENT_VER" = "none" ]; then
    echo "  → Installation de Quarto $LATEST_VER..."
  else
    echo "  → Mise à jour de Quarto $CURRENT_VER → $LATEST_VER..."
  fi

  ARCH="amd64"
  [ "$(uname -m)" = "aarch64" ] && ARCH="arm64"

  TMP="$(mktemp -d)"
  curl -sSL -o "$TMP/quarto.deb" \
    "https://github.com/quarto-dev/quarto-cli/releases/download/v${LATEST_VER}/quarto-${LATEST_VER}-linux-${ARCH}.deb"
  sudo dpkg -i "$TMP/quarto.deb" >/dev/null 2>&1 || sudo apt-get install -f -y
  rm -rf "$TMP"
  echo "  ✓ Quarto $LATEST_VER installé."
fi
echo ""

# ─────────────────────────────────────────────────────────────
# 5. Prompt bash personnalisé (identifier visuellement la distrobox)
# ─────────────────────────────────────────────────────────────
# Sans ça, le prompt par défaut est cyril@fedora:~/... ce qui prête à
# confusion avec un shell hôte. On ajoute un marqueur visuel (📦 + nom
# de la box) pour distinguer instantanément.

echo "▶ [5/5] Prompt bash distrobox"

BASHRC="$HOME/.bashrc"
PROMPT_MARKER="# distrobox-website-prompt"

if grep -qF "$PROMPT_MARKER" "$BASHRC" 2>/dev/null; then
  echo "  ✓ Prompt déjà configuré dans ~/.bashrc"
else
  echo "  → Ajout du prompt distrobox à ~/.bashrc"
  cat >> "$BASHRC" <<'BASHRCEOF'

# distrobox-website-prompt
# Prompt visuel pour distinguer la distrobox "website" du shell hôte
if [ -f /run/.containerenv ] && grep -q '^name="website"' /run/.containerenv 2>/dev/null; then
  export PS1='📦[\u@website \W]\$ '
fi
BASHRCEOF
  echo "  ✓ Prompt ajouté. Rechargement automatique au prochain shell."
fi
echo ""

# ─────────────────────────────────────────────────────────────
# Vérifications finales
# ─────────────────────────────────────────────────────────────

echo "════════════════════════════════════════════════════════"
echo "  Vérifications"
echo "════════════════════════════════════════════════════════"

R_VER="$(R --version | head -1 | awk '{print $3}')"
CHROME_VER="$(google-chrome-stable --version 2>/dev/null || echo 'NON TROUVÉ')"
SHIM_PATH="$(command -v chromium-browser || echo 'NON TROUVÉ')"
QUARTO_VER="$(quarto --version 2>/dev/null || echo 'NON TROUVÉ')"
PANDOC_VER="$(pandoc --version | head -1 | awk '{print $2}')"

printf "  %-10s %s\n" "R"        "$R_VER"
printf "  %-10s %s\n" "Chrome"   "$CHROME_VER"
printf "  %-10s %s\n" "Shim"     "$SHIM_PATH"
printf "  %-10s %s\n" "Quarto"   "$QUARTO_VER"
printf "  %-10s %s\n" "Pandoc"   "$PANDOC_VER"
echo ""

# Test concret : pagedown trouve-t-il Chrome ?
echo "  Test pagedown::find_chrome() :"
FOUND_CHROME="$(R --no-save --quiet -s 2>/dev/null <<'RTEST'
.libPaths(c(Sys.getenv("R_LIBS_USER"), .libPaths()))
if (requireNamespace("pagedown", quietly = TRUE)) {
  tryCatch(cat(pagedown::find_chrome()),
           error = function(e) cat("ERREUR:", conditionMessage(e)))
} else {
  cat("PACKAGE_MANQUANT")
}
RTEST
)"

if [ -z "$FOUND_CHROME" ] || [[ "$FOUND_CHROME" == ERREUR* ]] || [ "$FOUND_CHROME" = "PACKAGE_MANQUANT" ]; then
  echo "  ⚠️  find_chrome a échoué : $FOUND_CHROME"
else
  echo "  ✓ $FOUND_CHROME"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "  ✅ Provisioning terminé"
echo ""
echo "  Pour builder le CV :"
echo "    cd $HOME/projects/website && Rscript cv/build_resume.R"
echo "════════════════════════════════════════════════════════"
