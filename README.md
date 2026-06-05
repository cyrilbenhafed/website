# website — benhafed.com

Site personnel de Cyril Benhafed : vitrine + CV.
Déployé sur GitHub Pages, domaine `benhafed.com`.

> Le **blog** est hébergé séparément (repo `blog`, Quarto) sur
> `blog.benhafed.com`. Rythme de release et pipeline distincts.

## Écosystème

```
cyrilbenhafed/
├── blog        → blog.benhafed.com   (Quarto)
└── website     → benhafed.com        (ce repo : vitrine + CV)
```

## Structure du repo

```
website/
├── index.html          # Vitrine — Accueil + About
├── contact.html        # Vitrine — Contact
├── styles.css          # Styles vitrine
├── main.js             # JS vitrine (thème, langue, nav)
├── CNAME               # benhafed.com
├── .gitignore          # fusion vitrine + R
├── README.md
├── .vscode/
│   └── settings.json   # Terminal VS Code → distrobox `website`
├── .devcontainer/
│   ├── distrobox.ini   # Définition de l'env de dev (ubuntu:26.04)
│   ├── provision.sh    # Provisioning : libs R, Chrome, Quarto
│   └── README.md
└── cv/                 # Sous-projet CV (build R indépendant)
    ├── resume.Rmd          # source
    ├── cv_content.yaml     # contenu FR/EN
    ├── specifics.css       # styles pagedown
    ├── build_resume.R      # script de build
    ├── wrapper-styles.css  # nav partagée + iframe (versionné)
    ├── index.html          # wrapper iframe (versionné, point d'entrée /cv/)
    ├── resume_fr.html      # généré — À COMMITTER
    ├── resume_en.html      # généré — À COMMITTER
    ├── resume_fr.pdf       # généré — À COMMITTER
    └── resume_en.pdf       # généré — À COMMITTER
```

## Fil rouge visuel (vitrine · CV · blog)

Les trois surfaces partagent une **barre de navigation au même concept** :

- Fond nav toujours **dark** (`#1a202c`)
- Accent commun **`#667eea`**
- Nom « Cyril Benhafed » comme ancre, lien retour systématique
- Liens contextuels propres à chaque surface (Accueil/Blog/Contact ·
  Accueil/Blog/CV+PDF · Articles/Projets/… sur le blog)

La vitrine a un mode light/dark ; la nav reste dark dans les deux cas.

## Build & déploiement

### Vitrine (statique)
Aucun build. Éditer les `.html` / `.css` / `.js` directement.

### CV (R / pagedown)
```bash
cd cv
Rscript build_resume.R     # ou source("build_resume.R") dans RStudio
```
Produit `resume_{fr,en}.{html,pdf}` **dans `cv/`**. Ces sorties sont
versionnées (Pages les sert tel quel). Le wrapper `cv/index.html` et
`cv/wrapper-styles.css` ne sont pas générés — ils sont édités à la main.

URL finale du CV : `benhafed.com/cv/`

## Palette & typographie

| Variable     | Light       | Dark        |
|--------------|-------------|-------------|
| `--bg`       | `#f7f9fc`   | `#1a202c`   |
| `--accent`   | `#667eea`   | `#667eea`   |
| `--text`     | `#1a202c`   | `#f7fafc`   |
| Nav (fixe)   | `#1a202c`   | `#1a202c`   |

- **Display** : DM Serif Display · **Body** : DM Sans
