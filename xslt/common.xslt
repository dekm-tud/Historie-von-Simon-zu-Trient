<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="tei xs">

    <xsl:template name="page-shell">
        <xsl:param name="title" />
        <xsl:param name="css-href" />
        <xsl:param name="js-href" />
        <xsl:param name="content" as="node()*" />
        <xsl:param name="head-extra" as="node()*" />
        <xsl:param name="body_extra_bottom" as="node()*" />
        <xsl:param name="atRoot" as="xs:boolean" select="false()" />
        <xsl:param name="outdir" select="'html/'" />
        <xsl:param name="iiif_manifest" select="'https://api.digitale-sammlungen.de/iiif/presentation/v2/bsb00027835/manifest'" />
        <xsl:param name="site_title" select="'Historie von Simon zu Trient – Digital Edition'" />

        <html lang="de" data-manifest="{$iiif_manifest}">
            <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1" />
                <title>
                    <xsl:value-of select="$title" />
                </title>
                <link rel="stylesheet" href="{$css-href}" />
                <xsl:copy-of select="$head-extra" />
            </head>
            <body class="mode-expan layout-reading">
                <header class="site-header">
                    <nav class="nav">
                        <div class="brand">
                            <xsl:variable name="teiTitle" select="normalize-space(//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main'])" />
                            <xsl:value-of select="if ($teiTitle != '') then $teiTitle else $site_title" />
                        </div>
                        <div class="menu">
                            <xsl:variable name="prefix" select="if ($atRoot) then '' else '../'" />
                            <xsl:variable name="html-prefix" select="if ($atRoot) then (if (ends-with($outdir, '/')) then $outdir else concat($outdir, '/')) else ''" />
                            <a href="{concat($prefix, 'index.html')}">Home</a>
                            <a href="{concat($html-prefix, 'introduction.html')}">Einleitung</a>
                            <a href="{concat($html-prefix, 'edition.html')}">Edition</a>
                            <a href="{concat($html-prefix, 'literature.html')}">Literatur</a>
                            <a href="https://github.com/dekm-tud/Historie-von-Simon-zu-Trient/">GitHub</a>
                        </div>
                    </nav>
                </header>
                
                <xsl:copy-of select="$content" />
                
                <footer>
                    <h2>Impressum</h2>
                    <h3>Angaben gemäß § 5 TMG</h3>
                    <p>                        
                        Herausgeber:<br/>
                        Dr. Marco Heiles<br/>
                        Universität zu Köln <br/>
                        Institut für Digital Humanities  <br/>
                        Albertus-Magnus-Platz <br/>
                        D-50923 Köln  <br/>
                        mheiles @ uni-koeln.de <br/>
                    </p>
                    <h3>Lizenzbestimmungen</h3>
                    <p>Die Texte dieser Website stehen unter Creative Commons Attribution 4.0 International
                        Lizenz. Sie dürfen die Texte unter Angabe des Urhebers und der CC-Lizenz sowohl kopieren
                        als auch an anderer Stelle veröffentlichen.</p>
                    <h3>Förderung</h3>
                    <p>Die Forschung von <a href="https://hcommons.org/members/marcoheiles/">Dr. Marco Heiles</a> zur Edition der Historie von Simon zu Trient fand im <a href="https://www.germlit.rwth-aachen.de/cms/germlit/Das-Institut/~mpma/Aeltere-deutsche-Literatur/">Institut für Germanistische und Allgemeine Literaturwissenschaft</a> der RWTH Aachen University, am <a href="https://www.csmc.uni-hamburg.de">Centre for the Study of Manuscript Cultures (CSMC)</a> der Universität Hamburg und im  <a href="https://dh.phil-fak.uni-koeln.de">Institut für Digital Humanities</a> der Universität zu Köln statt. Sie wurde durch die Deutsche Forschungsgemeinschaft (DFG) im Rahmen der Exzellenzstrategie
                        des Bundes und der Länder – EXC 2176 „Understanding Written Artefacts: Material, Interaction
                        and Transmission in Manuscript Cultures”, Projektnr. 390893796 gefördert.</p>
                    <p>Die Einrichtung und Veröffentlichung der Digitalen Edition und der Sicherung der Forschungsdaten
                        erfolgte durch <a href="https://orcid.org/0000-0002-2750-1900">Prof. Dr. Michael Schonhardt</a> im Fachgebiet <a href="https://www.linglit.tu-darmstadt.de/institutlinglit/fachgebiete/digitale_editorik_und_kulturgeschichte_des_mittelalters/index.de.jsp">Digitale Editorik und Kulturgeschichte des Mittelalters</a> der Technischen Universität Darmstadt.</p>
                </footer>

                <xsl:copy-of select="$body_extra_bottom" />
                <script src="{$js-href}" />
                
                <!-- Common Scripts (Register Popup) -->
                <script>                    
                    document.addEventListener('DOMContentLoaded', () =&gt; {
                        const registerDataElement = document.getElementById('register-data');
                        const popupElement = document.getElementById('register-popup-element');
                        let registerLookup = {};
                        
                        if (!popupElement) {
                            return;
                        }
                        
                        if (registerDataElement) {
                            try {
                                registerLookup = JSON.parse(registerDataElement.textContent || '{}');
                            } catch (e) {
                                console.error("Failed to parse register data:", e);
                            }
                        }
                        
                        const annotatedSpans = document.querySelectorAll('.register-lookup');
                        
                        const getPopupText = (el) =&gt; {
                            return el.dataset.popupContent || (el.dataset.refid ? registerLookup[el.dataset.refid] : undefined);
                        };
                        
                        const showPopup = (el) =&gt; {
                            const text = getPopupText(el);
                            if (!text) {
                                popupElement.style.display = 'none';
                                return;
                            }
                            popupElement.innerHTML = text;
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
</xsl:stylesheet>
