# Historie von Simon zu Trient - Static digital edition

This repository contains the data, transformation scripts, and the static web edition for the edition "Historie von Simon zu Trient". The project demonstrates a simple and sustainable pipeline for publishing a scholarly edition as a static website without any backend, using data scholars commonly already have (Transkribus document, Zotero library, docx), XSLT and a local XML processor.

Currently, the repository is in beta stage.

## Goals

- Provide an easily reproducible, static publication pipeline for a TEI-based edition.
- Prioritise publishing reliable data quickly.
- Keep everything self-contained so the project can be run locally and archived using GitHub and Zenodo.

## This repository

In this repository you will find:

- `data/`: XML exports (TEI exports from Transkribus, Zotero TEI export, etc.)
- `Historie_von_Simon_zu_Trient/`: Images, METS and page XML for exemplar used in this edition
	- `Historie_von_Simon_zu_Trient/metadata.xml` and `mets.xml`
	- `page/00001.xml` ... `page/00028.xml`
- `xslt/`: XSLT transforms used to turn TEI and other XML sources into the static HTML pages
	- `transform_edition.xslt`: transforms the TEI edition into the static HTML edition
	- `transform_introduction.xslt`: transforms the introduction TEI into an HTML page
	- `transform_literature.xslt`: transforms the Zotero TEI bibliography into an HTML bibliography
- `Saxon/`: the used XML processor files used to run the XSLT (Saxon distribution, libraries, and notices)
- `html/`: the generated static website (edition pages, introduction, literature) and site assets
	- `html/edition.html`, `html/introduction.html`, `html/literature.html`
- `index.html`: landing page

## Provenance and data

- The edition text was transcribed in Transkribus and exported as TEI. Those TEI files were processed and enriched to conform with TEI conventions and scholarily practice.
- The introduction was drafted in Microsoft Word and converted to TEI using OxGarage.
- The bibliography was created with Zotero and exported as TEI.
- Page images and page-XML are included where available. Images are Public Domain (see the notices and the BSB source reference). Some remote services (e.g., IIIF viewer instances hosted by BSB München) are not included in the package and are referenced externally.

## View the edition locally

1. Clone the repository or download the archive.
2. From the repository root, start a simple HTTP server and open the site in your browser.

PowerShell (Windows):

```powershell
Start-Process python -ArgumentList '-m','http.server','8000'; Start-Sleep -Seconds 1; Start-Process 'http://localhost:8000/'
```

macOS / Linux (bash / zsh):

```bash
python3 -m http.server 8000 & sleep 1 && python3 -c "import webbrowser; webbrowser.open('http://localhost:8000/')"
```

After the server starts, open `http://localhost:8000/` (or your browser should open automatically). The static edition pages are in the `html/` directory — for example `html/edition.html`.

## Regenerating the static site (XSLT + Saxon)

The site can be built locally. Transforms are run with Saxon against XML files in `data/`.

Input/output overview:

- `data/Historie_von_Simon_zu_Trient_Edition.xml` + `xslt/transform_edition.xslt` -> `html/edition.html` and `index.html`
- `data/Historie_von_Simon_zu_Trient_Einleitung.xml` + `xslt/transform_introduction.xslt` -> `html/introduction.html`
- `data/Historie_von_Simon_zu_Trient_Zotero.xml` + `xslt/transform_literature.xslt` -> `html/literature.html`

```bash
mkdir -p ./build

# Edition + root index
java -jar ./Saxon/saxon-he-12.9.jar \
  -s:data/Historie_von_Simon_zu_Trient_Edition.xml \
  -xsl:xslt/transform_edition.xslt outdir=./html/

# Introduction
java -jar ./Saxon/saxon-he-12.9.jar \
  -s:data/Historie_von_Simon_zu_Trient_Einleitung.xml \
  -xsl:xslt/transform_introduction.xslt \
  -o:html/introduction.html

# Literature
java -jar ./Saxon/saxon-he-12.9.jar \
  -s:data/Historie_von_Simon_zu_Trient_Zotero.xml \
  -xsl:xslt/transform_literature.xslt \
  -o:html/literature.html
```

If you use another Saxon installation, replace the jar path accordingly.

## Hosting and preservation

- The live edition is hosted using GitHub Pages. The repository is mirrored on Zenodo for long-term preservation.

## Licensing and attribution

- Images in this repository are Public Domain.
- Third-party components (Saxon, other libraries) include their own licenses and notices (see `Saxon/notices/`).

If you re-use images or other resources, please check the relevant metadata files and notices included in the repository for full attribution details.

## Limitations and external services

- The edition relies on some external services for advanced viewers (for example a IIIF/Manifold viewer hosted by external providers). These services are not distributed in this repo. Page images and page XML are provided where possible for longterm accessability.


---
