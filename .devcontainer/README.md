# Environnement de dev — distrobox `website`

Environnement de développement reproductible pour le repo `website`,
basé sur **Ubuntu 26.04** — en parité avec le home-server et les
runners GitHub Actions.

## Pourquoi une distrobox ?

Comme `uv`/`pyenv` isolent les dépendances Python par projet, distrobox
isole l'**environnement système** (R, Chrome, Quarto, libs `-dev`)
dans un conteneur. Le même conteneur tourne à l'identique sur n'importe
quel hôte.

```
X270 (Fedora Silverblue)  ─┐
Workstation (Fedora WS)    ─┼─→  distrobox "website" (ubuntu:26.04)
Home-server (Ubuntu 26.04) ─┘     = même env partout + parité CI
```

> Distrobox n'est pas exclusif : sur la workstation, tu peux garder ton
> stack Python natif (`uv`/`pyenv`) pour le reste. La distrobox ne sert
> qu'à ce qui doit être en parité serveur/CI (build R du CV, Quarto).

## Création de l'environnement

Depuis la racine du repo, sur n'importe quelle machine :

```bash
distrobox assemble create --file .devcontainer/distrobox.ini
distrobox enter website
```

`distrobox assemble` lit `distrobox.ini`, crée le conteneur Ubuntu 26.04
et installe les paquets système. Le hook de provisioning (packages R
+ Chrome + Quarto) devrait tourner automatiquement.

> ⚠️ Selon la version de `distrobox`, le `init_hooks` peut ne pas se
> déclencher de manière fiable. Si en entrant dans le conteneur les
> packages R ou Chrome ne sont pas installés, lance-le manuellement :
>
> ```bash
> bash $HOME/projects/website/.devcontainer/provision.sh
> ```
>
> Le script est **idempotent** : tu peux le relancer sans risque.

> ⚠️ Distrobox monte automatiquement ton `$HOME` dans le conteneur, donc
> le repo est accessible à son chemin hôte naturel (par défaut
> `~/projects/website`). Si tu clones ailleurs, adapte simplement les
> commandes — pas de fichier de config à modifier.

## Ce que fait provision.sh

1. **Libs système** — vérifie et installe les `-dev` requises pour
   compiler les packages R (`libssl-dev`, `libuv1-dev`, etc.).
2. **Packages R** — installe `rmarkdown`, `pagedown`, `yaml`,
   `rstudioapi` dans la bibliothèque utilisateur (pas de sudo).
3. **Chrome + shim** — voir « Le piège Chromium / Chrome » ci-dessous.
4. **Quarto** — installe (ou met à jour) la dernière version stable
   depuis le dépôt GitHub officiel.
5. **Prompt bash distrobox** — ajoute un marqueur visuel `📦[user@website ...]`
   au `~/.bashrc` du conteneur pour distinguer instantanément un shell
   distrobox d'un shell hôte. Sans ça, le prompt par défaut affiche
   le hostname de l'hôte (préservé par distrobox), ce qui prête à
   confusion.

Chaque étape vérifie l'existant avant d'agir — relancer le script ne
réinstalle pas ce qui est déjà à jour.

## Le piège Chromium / Chrome (résolu)

Sur Ubuntu 26.04, `apt install chromium-browser` installe un wrapper
qui réclame le **snap** `chromium`, et snapd ne tourne pas en conteneur.
Plusieurs tentatives ont été essayées avant d'aboutir :

- ❌ Bloquer le snap avec un faux paquet `equivs` → `apt update` finit
  par réinstaller le wrapper officiel par-dessus.
- ❌ Pointer un shim vers `chromium` → le wrapper transitional est un
  script qui appelle `snap run chromium`, qui n'existe pas en conteneur.

✅ **Solution retenue : Google Chrome stable depuis le dépôt officiel
Google.** Vrai `.deb` signé, auto-mis-à-jour via `apt update`, même
moteur Blink que Chromium — `pagedown::chrome_print` produit le même
résultat.

`provision.sh` :

1. Supprime le wrapper snap `chromium-browser` s'il est installé
2. Ajoute le dépôt Google Chrome (clé GPG + sources.list)
3. Installe `google-chrome-stable`
4. Pose un shim `/usr/local/bin/chromium-browser` qui appelle
   `/usr/bin/google-chrome-stable` (chemin **absolu** pour éviter toute
   récursion) avec les flags requis en conteneur :
   `--no-sandbox`, `--disable-gpu`, `--disable-dev-shm-usage`

Le nom du shim reste `chromium-browser` parce que c'est ce que
`pagedown::find_chrome()` cherche dans le PATH.

## Builder le CV

Une fois dans le conteneur :

```bash
cd $HOME/projects/website
Rscript cv/build_resume.R
```

Tu devrais obtenir `cv/resume_{fr,en}.html` et `cv/resume_{fr,en}.pdf`.

## Cycle de vie

```bash
# Lister les distrobox
distrobox list

# Entrer
distrobox enter website

# Re-provisionner sans recréer (si tu modifies provision.sh)
distrobox enter website -- bash $HOME/projects/website/.devcontainer/provision.sh

# Détruire (sans toucher au repo, qui est juste monté)
distrobox rm website --force
```

## Fichiers

| Fichier          | Rôle |
|------------------|------|
| `distrobox.ini`  | Définition déclarative du conteneur |
| `provision.sh`   | Installe libs R, packages R, Chrome+shim, Quarto |
| `README.md`      | Ce fichier |
