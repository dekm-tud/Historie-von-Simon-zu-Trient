<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="tei xs">

    
    <xsl:param name="site_title"
               select="'Historie von Simon zu Trient – Digital Edition'" />
    <xsl:param name="iiif_manifest"
               select="'https://api.digitale-sammlungen.de/iiif/presentation/v2/bsb00027835/manifest'" />
    <xsl:param name="outdir"
               select="'html'" />
    <xsl:output method="html"
                encoding="UTF-8"
                omit-xml-declaration="yes" />
    
    
    <xsl:key name="char-by-id"
             match="tei:char"
             use="@xml:id" />
    <xsl:key name="glyph-by-id"
             match="tei:glyph"
             use="@xml:id" />
    
    
    <xsl:template match="/tei:TEI">

        <!-- edition.html -->
        <xsl:result-document href="{concat($outdir, '/edition.html')}"
                             method="html"
                             encoding="UTF-8"
                             omit-xml-declaration="yes">
            <xsl:call-template name="page-shell">
                <xsl:with-param name="title"
                                select="concat($site_title, ' — Digitale Edition')" />
                <xsl:with-param name="css-href"
                                select="'assets/site.css'" />
                <xsl:with-param name="js-href"
                                select="'assets/site.js'" />
                <xsl:with-param name="atRoot"
                                select="false()" />
                <xsl:with-param name="head-extra">
                    <link rel="stylesheet"
                          href="https://unpkg.com/mirador@3.3.0/dist/mirador.min.css" />
                    <script src="https://unpkg.com/mirador@3.3.0/dist/mirador.min.js" />

                    <style>                        
                        .choice.corr-sic .corr { display: none; }
                        .choice.corr-sic .sic  { display: inline; }
                        .norm-on .choice.corr-sic .corr { display: inline; }
                        .norm-on .choice.corr-sic .sic  { display: none; }
                    </style>
                </xsl:with-param>
                <xsl:with-param name="content">
                    <main class="container">
                        <section id="edition">
                            <div class="edition-grid">
                                <div id="outer-left"
                                     class="outer-handle"
                                     role="separator"
                                     aria-orientation="vertical"
                                     aria-label="Panelbreite nach links anpassen"
                                     tabindex="0" />
                                <article class="panel text"
                                         id="text-panel">
                                    <div class="head">
                                        <div class="controls">
                                            <!-- Expansion (toggle) -->
                                            <div class="group"
                                                 role="group"
                                                 aria-label="Expansion toggle">
                                                <label class="visually-hidden"
                                                       for="btn-expansion">Abbreviationen</label>
                                                <button id="btn-expansion"
                                                        type="button"
                                                        aria-pressed="true"
                                                        title="Zwischen Expansion und Abkürzungen umschalten">Abbreviationen</button>
                                            </div>
                                            <!-- Lesefassung (toggle) -->
                                            <div class="group"
                                                 role="group"
                                                 aria-label="Reading layout toggle">
                                                <label class="visually-hidden"
                                                       for="btn-reading">Zeilenumbruch</label>
                                                <button id="btn-reading"
                                                        type="button"
                                                        aria-pressed="true"
                                                        title="Zwischen Lesefassung und Originalfassung umschalten">Zeilenumbruch</button>
                                            </div>
                                            <!-- Normalisierung (toggle) -->
                                            <div class="group"
                                                 role="group"
                                                 aria-label="Glyph normalization toggle">
                                                <label class="visually-hidden"
                                                       for="btn-normalize">Normalisierung</label>
                                                <button id="btn-normalize"
                                                        type="button"
                                                        aria-pressed="false"
                                                        title="Sonderzeichen normalisieren (z. B. langes s → s)">Normalisierung</button>
                                            </div>
                                            <!-- Auto sync (toggle) -->
                                            <div class="group"
                                                 role="group"
                                                 aria-label="Viewer auto scroll sync">
                                                <label class="visually-hidden"
                                                       for="btn-sync">Automatischer Bildlauf</label>
                                                <button id="btn-sync"
                                                        type="button"
                                                        aria-pressed="true"
                                                        title="Viewer beim Scrollen automatisch mit dem Text synchronisieren (an/aus)">Automatischer Bildlauf</button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="body"
                                         id="text-body">
                                        <xsl:apply-templates select="tei:text" />
                                    </div>
                                </article>
                                <aside class="panel edition-viewer">
                                    <div class="head">
                                        <div>Facsimiles (Mirador 3)</div>
                                        <div style="font-size:.9rem;color:var(--muted)">IIIF Manifest</div>
                                    </div>
                                    <div class="body viewer-wrap">
                                        <div id="mirador"
                                             data-manifest="{$iiif_manifest}" />
                                    </div>
                                </aside>
                                <div id="outer-right"
                                     class="outer-handle"
                                     role="separator"
                                     aria-orientation="vertical"
                                     aria-label="Panelbreite nach rechts anpassen"
                                     tabindex="0" />
                            </div>
                        </section>
                    </main>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:result-document>

        <!-- index.html -->
        <xsl:call-template name="page-shell">
            <xsl:with-param name="title"
                            select="$site_title" />
            <xsl:with-param name="css-href"
                            select="concat($outdir, '/assets/site.css')" />
            <xsl:with-param name="js-href"
                            select="concat($outdir, '/assets/site.js')" />
            <xsl:with-param name="atRoot"
                            select="true()" />
            <xsl:with-param name="content">
                <main class="container">
                    <section id="home">
  <h1>Historie von Simon zu Trient – Digitale Edition</h1>

  <section class="text-und-bild">
    <div class="text">
      <p>Die <em>Historie von Simon zu Trient</em> ist eine judenfeindliche Verschwörungserzählung aus dem Jahre 1475 und sollte vielleicht besser <em>Historie von der Ermordung der Trienter Juden</em> genannt werden. Der Text wurde 6. September 1475 von Albrecht Kunne in Trient gedruckt und erzählt von der angeblichen Entführung, Folterung und Tötung des zweijährigen Simon durch die Männer der jüdischen Gemeinde in Trient, deren Verhaftung, Folterung und Ermordung sowie dem Totenkult um Simon.</p>
      <p>Die hier vorgelegte Edition ist Teil eines Forschungsprojekts von Marco Heiles, das die <em>Historie von Simon zu Trient</em> durch eine Digitale Edition und eine begleitende Artikelserie im Blog <em>
        <a href="https://mittelalter.hypotheses.org/">Das Mittelalter. Interdisziplinäre Forschung und Rezeptionsgeschichte</a>
      </em> für die Forschung und vor allem die akademische Lehre zugänglich machen möchte.</p>
      <p>Anlass für diese Auseinandersetzung mit dem Text war dabei ein germanistisches Master-Hauptseminar zu <em>Verschwörungserzählungen im Spätmittelalter und heute</em>, das Marco Heiles im Wintersemester 2022/2023 an der RWTH Aachen University durchgeführt hat. In diesem wurden – ausgehend von den eigenen aktuellen Erfahrungen mit Verschwörungserzählungen während der Coronapandemie – eine ganze Reihe spätmittelalterlicher Texte auf strukturelle Gemeinsamkeiten mit und motivische Kontinuitäten zu heutigen Verschwörungserzählungen untersucht. Da mehrere Studierende Hausarbeiten zur 'Historie von Simon zu Trient' schreiben wollten und eine zitierfähige und leicht lesbare Ausgabe des Textes fehlt, hat Marco Heiles mithilfe von 'Transkribus' eine Transkription des Druckes erstellt. Dank der technischen Unterstützung von Michael Schonhardt und dem Fachgebiet Digitale Editorik und Kulturgeschichte des Mittelalters der Technischen Universität Darmstadt kann diese Transkription jetzt hier als Digitale Edition erscheinen.</p>
  <p>Publikationen im Projekt <em>Historie von der Ermordung der Trienter Juden</em>:</p>
  <ul>
    <li>Historie von Simon zu Trient. Digitale Edition, hg. von Marco Heiles und Michael Schonhardt, Darmstadt 2025, URL: ##github</li>
    <li>Historie von Simon zu Trient. Dataset zur digitalen Edition, hg. von Marco Heiles und Michael Schonhardt, Darmstadt 2025, DOI:  ##zenodo</li>
    <li>Marco Heiles, Die Historie von Simon zu Trient – eine judenfeindliche Verschwörungserzählung aus dem Jahre 1475, in: Mittelalter. Interdisziplinäre Forschung und Rezeptionsgeschichte 8 (2025), S. xx–yy, DOI: : #xyz.</li>
    <li>Kevin Reinardy, Kein Märtyrer ohne Ritualmord. Die Historie von Simon zu Trient als Verschwörungstheorie?, in: Mittelalter. Interdisziplinäre Forschung und Rezeptionsgeschichte 8 (2025), S. xx–yy, DOI: #xyz.</li>
    <li>Hannah Heinrichs, Zwischen Märtyrerkult und antijüdischen Feindbildern. Eine Untersuchung des Ritualmordkonstruks in Text und Bild der Historie von Simon zu Trient, in: Mittelalter. Interdisziplinäre Forschung und Rezeptionsgeschichte 8 (2025), S. xx–yy, DOI: #xyz.</li>
    <li>Tobias Esser, Judenfeindliche Ikonographie – Verwendung und Umkehr christlicher Abendmahlmotivik in Text und Bild der Historie von Simon zu Trient, in: Mittelalter. Interdisziplinäre Forschung und Rezeptionsgeschichte 8 (2025), S. xx–yy, DOI: #xyz.</li>
  </ul>
    </div>

    <figure class="abb">
      <img src="html/assets/img/HAB_5_xylogr_2_00118.png"
           alt="Historie von Simon zu Trient, Trient 06.09.1475: Albrecht Kunne. Exemplar: HAB, 5 Xylogr. (2)"
           loading="lazy"/>
      <figcaption><em>Historie von Simon zu Trient, Trient 06.09.1475: Albrecht Kunne. Exemplar: Wolfenbüttel,
        Herzog August Bibliothek, 5 Xylogr. (2)</em></figcaption>
    </figure>
  </section>

 
</section>

                </main>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>



    <xsl:template name="page-shell">
        <xsl:param name="title" />
        <xsl:param name="css-href" />
        <xsl:param name="js-href" />
        <xsl:param name="content"
                   as="node()*" />
        <xsl:param name="head-extra"
                   as="node()*" />
        <xsl:param name="atRoot"
                   as="xs:boolean"
                   select="false()" />
        <html lang="de"
              data-manifest="{$iiif_manifest}">
            <head>
                <meta charset="utf-8" />
                <meta name="viewport"
                      content="width=device-width, initial-scale=1" />
                <title>
                    <xsl:value-of select="$title" />
                </title>
                <link rel="stylesheet"
                      href="{$css-href}" />
                <xsl:copy-of select="$head-extra" />
            </head>

            <body class="mode-expan layout-reading">
                <header class="site-header">
                    <nav class="nav">
                        <div class="brand">
                            <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main'])" />
                        </div>
                        <div class="menu">
                            <xsl:choose>
                                <xsl:when test="$atRoot">
                                    <a href="index.html">Home</a>
                                    <a href="html/introduction.html">Einleitung</a>
                                    <a href="html/edition.html">Edition</a>
                                    <a href="html/literature.html">Literatur</a>
                                    <a href="https://github.com/michaelscho/Historie-von-Simon-zu-Trient">GitHub</a>

                                </xsl:when>
                                <xsl:otherwise>
                                    <a href="../index.html">Home</a>
                                    <a href="introduction.html">Einleitung</a>
                                    <a href="edition.html">Edition</a>
                                    <a href="literature.html">Literatur</a>
                                    <a href="https://github.com/michaelscho/Historie-von-Simon-zu-Trient">GitHub</a>

                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </nav>
                </header>
                <xsl:copy-of select="$content" />
                <footer>
                    <h2>Impressum</h2>
                    <h3>Angaben gemäß § 5 TMG</h3>
                    <p>                        
                        Herausgeber:
                        Dr. phil. Marco Heiles
                        Ulrich Haberland Straße 43
                        53121 Bonn
                        Deutschland
                        marco.heiles @ uni-hamburg.de


                    </p>
                    <h3>Lizenzbestimmungen</h3>
                    <p>Die Texte dieser Website stehen unter Creative Commons Attribution 4.0 International Lizenz. Sie dürfen die Texte unter Angabe des Urhebers und der CC-Lizenz sowohl kopieren als auch an anderer Stelle veröffentlichen.</p>
                    <h3>Förderung</h3>
                    <p>Die Forschung von <a href="https://hcommons.org/members/marcoheiles/">Dr. Marco Heiles</a> zur Edition der Historie von Simon zu Trient fand im <a href="https://www.germlit.rwth-aachen.de/cms/germlit/Das-Institut/~mpma/Aeltere-deutsche-Literatur/">Institut für Germanistische und Allgemeine Literaturwissenschaft der RWTH Aachen University</a> und am <a href="https://www.csmc.uni-hamburg.de">Centre for the Study of Manuscript Cultures (CSMC) der Universität Hamburg</a> statt. Sie wurde durch die Deutsche Forschungsgemeinschaft (DFG) im Rahmen der Exzellenzstrategie des Bundes und der Länder – EXC 2176 „Understanding Written Artefacts: Material, Interaction and Transmission in Manuscript Cultures”, Projektnr. 390893796 gefördert.</p>
                    <p>Die Einrichtung und Veröffentlichung der Digitalen Edition und der Sicherung der Forschungsdaten erfolgte durch <a href="https://orcid.org/0000-0002-2750-1900">Prof. Dr. Michael Schonhardt</a> im Fachgebiet <a href="https://www.linglit.tu-darmstadt.de/institutlinglit/fachgebiete/digitale_editorik_und_kulturgeschichte_des_mittelalters/index.de.jsp">Digitale Editorik und Kulturgeschichte des Mittelalters</a> der Technischen Universität Darmstadt.</p>
                </footer>
                <script src="{$js-href}" />
            </body>
        </html>
    </xsl:template>



    
    <xsl:template match="tei:text">
        <xsl:apply-templates select="tei:body" />
    </xsl:template>
    <xsl:template match="tei:body">
        <div>
            <xsl:apply-templates />
        </div>
    </xsl:template>
    
    <!-- Page breaks -->
    <xsl:template match="tei:pb">
        <div class="pb"
             role="button"
             tabindex="0"
             aria-controls="mirador"
             aria-label="{concat('Seite ', @n, ' im Viewer anzeigen')}"
             data-n="{@n}">
            <xsl:attribute name="data-canvas-index">
                <xsl:value-of select="count(preceding::tei:pb)" />
            </xsl:attribute>
            <span class="tag">Folio <xsl:value-of select="@n" />
        </span>
    </div>
</xsl:template>

<!-- Line breaks -->
<xsl:template match="tei:lb">
    <span class="lb">
        <span class="orig">
            <xsl:if test="@break='no'">
                <span class="hyphen"
                      aria-hidden="true">-</span>
            </xsl:if>
            <br class="lb-br" />
        </span>
        <span class="reading">
            <xsl:choose>
                <xsl:when test="@break='no'" />
                <xsl:otherwise>
                    <xsl:text />
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </span>
</xsl:template>

<!-- Divs / paragraphs -->
<xsl:template match="tei:div">
    <section class="{if (@type = 'illustration') then 'illustration' else ()}">
        <xsl:apply-templates />
    </section>
</xsl:template>
<xsl:template match="tei:p">
    <p>
        <xsl:apply-templates />
    </p>
</xsl:template>

<!-- abbr/expan -->
<xsl:template match="tei:choice[tei:abbr and tei:expan]">
    <span class="choice"
          title="Abbrev./expansion toggle">
        <span class="abbr">
            <xsl:apply-templates select="tei:abbr/node()" />
        </span>
        <span class="expan">
            <xsl:apply-templates select="tei:expan/node()" />
        </span>
    </span>
</xsl:template>

<!-- sic/corr -->
<xsl:template match="tei:choice[tei:sic and tei:corr]">
    <span class="choice corr-sic"
          title="Fehler/Korrektur">
        <span class="sic">
            <xsl:apply-templates select="tei:sic/node()" />
        </span>
        <span class="corr">
            <xsl:apply-templates select="tei:corr/node()" />
        </span>
    </span>
</xsl:template>

<!-- g -->
<xsl:template match="tei:g">
    <xsl:variable name="id"
                  select="replace(normalize-space(@ref), '^#', '')" />
    <xsl:variable name="char"
                  select="key('glyph-by-id', $id)[1]" />
    <xsl:variable name="norm"
                  select="string(( $char/tei:mapping[@type='normalized'], $char/tei:mapping[@type='standard'] )[1])" />
    <span class="glyph"
          data-ref="{$id}">
        <xsl:if test="normalize-space($norm) != ''">
            <xsl:attribute name="data-norm">
                <xsl:value-of select="$norm" />
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates />
    </span>
</xsl:template>

<!-- Wikidata link -->
<xsl:template name="maybe-ref-link">
    <xsl:variable name="href"
                  as="xs:string?"
                  select="if (@ref) then tokenize(normalize-space(@ref), '\s+')[1] else ()" />
    <xsl:if test="exists($href)">
        <a href="{$href}"
           class="wikidata"
           target="_blank"
           rel="noopener">
            <img src="https://upload.wikimedia.org/wikipedia/commons/f/ff/Wikidata-logo.svg"
                 alt="Wikidata"
                 height="12" />
        </a>
    </xsl:if>
</xsl:template>

<!-- Person / Place / rs with optional link -->
<xsl:template match="tei:persName">
    <span class="ann person"
          title="Person">
        <xsl:apply-templates />
        <xsl:call-template name="maybe-ref-link" />
    </span>
</xsl:template>
<xsl:template match="tei:placeName">
    <span class="ann place"
          title="Place">
        <xsl:apply-templates />
        <xsl:call-template name="maybe-ref-link" />
    </span>
</xsl:template>
<xsl:template match="tei:geogName">
    <span class="ann place"
          title="Geographic name">
        <xsl:apply-templates />
        <xsl:call-template name="maybe-ref-link" />
    </span>
</xsl:template>
<xsl:template match="tei:rs">
    <span title="Reference">
        <xsl:attribute name="class">
            <xsl:text>ann rs</xsl:text>
            <xsl:if test="@type">
                <xsl:text />
                <xsl:value-of select="@type" />
            </xsl:if>
        </xsl:attribute>
        <xsl:apply-templates />
        <xsl:call-template name="maybe-ref-link" />
    </span>
</xsl:template>

<!-- Head / hi / foreign / date / editorial -->
<xsl:template match="tei:head">
    <b>
        <xsl:apply-templates />
    </b>
</xsl:template>
<xsl:template match="tei:hi">
    <span class="initial">
        <xsl:apply-templates />
    </span>
</xsl:template>
<xsl:template match="tei:foreign">
    <span class="ann foreign">
        <xsl:if test="@xml:lang or @lang">
            <xsl:attribute name="title">
                <xsl:text>Foreign (</xsl:text>
                <xsl:value-of select="(@xml:lang, @lang)[1]" />
                <xsl:text>)</xsl:text>
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates />
    </span>
</xsl:template>
<xsl:template match="tei:date">
    <time class="ann date">
        <xsl:if test="@when">
            <xsl:attribute name="datetime">
                <xsl:value-of select="@when" />
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates />
    </time>
</xsl:template>

<!-- Legacy <sic> -->
<xsl:template match="tei:sic">
    <span class="ann sic">
        <xsl:if test="@correction">
            <xsl:attribute name="title">Correction: <xsl:value-of select="@correction" />
        </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates />
</span>
</xsl:template>
<xsl:template match="tei:del">
    <span class="ann del"
          title="Deleted">
        <xsl:apply-templates />
    </span>
</xsl:template>
<xsl:template match="tei:unclear">
    <span class="ann unclear"
          title="Unclear">
        <xsl:apply-templates />
    </span>
</xsl:template>

<xsl:template match="text()">
    <xsl:value-of select="." />
</xsl:template>
<xsl:template match="*">
    <xsl:apply-templates />
</xsl:template>
</xsl:stylesheet>