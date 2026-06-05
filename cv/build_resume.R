# build_resume.R — Build CV (FR/EN) avec wrapper iframe
#
# Lançable depuis n'importe où :
#   Rscript cv/build_resume.R          (depuis la racine du repo)
#   cd cv && Rscript build_resume.R    (depuis cv/)
#
# Le script se replace automatiquement dans son propre dossier (cv/),
# puis produit les fichiers dans ce dossier — pour servir l'URL
# benhafed.com/cv/ une fois déployé via GitHub Pages (root).

# --- Se placer dans le dossier du script, quel que soit le cwd ---
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg) == 1) {
  # Lancé via Rscript : on connaît le chemin du script
  script_path <- sub("^--file=", "", file_arg)
  setwd(dirname(normalizePath(script_path)))
} else if (requireNamespace("rstudioapi", quietly = TRUE) &&
           rstudioapi::isAvailable()) {
  # Lancé via "Source" dans RStudio
  setwd(dirname(rstudioapi::getSourceEditorContext()$path))
}
# (sinon : on suppose que le cwd est déjà cv/)

cat("📂 Dossier de travail :", getwd(), "\n\n")

langs <- c("fr", "en")

cat("🔨 Building CV in both languages...\n\n")

# Step 1: Render HTML for each language
for (lang in langs) {
  cat(paste0("  📄 Rendering HTML (", toupper(lang), ")...\n"))

  rmarkdown::render(
    "resume.Rmd",
    output_file = paste0("resume_", lang, ".html"),
    params = list(lang = lang),
    envir = new.env(),
    quiet = TRUE
  )
}

# Step 2: Generate PDFs
cat("\n📑 Generating PDFs...\n")
for (lang in langs) {
  cat(paste0("  📄 Generating PDF (", toupper(lang), ")...\n"))

  pagedown::chrome_print(
    input = paste0("resume_", lang, ".html"),
    output = paste0("resume_", lang, ".pdf"),
    verbose = 0
  )
}

cat("\n✅ Build complete!\n")
cat("\n📂 Generated files (dans cv/) :\n")
cat("  • resume_fr.html\n")
cat("  • resume_en.html\n")
cat("  • resume_fr.pdf\n")
cat("  • resume_en.pdf\n")
cat("  ⭐ index.html (wrapper iframe — point d'entrée /cv/)\n")
cat("\n🌐 Le wrapper index.html et wrapper-styles.css sont versionnés\n")
cat("   directement (pas générés). Ils embarquent les resume_*.html.\n")
