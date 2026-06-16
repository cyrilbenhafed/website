# Contexte projet `website` pour Claude Code

> À placer dans `~/projects/website/CLAUDE.md` (ou autre nom selon ta
> convention) pour donner à Claude Code le contexte du projet à chaque
> session. Claude Code lit automatiquement ce fichier s'il porte le
> bon nom (`CLAUDE.md` recommandé).

---

## Qu'est-ce que ce repo

Site personnel de Cyril Benhafed : **vitrine** (`benhafed.com`) + **CV** (`benhafed.com/cv/`).
Le **blog** est hébergé dans un repo séparé (`blog`, Quarto) sur `blog.benhafed.com`.

## Stack

- **Vitrine** : HTML/CSS/JS vanilla, à la racine du repo. Aucun build.
- **CV** : R + pagedown, sources dans `cv/`. Build local avec
  `Rscript cv/build_resume.R` qui produit `cv/resume_{fr,en}.{html,pdf}`.
- **Environnement de dev** : distrobox `website` sur image `ubuntu:26.04`,
  définie dans `.devcontainer/distrobox.ini` et provisionnée par
  `.devcontainer/provision.sh` (R packages, Chrome stable + shim
  conteneur, Quarto, prompt visuel `📦`).
- **Editor** : VS Code (RPM sur Fedora Workstation). Le repo embarque
  `.vscode/settings.json` qui ouvre tout terminal VS Code dans la
  distrobox.

## Décisions architecturales clés

1. **Fil rouge visuel inter-surfaces** : la vitrine, le CV et le blog
   partagent une **barre de navigation au même concept** (fond
   `#1a202c`, accent `#667eea`, nom « Cyril Benhafed » comme ancre,
   liens contextuels propres). Indépendant des stacks (vanilla, R/pagedown,
   Quarto).

2. **Pas de volume custom dans `distrobox.ini`** : distrobox monte
   automatiquement `$HOME` dans le conteneur. Le repo est accessible
   à son chemin hôte naturel (par défaut `~/projects/website`) depuis
   l'intérieur du conteneur. Ne pas réintroduire de `volume=` custom.

3. **Chrome stable, pas Chromium** : sur Ubuntu 26.04, `apt install
   chromium-browser` installe un wrapper snap qui ne tourne pas en
   conteneur. On installe Google Chrome stable depuis le dépôt
   officiel Google, avec un shim `/usr/local/bin/chromium-browser`
   pointant en chemin **absolu** vers `/usr/bin/google-chrome-stable`
   avec les flags `--no-sandbox --disable-gpu --disable-dev-shm-usage`.
   Le chemin absolu évite toute récursion. Ne pas tenter de revenir
   à Chromium "par naïveté".

4. **Build du CV indépendant du cwd** : `build_resume.R` détecte son
   propre emplacement et fait `setwd()` automatiquement. Lançable
   depuis n'importe où via `Rscript cv/build_resume.R` ou depuis `cv/`
   directement.

5. **Sorties du CV versionnées dans le repo** : `resume_{fr,en}.{html,pdf}`
   sont commitées et servies tel quel par GitHub Pages. La question
   de retirer ce versionnement au profit d'une CI obligatoire est
   ouverte mais pas encore tranchée.

## Conventions

- **Branches** : `main` = prod (`benhafed.com`), `dev` = preprod (URL
  GitHub Pages exotique), `feat/xxx` ou `fix/xxx` pour le travail
  local. Workflow PR `feat → dev → main` calqué sur le repo `blog`.
- **Langue du commit** : anglais (conventional commits :
  `feat:`, `fix:`, `build:`, `docs:`, `chore:`, `refactor:`).
- **Auteur des commits** : Cyril Benhafed, `cyril@benhafed.com`.
- **Format des fichiers** : UTF-8, LF, trim trailing whitespace, final
  newline (settings VS Code workspace).

## Commandes utiles

```bash
# Entrer dans la distrobox
distrobox enter website

# (Re-)provisionner la distrobox
distrobox enter website -- bash ~/projects/website/.devcontainer/provision.sh

# Builder le CV (depuis l'hôte)
distrobox enter website -- bash -c "cd ~/projects/website/cv && Rscript build_resume.R"

# Builder le CV (depuis l'intérieur de la distrobox / terminal VS Code)
cd ~/projects/website/cv && Rscript build_resume.R
```

## État actuel (à la création de ce document)

- ✅ Vitrine fonctionnelle (`index.html`, `contact.html`)
- ✅ CV buildé localement et committé (`cv/resume_{fr,en}.{html,pdf}`)
- ✅ Environnement de dev versionné (`distrobox.ini`, `provision.sh`)
- ✅ Settings VS Code workspace pour terminal distrobox
- ✅ Repo poussé sur GitHub (`main`)
- ⏳ GitHub Pages : configuration en cours (option "GitHub Actions"
  comme source de Pages, en attente du workflow)
- ⏳ DNS : à configurer (4 A records apex + CNAME `blog`)
- ⏳ Workflow CI/CD : à mettre en place (voir `synthese-cicd-website.md`
  pour le cadrage)
- ⏳ Branche `dev` : à créer une fois la pipeline en place

## Principes à respecter dans les évolutions

- **Authorship boundary** : Cyril rédige tous les contenus textuels.
  Claude (et Claude Code) gèrent structure, code, formatting — pas le
  fond rédactionnel.
- **Cohérence visuelle** : toute modification du design doit respecter
  la palette slate/indigo (`#1a202c`, `#667eea`, `#f7f9fc`) et la
  typographie (DM Serif Display + DM Sans). Voir README racine pour
  la palette complète.
- **Bilingue FR/EN** : tout texte ajouté à la vitrine doit avoir ses
  attributs `data-fr` et `data-en` pour fonctionner avec le switcher.
- **Réutiliser le pattern du repo `blog`** quand pertinent (workflow
  GitHub Actions, structure de branches, conventions).
- **Pas de surprise dans le dev container** : si tu ajoutes une
  dépendance système, ajoute-la dans `additional_packages` du
  `distrobox.ini` ET dans le `SYS_PKGS` du `provision.sh` (les deux,
  pour garantir idempotence et reproduction sur autres machines).
