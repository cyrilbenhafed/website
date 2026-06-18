.PHONY: cv serve help

# Build CV (FR + EN, HTML + PDF) inside the distrobox
cv:
	distrobox enter website -- bash -c "Rscript $(CURDIR)/cv/build_resume.R"

# Serve the full site locally on :8080 (vitrine + CV)
serve:
	@echo "  http://localhost:8080"
	@echo "  http://localhost:8080/cv/"
	python3 -m http.server 8080

help:
	@echo "make cv     build CV (FR + EN) via distrobox"
	@echo "make serve  serve site locally on :8080"
