# Feuille de route — `website`

> Mis à jour le 2026-06-17. État : site en ligne sur `benhafed.com`,
> pipeline CI/CD opérationnelle. Prochaine étape : Phase 3 (thème sombre/clair).

---

## Phase 1 — Mise en ligne minimale ✅ (terminée)

**Objectif** : `benhafed.com` répond et sert la vitrine + CV depuis `main`.

- ✅ GitHub Pages configuré (source "GitHub Actions")
- ✅ Environments `production` et `preprod` créés dans Settings → Environments
- ✅ DNS configuré chez le registrar (4 A records apex + CNAMEs `www` et `blog`)
- ✅ Custom domain `benhafed.com` dans Settings → Pages
- ✅ HTTPS enforced
- ✅ Site accessible sur `benhafed.com` et `benhafed.com/cv/`

## Phase 2 — Pipeline CI/CD ✅ (terminée)

**Objectif** : automatiser le build du CV et la séparation preprod/prod.

Ce qui a été mis en place (`.github/workflows/deploy.yml`) :
- `main` → build CV (R + pagedown + Chrome) → déploie sur GitHub Pages
  (source "GitHub Actions") → `benhafed.com`
- `dev` → build CV → pousse sur la branche `gh-pages-dev` (inspection)
- Cache des packages R (invalidé si `build_resume.R` change)
- Chrome installé depuis le dépôt officiel Google, avec shim `--no-sandbox`
  (même stratégie que `provision.sh`)

**Décisions tranchées en cours de session :**
- Workflow YAML direct (pas Docker) — à migrer si les dépendances
  système deviennent trop lourdes
- Sorties du CV (`cv/resume_*.html/pdf`) toujours versionnées dans le
  repo (décision 1 des questions ouvertes : statu quo)
- Branche `dev` à créer manuellement après validation du premier run prod
  (`git checkout -b dev && git push -u origin dev`)

## Phase 3 — Refonte visuelle (session dédiée)

**Objectif** : itérer sur le design quand le contenu sera stable et la
Phase 1 terminée.

- **Thème sombre / clair basé sur le système** (`prefers-color-scheme`) :
  adaptation automatique à la préférence OS/navigateur. Priorité haute
  dans cette phase — fonctionnalité attendue sur tout site en 2026.
- **Photo dans le hero** : intégrer une photo dès la section d'accroche
  (nom + rôle + CTA), visible immédiatement à l'arrivée sur le site.
- **Transition UI vitrine → CV** : améliorer le passage visuel entre les
  deux surfaces (navigation, continuité graphique, retour arrière).
- **Favicon + Open Graph** : favicon multi-résolution (`.ico` + `apple-touch-icon`
  + `svg`) et balises `og:image`, `og:title`, `og:description` pour un
  partage correct sur les réseaux. À coordonner avec le choix de la photo
  (l'`og:image` peut réutiliser la même).
- Adaptation aux retours visuels au fil de l'usage
- Affinage des micro-interactions

## Phase 4 — Ajouts fonctionnels (au fil de l'eau)

**À prioriser une fois les phases 1-3 terminées :**

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
- Mises à jour de l'environnement de dev (nouvelle version R, etc.)
  → ajuster `provision.sh`, tester en local, push
- Mise à jour du contenu vitrine → modifier les fichiers HTML, push

---

## Décisions ouvertes à trancher en cours de route

1. ~~**Versionnement des sorties du CV**~~ — **Tranché** : sorties
   versionnées dans le repo (statu quo). La CI les reconstruit à chaque
   push de toute façon.

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

- **CLAUDE.md** : contexte complet pour Claude Code (racine du repo)
- **README.md** (racine du repo) : structure, setup distrobox,
  build CV, déploiement
- **.devcontainer/README.md** : détails de l'environnement de dev
  (piège Chromium, choix Chrome stable, etc.)
- **Repo `blog`** : référence pour les conventions et la
  stratégie de branches
