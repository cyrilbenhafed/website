# Feuille de route — `website`

> État au moment de la création de ce document : repo poussé sur GitHub
> (`main`), GitHub Pages en cours de configuration (option GitHub Actions),
> DNS à configurer, CI/CD à mettre en place.

---

## Phase 1 — Mise en ligne minimale ⏳ (en cours)

**Objectif** : `benhafed.com` répond et sert la vitrine + CV depuis `main`.

- [ ] **GitHub Pages** : configurer la source en "GitHub Actions"
      (Settings → Pages → Source : GitHub Actions)
- [ ] **DNS** : configurer chez le registrar
  - 4 A records pour l'apex `benhafed.com` → IPs GitHub Pages
  - 1 CNAME `www` → `cyrilbenhafed.github.io` (optionnel mais recommandé)
  - 1 CNAME `blog` → `cyrilbenhafed.github.io` (pour le blog déjà déployé)
- [ ] **Custom domain** dans Settings → Pages : `benhafed.com`
- [ ] **HTTPS** : cocher "Enforce HTTPS" une fois le certificat émis
- [ ] **Test** : ouvrir `benhafed.com` et `benhafed.com/cv/` dans un
      navigateur en navigation privée

**Note** : tant que la CI/CD n'est pas en place, on basculera
temporairement la source Pages sur "Deploy from a branch" → `main` /
root, pour que le site soit accessible. Une fois la CI prête, retour
sur "GitHub Actions".

## Phase 2 — Pipeline CI/CD 🎯 (prochaine session dédiée)

**Objectif** : automatiser le build du CV et la séparation
preprod/prod, sur le pattern du repo `blog`.

**Document de cadrage** : `synthese-cicd-website.md` (toutes les
décisions déjà prises et questions à clarifier en début de session).

Points clés :
- Stratégie `dev → preprod, main → prod` calquée sur `blog`
- Hébergement : branches `gh-pages` distinctes
- Build du CV uniquement (vitrine reste statique)
- Question ouverte : transposer `provision.sh` dans le workflow YAML,
  ou passer par un conteneur Docker (recommandation initiale : YAML
  direct, migrer vers Docker si besoin)

## Phase 3 — Refonte visuelle (autre session dédiée)

**Objectif** : itérer sur le design de la vitrine quand le contenu
sera plus stable et la CI en place pour pouvoir tester en preprod.

Pas urgent. La vitrine actuelle est fonctionnelle et cohérente avec
le CV et le blog. Évolutions possibles :
- Adaptation aux retours visuels au fil de l'usage
- Ajout d'illustrations / éléments graphiques
- Affinage des micro-interactions

## Phase 4 — Ajouts fonctionnels (au fil de l'eau)

**À mesurer/prioriser quand les phases 1-2 seront terminées :**

- Section "Ressources pédagogiques" (placeholder dans la nav, à
  remplir progressivement)
- Section "Projets" (showcase de réalisations)
- Page CV en alternative HTML responsive (au-delà du PDF actuel)
- Optimisation SEO (meta tags, sitemap, robots.txt, Open Graph)
- Analytics légers (Plausible / Umami self-hosted ? — à débattre)
- Liens RSS depuis vitrine vers blog

## Phase 5 — Maintenance & itération

- Mise à jour du CV (nouvelle certification, nouveau poste, etc.)
  → modifier `cv/cv_content.yaml`, push → CI rebuild + déploie
- Mises à jour de l'environnement de dev (nouvelle version R, Quarto,
  etc.) → ajuster `provision.sh`, tester en local, push
- Mise à jour du contenu vitrine → modifier les fichiers HTML, push

---

## Décisions ouvertes à trancher en cours de route

1. **Versionnement des sorties du CV** (`cv/resume_*.html/pdf`) :
   continuer à les commiter ? Ou les retirer et forcer le passage par
   CI ? Décision à prendre en début de Phase 2.

2. **Ajout d'une langue supplémentaire** au-delà de FR/EN ? Aucun
   besoin identifié, mais le code y est préparé via les attributs
   `data-XX`.

3. **Comments / interaction sur le blog** (giscus déjà envisagé,
   différé) : à reconsidérer après quelques mois de blog en ligne.
   Hors scope `website` mais affecte la cohérence d'écosystème.

4. **Analytics** : si oui, quel outil ? Privacy-friendly impératif
   (Plausible self-hosted sur home-server ? Cloudflare Analytics ?
   Umami ?). À débattre.

---

## Références

- **CLAUDE.md** : contexte complet pour Claude Code (à placer à la
  racine du repo)
- **synthese-cicd-website.md** : cadrage de la session CI/CD
- **README.md** (racine du repo) : structure, setup distrobox,
  build CV, déploiement
- **.devcontainer/README.md** : détails de l'environnement de dev
  (piège Chromium, choix Chrome stable, etc.)
- **Repo `blog`** : référence pour les workflows GitHub Actions et la
  stratégie de branches preprod/prod
