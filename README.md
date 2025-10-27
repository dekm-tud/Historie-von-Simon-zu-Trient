# Historie von Simon zu Trient — Static digital edition

This repository contains the data, transformation scripts, and the static web edition for the edition "Historie von Simon zu Trient". The project demonstrates a simple, sustainable pipeline for publishing a scholarly edition as a static website without a backend, using files scholars commonly already have (TEI XML, Zotero exports, Word→TEI conversions, XSLT and a local XML processor).

## Goals

- Provide an easily reproducible, static publication pipeline for a TEI-based edition.
- Prioritise getting reliable, well-formed data online quickly rather than full feature parity with research-grade digital editions.
- Keep everything self-contained so the project can be run locally and archived (GitHub + Zenodo).

## What's included

Top-level items you will find in the repository:

- `data/` — assorted project-level XML exports (TEI exports from Transkribus, Zotero TEI export, etc.)
- `Historie_von_Simon_zu_Trient/` — the primary TEI package containing metadata, METS and page XML for the edition
	- `Historie_von_Simon_zu_Trient/metadata.xml` and `mets.xml`
	- `page/00001.xml` ... `page/00028.xml` — page XML files (pageimages/page-xml)
- `xslt/` — XSLT transforms used to turn TEI and other XML sources into the static HTML pages
	- `transform_edition.xslt` — transforms the TEI edition into the public-facing HTML edition
	- `transform_introduction.xslt` — transforms the introduction TEI into an HTML page
	- `transform_literature.xslt` — transforms the Zotero TEI bibliography into an HTML bibliography
- `Saxon/` — the included XML processor files used to run the XSLT (Saxon distribution, libraries, and notices)
- `html/` — the generated static website (edition pages, introduction, literature) and site assets
	- `html/edition.html`, `html/introduction.html`, `html/literature.html`
- `doc/` — documentation and styling (a small docs site and stylesheets used for preview)
- `index.html` — repository/home landing page

## Provenance and data

- The edition text was transcribed in Transkribus and exported as TEI. Those TEI files were processed and enriched to conform with TEI conventions used here.
- The introduction was drafted in Microsoft Word and converted to TEI using OxGarage.
- The bibliography was created with Zotero and exported as TEI.
- Page images and page-XML are included where available. Images are Public Domain (see the notices and the BSB source reference). Some remote services (e.g., IIIF viewer instances hosted by BSB München) are not included in the package and are referenced externally.

## Quick start — view the edition locally

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

This repository includes the XSLT transforms in `xslt/` and a Saxon distribution in `Saxon/`. To regenerate the HTML pages from the TEI sources you can run the Saxon processor. The exact Saxon jar name may vary; adjust the path/filename as necessary.

Example command (PowerShell):

```powershell
# replace saxon-he.jar with the actual jar filename in Saxon\lib
java -jar .\Saxon\lib\saxon-he.jar -s:Historie_von_Simon_zu_Trient\Historie_von_Simon_zu_Trient\metadata.xml -xsl:xslt\transform_edition.xslt -o:html\edition.html
java -jar .\Saxon\lib\saxon-he.jar -s:data\Historie_von_Simon_zu_Trien_Einleitung.xml -xsl:xslt\transform_introduction.xslt -o:html\introduction.html
java -jar .\Saxon\lib\saxon-he.jar -s:data\Historie_von_Simon_zu_Trient_Zotero.xml -xsl:xslt\transform_literature.xslt -o:html\literature.html
```

Example command (macOS / Linux):

```bash
# replace saxon-he.jar with the actual jar filename in Saxon/lib
java -jar ./Saxon/lib/saxon-he.jar -s:Historie_von_Simon_zu_Trient/Historie_von_Simon_zu_Trient/metadata.xml -xsl:xslt/transform_edition.xslt -o:html/edition.html
```

Notes:
- The `-s:` source argument should point to the TEI (or other XML) input for the transform. For the edition we use the `metadata.xml` inside the package as the entry point.
- The `-xsl:` option selects the transform file from `xslt/`.
- The `-o:` option writes the output HTML to `html/` (overwrite as-needed).
- If you have an alternative Saxon installation (on PATH) you can use that instead of the included Saxon distribution.

## Hosting and preservation

- The live edition is hosted using GitHub Pages. The repository is mirrored on Zenodo for long-term preservation (check the project page for DOI and mirror links).

## Licensing and attribution

- Images in this repository are Public Domain (see notices in `Saxon/notices` and any per-image metadata).
- Third-party components (Saxon, other libraries) include their own licenses and notices (see `Saxon/notices/`).

If you re-use images or other resources, please check the relevant metadata files and notices included in the repository for full attribution details.

## Limitations and external services

- The edition relies on some external services for advanced viewers (for example a IIIF/Manifold viewer hosted by external providers). These services are not distributed in this repo; page images and page XML are provided where possible.

## Troubleshooting

- If the Saxon jar name or location differs from the example commands, list the contents of `Saxon\lib` and substitute the actual filename.
- If pages look broken after transformation, validate the source TEI for well-formedness and check the XSLT stderr output for errors.

## Development & contributions

- Contributions that improve processing, fix TEI issues, or add documentation are welcome. Please open issues or pull requests on the GitHub repository.
- If you want to extend the pipeline (e.g., add a Makefile/PowerShell script to automate transforms and server start), consider adding a small script in the project root and documenting its usage here.

## Files of interest

- `xslt/transform_edition.xslt` — main transform for the edition HTML
- `xslt/transform_introduction.xslt` — introduction transform
- `xslt/transform_literature.xslt` — bibliography transform
- `Historie_von_Simon_zu_Trient/` — TEI package with metadata, mets, page XML
- `html/` — generated site (open `html/edition.html`)

## Contact

For questions about the repository or to report issues, please use the GitHub repository issues. The source files contain provenance and metadata for specific editorial contacts where available.

---

This README was generated from the project notes and repository contents. If you'd like, I can add a short PowerShell or Makefile script to automate the full transform + server workflow next.
