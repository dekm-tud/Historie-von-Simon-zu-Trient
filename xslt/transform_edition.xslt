<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                exclude-result-prefixes="tei xs map">
    <xsl:param name="site_title"
               select="'Historie von Simon zu Trient – Digital Edition'" />
    <xsl:param name="iiif_manifest"
               select="'https://api.digitale-sammlungen.de/iiif/presentation/v2/bsb00027835/manifest'" />
    <xsl:param name="outdir"
               select="'html'" />
    <xsl:output method="html"
                encoding="UTF-8"
                omit-xml-declaration="yes"
                indent="yes" />
    <xsl:key name="char-by-id"
             match="tei:char"
             use="@xml:id" />
    <xsl:key name="glyph-by-id"
             match="tei:glyph"
             use="@xml:id" />
    <xsl:function name="tei:get-canonical-name"
                  as="xs:string">
        <xsl:param name="entry"
                   as="element()" />
        <xsl:choose>
            <xsl:when test="$entry/tei:persName/tei:forename and $entry/tei:persName/tei:surname">
                <xsl:value-of select="string-join($entry/tei:persName/(tei:forename, tei:surname)/normalize-space(.), ' ')" />
            </xsl:when>
            <xsl:when test="$entry/(tei:placeName | tei:persName | tei:title)[1]">
                <xsl:value-of select="normalize-space($entry/(tei:placeName | tei:persName | tei:title)[1])" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space($entry)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:variable name="register-map"
                  as="map(xs:string, xs:string)">
        <xsl:map>
            <xsl:for-each select="//tei:teiHeader/tei:profileDesc/(tei:particDesc/tei:listPerson/tei:person | tei:settingDesc/tei:listPlace/tei:place | tei:listBibl[@type='list_work']/tei:bibl)">
                <xsl:map-entry key="string(@xml:id)"
                               select="tei:get-canonical-name(.)" />
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    <xsl:variable name="register-json"
                  as="xs:string"
                  select="serialize($register-map, map{'method':'json'})" />
    <xsl:template match="/tei:TEI">
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
                        
                        /* Basic Popup Styles */
                        .register-popup {
                        position: absolute;
                        background-color: white;
                        border: 1px solid #ccc;
                        padding: 5px 10px;
                        border-radius: 4px;
                        box-shadow: 2px 2px 5px rgba(0,0,0,0.2);
                        z-index: 1000;
                        display: none; /* Initially hidden */
                        max-width: 300px;
                        font-size: 0.9em;
                        }
                        .register-lookup {
                        cursor: help; /* Indicate clickable */
                        }
                    </style>
                </xsl:with-param>
                <xsl:with-param name="body_extra_bottom">
                    <script type="application/json"
                            id="register-data">
                        <xsl:value-of select="$register-json"
                                      disable-output-escaping="yes" />
                    </script>
                    <div id="register-popup-element"
                         class="register-popup"
                         aria-live="polite" />
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
        <xsl:result-document href="index.html"
                             method="html"
                             encoding="UTF-8"
                             omit-xml-declaration="yes">
            <xsl:call-template name="page-shell">
                <xsl:with-param name="title"
                                select="$site_title" />
                <xsl:with-param name="css-href"
                                select="concat($outdir, '/assets/site.css')" />
                <xsl:with-param name="js-href"
                                select="concat($outdir, '/assets/site.js')" />
                <xsl:with-param name="atRoot"
                                select="true()" />
                <xsl:with-param name="body_extra_bottom">
                    <div id="register-popup-element"
                         class="register-popup"
                         aria-live="polite" />
                </xsl:with-param>
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
                                         loading="lazy" />
                                    <figcaption>
                                        <em>Historie von Simon zu Trient, Trient 06.09.1475: Albrecht Kunne. Exemplar: Wolfenbüttel, Herzog August Bibliothek, 5 Xylogr. (2)</em>
                                    </figcaption>
                                </figure>
                            </section>
                        </section>
                    </main>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>
    <xsl:template name="page-shell">
        <xsl:param name="title" />
        <xsl:param name="css-href" />
        <xsl:param name="js-href" />
        <xsl:param name="content"
                   as="node()*" />
        <xsl:param name="head-extra"
                   as="node()*" />
        <xsl:param name="body_extra_bottom"
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
                            <xsl:value-of select="normalize-space(//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main'])" />
                        </div>
                        <div class="menu">
                            <xsl:variable name="prefix"
                                          select="if ($atRoot) then '' else '../'" />
                            <a href="{concat($prefix, 'index.html')}">Home</a>
                            <a href="{concat($prefix, $outdir, '/introduction.html')}">Einleitung</a>
                            <a href="{concat($prefix, $outdir, '/edition.html')}">Edition</a>
                            <a href="{concat($prefix, $outdir, '/literature.html')}">Literatur</a>
                            <a href="https://github.com/michaelscho/Historie-von-Simon-zu-Trient">GitHub</a>
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
                <xsl:copy-of select="$body_extra_bottom" />
                <script src="{$js-href}" />
                <script>                    
                    document.addEventListener('DOMContentLoaded', () =&gt; {
                    const registerDataElement = document.getElementById('register-data');
                    const popupElement = document.getElementById('register-popup-element');
                    let registerLookup = {};
                    
                    if (!popupElement) {
                    console.warn("Popup element not found.");
                    return;
                    }
                    
                    if (registerDataElement) {
                    try {
                    registerLookup = JSON.parse(registerDataElement.textContent || '{}');
                    } catch (e) {
                    console.error("Failed to parse register data:", e);
                    }
                    } else {
                    console.warn("Register data element not found (this is expected on some pages).");
                    }
                    
                    const annotatedSpans = document.querySelectorAll('.register-lookup');
                    
                    const getPopupText = (el) =&gt; {
                    return el.dataset.popupContent || (el.dataset.refid ? registerLookup[el.dataset.refid] : undefined);
                    };
                    
                    const showPopup = (el) =&gt; {
                    const text = getPopupText(el);
                    if (!text) {
                    popupElement.style.display = 'none';
                    const idInfo = el.dataset.refid ? ` (refid: ${el.dataset.refid})` : '';
                    console.warn(`No popup content found${idInfo}.`);
                    return;
                    }
                    popupElement.textContent = text;
                    const rect = el.getBoundingClientRect();
                    popupElement.style.left = `${window.scrollX + rect.left}px`;
                    popupElement.style.top  = `${window.scrollY + rect.bottom + 5}px`;
                    popupElement.style.display = 'block';
                    };
                    
                    annotatedSpans.forEach((span) =&gt; {
                    if (!span.hasAttribute('tabindex')) span.setAttribute('tabindex', '0');
                    
                    span.addEventListener('click', (event) =&gt; {
                    event.stopPropagation();
                    showPopup(span);
                    });
                    
                    span.addEventListener('keydown', (event) =&gt; {
                    if (event.key === 'Enter' || event.key === ' ') {
                    event.preventDefault();
                    event.stopPropagation();
                    showPopup(span);
                    }
                    });
                    });
                    
                    document.addEventListener('click', () =&gt; {
                    if (popupElement.style.display === 'block') popupElement.style.display = 'none';
                    });
                    
                    document.addEventListener('keydown', (event) =&gt; {
                    if (event.key === 'Escape' &amp;&amp; popupElement.style.display === 'block') {
                    popupElement.style.display = 'none';
                    }
                    });
                    });
                </script>
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
            <xsl:if test="@break!='no'">
                <xsl:text />
            </xsl:if>
        </span>
    </span>
</xsl:template>
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
            <xsl:attribute name="data-norm"
                           select="$norm" />
        </xsl:if>
        <xsl:apply-templates />
    </span>
</xsl:template>
<xsl:template name="maybe-ref-link">
    <xsl:variable name="href"
                  as="xs:string?"
                  select="@target" />
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
<xsl:template match="tei:persName | tei:rs[@type='person']">
    <span class="ann person register-lookup"
          title="Person">
        <xsl:attribute name="data-refid"
                       select="replace(@ref, '^#', '')" />
        <xsl:apply-templates />
        <xsl:call-template name="maybe-ref-link" />
    </span>
</xsl:template>
<xsl:template match="tei:placeName | tei:geogName | tei:rs[@type='place']">
    <span class="ann place register-lookup"
          title="{if (self::tei:geogName) then 'Geographic name' else 'Place'}">
        <xsl:attribute name="data-refid"
                       select="replace(@ref, '^#', '')" />
        <xsl:apply-templates />
        <xsl:call-template name="maybe-ref-link" />
    </span>
</xsl:template>
<xsl:template match="tei:rs[@type='work']">
    <span class="ann work register-lookup"
          title="Work">
        <xsl:attribute name="data-refid"
                       select="replace(@ref, '^#', '')" />
        <xsl:apply-templates />
        <xsl:call-template name="maybe-ref-link" />
    </span>
</xsl:template>
<xsl:template match="tei:rs[not(@type=('person','place','work'))]">
    <span title="Reference">
        <xsl:attribute name="class">ann rs <xsl:value-of select="@type" />
    </xsl:attribute>
    <xsl:apply-templates />
    <xsl:call-template name="maybe-ref-link" />
</span>
</xsl:template>
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
            <xsl:attribute name="title">Foreign (<xsl:value-of select="(@xml:lang, @lang)[1]" />)</xsl:attribute>
        </xsl:if>
        <xsl:apply-templates />
    </span>
</xsl:template>
<xsl:template match="tei:date">
    <xsl:variable name="when"
                  select="string(@when)" />
    <time class="ann date { if ($when != '') then 'register-lookup' else '' }"
          title="Date">
        <xsl:if test="$when != ''">
            <xsl:attribute name="datetime"
                           select="$when" />
            <xsl:attribute name="data-popup-content"
                           select="$when" />
        </xsl:if>
        <xsl:apply-templates />
    </time>
</xsl:template>
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