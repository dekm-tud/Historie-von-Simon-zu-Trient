<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                exclude-result-prefixes="tei xs map">
    <xsl:import href="common.xslt" />
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
    <xsl:function name="tei:slug"
                  as="xs:string">
        <xsl:param name="raw"
                   as="xs:string?" />
        <xsl:variable name="norm"
                      select="normalize-space($raw)" />
        <xsl:variable name="sanitized"
                      select="replace($norm, '[^A-Za-z0-9]+', '-')" />
        <xsl:variable name="trimmed"
                      select="replace(replace($sanitized, '^-+', ''), '-+$', '')" />
        <xsl:sequence select="if ($trimmed != '') then lower-case($trimmed) else 'x'" />
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

    <xsl:variable name="prefixDefs" select="//tei:teiHeader//tei:prefixDef" />

    <xsl:function name="tei:resolve-cRef" as="xs:string?">
        <xsl:param name="cRef" as="xs:string?" />
        <xsl:if test="contains($cRef, ':')">
            <xsl:variable name="prefix" select="substring-before($cRef, ':')" />
            <xsl:variable name="value" select="substring-after($cRef, ':')" />
            <xsl:variable name="def" select="$prefixDefs[@ident = $prefix]" />
            <xsl:if test="$def">
                <xsl:value-of select="replace($def/@replacementPattern, '\$1', $value)" />
            </xsl:if>
        </xsl:if>
    </xsl:function>

    <xsl:function name="tei:pretty-cRef" as="xs:string?">
        <xsl:param name="cRef" as="xs:string?" />
        <xsl:choose>
            <xsl:when test="contains($cRef, ':')">
                <xsl:variable name="prefix" select="substring-before($cRef, ':')" />
                <xsl:variable name="value" select="substring-after($cRef, ':')" />
                <xsl:variable name="book" select="substring-before($value, '.')" />
                <xsl:variable name="chapter-verse" select="replace(substring-after($value, '.'), '\.', ',')" />
                <xsl:variable name="bookName">
                    <xsl:choose>
                        <xsl:when test="$book = 'PHP'">Phil</xsl:when>
                        <xsl:when test="$book = 'JHN'">Joh</xsl:when>
                        <xsl:when test="$book = 'MAT'">Mt</xsl:when>
                        <xsl:when test="$book = 'MAR'">Mk</xsl:when>
                        <xsl:when test="$book = 'LUK'">Lk</xsl:when>
                        <xsl:when test="$book = 'ACT'">Apg</xsl:when>
                        <xsl:when test="$book = 'ROM'">Röm</xsl:when>
                        <xsl:when test="$book = 'GEN'">Gen</xsl:when>
                        <xsl:when test="$book = 'PSA'">Ps</xsl:when>
                        <xsl:otherwise><xsl:value-of select="$book"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="concat($bookName, ' ', $chapter-verse)" />
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$cRef"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

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
                <xsl:with-param name="outdir"
                                select="$outdir" />
                <xsl:with-param name="site_title"
                                select="$site_title" />
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

                        /* Commentary Note Styles */
                        .note-commentary {
                            font-size: 0.8em;
                            vertical-align: super;
                            cursor: pointer;
                            color: #a00;
                            margin-left: 2px;
                            font-weight: bold;
                        }
                        .commentary-content {
                            display: none;
                            background-color: #f9f9f9;
                            border-left: 3px solid #a00;
                            padding: 0.5em 1em;
                            margin: 0.5em 0;
                            font-size: 0.9em;
                        }
                        .commentary-active .commentary-content {
                            display: block;
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
<xsl:template match="tei:div[@type='chapter']">
    <xsl:variable name="cid"
                  select="string((@xml:id, concat('hszt-chapter-', (normalize-space(@n), count(preceding::tei:div[@type='chapter']) + 1)[1]))[1])" />
    <section class="chapter citable"
             id="{$cid}">
        <xsl:call-template name="emit-cite-handle">
            <xsl:with-param name="id"
                            select="$cid" />
            <xsl:with-param name="kind-label"
                            select="'Kapitel'" />
        </xsl:call-template>
        <xsl:apply-templates />
    </section>
</xsl:template>
<xsl:template match="tei:div[@type='illustration']">
    <section class="illustration">
        <xsl:apply-templates />
    </section>
</xsl:template>
<xsl:template match="tei:figure">
    <xsl:variable name="fid"
                  select="string((@xml:id, concat('hszt-figure-', tei:slug((@type, 'figure')[1]), '-', tei:slug((@n, count(preceding::tei:figure) + 1)[1])))[1])" />
    <figure class="edition-figure citable"
            id="{$fid}">
        <xsl:call-template name="emit-cite-handle">
            <xsl:with-param name="id"
                            select="$fid" />
            <xsl:with-param name="kind-label"
                            select="'Abbildung'" />
        </xsl:call-template>
        <xsl:if test="tei:head">
            <b>
                <xsl:apply-templates select="tei:head/node()" />
            </b>
        </xsl:if>
        <xsl:if test="tei:figDesc">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="tei:figDesc/node()" />
        </xsl:if>
    </figure>
</xsl:template>
<xsl:template name="emit-cite-handle">
    <xsl:param name="id"
               as="xs:string?" />
    <xsl:param name="kind-label"
               as="xs:string"
               select="'Abschnitt'" />
    <xsl:if test="normalize-space($id) != ''">
        <a class="cite-handle"
           href="#{$id}"
           title="{concat($kind-label, ' verlinken: #', $id)}"
           aria-label="{concat($kind-label, ' verlinken: #', $id)}">
            <span class="cite-symbol"
                  aria-hidden="true">id</span>
            <span class="cite-id">
                <code>
                    <xsl:value-of select="$id" />
                </code>
            </span>
        </a>
    </xsl:if>
</xsl:template>
<xsl:template match="tei:div[@type='chapter']/tei:p">
    <xsl:variable name="chapter-id"
                  select="string((ancestor::tei:div[@type='chapter'][1]/@xml:id, concat('hszt-chapter-', (normalize-space(ancestor::tei:div[@type='chapter'][1]/@n), count(ancestor::tei:div[@type='chapter'][1]/preceding::tei:div[@type='chapter']) + 1)[1]))[1])" />
    <xsl:variable name="pid"
                  select="string((@xml:id, concat($chapter-id, '-paragraph-', tei:slug((@n, concat('p', count(preceding-sibling::tei:p) + 1))[1])))[1])" />
    <p class="edition-paragraph citable"
       id="{$pid}">
        <xsl:call-template name="emit-cite-handle">
            <xsl:with-param name="id"
                            select="$pid" />
            <xsl:with-param name="kind-label"
                            select="'Absatz'" />
        </xsl:call-template>
        <xsl:apply-templates />
    </p>
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
    <xsl:variable name="refid" select="replace(@ref, '^#', '')" />
    <xsl:variable name="normName" select="map:get($register-map, $refid)" />
    <span class="ann person register-lookup">
        <xsl:attribute name="title" select="if ($normName) then $normName else 'Person'" />
        <xsl:attribute name="data-refid" select="$refid" />
        <xsl:apply-templates />
        <xsl:call-template name="maybe-ref-link" />
    </span>
</xsl:template>
<xsl:template match="tei:placeName | tei:geogName | tei:rs[@type='place']">
    <xsl:variable name="refid" select="replace(@ref, '^#', '')" />
    <xsl:variable name="normName" select="map:get($register-map, $refid)" />
    <span class="ann place register-lookup">
        <xsl:attribute name="title" select="if ($normName) then $normName else (if (self::tei:geogName) then 'Geographic name' else 'Place')" />
        <xsl:attribute name="data-refid" select="$refid" />
        <xsl:apply-templates />
        <xsl:call-template name="maybe-ref-link" />
    </span>
</xsl:template>
<xsl:template match="tei:rs[@type='work']">
    <xsl:variable name="refid" select="replace(@ref, '^#', '')" />
    <xsl:variable name="normName" select="map:get($register-map, $refid)" />
    <span class="ann work register-lookup">
        <xsl:attribute name="title" select="if ($normName) then $normName else 'Work'" />
        <xsl:attribute name="data-refid" select="$refid" />
        <xsl:apply-templates />
        <xsl:call-template name="maybe-ref-link" />
    </span>
</xsl:template>

<xsl:template match="tei:quote">
    <xsl:variable name="sourceLink" select="tei:resolve-cRef(@source)" />
    <span class="quote">
        <xsl:variable name="pretty-source" select="tei:pretty-cRef(@source)" />
        <xsl:attribute name="title" select="if ($pretty-source) then concat('Quelle: ', $pretty-source) else 'Zitat'" />
        <xsl:apply-templates />
        <xsl:if test="$sourceLink">
            <a href="{$sourceLink}" class="source-link" target="_blank" title="{if ($pretty-source) then concat('Quelle aufrufen: ', $pretty-source) else concat('Quelle aufrufen: ', @source)}">
                <xsl:text> [↗]</xsl:text>
            </a>
        </xsl:if>
    </span>
</xsl:template>

<xsl:template match="tei:ref[@cRef]">
    <xsl:variable name="link" select="tei:resolve-cRef(@cRef)" />
    <a href="{$link}" class="cRef-link" target="_blank">
        <xsl:if test="not(node())">
            <xsl:value-of select="tei:pretty-cRef(@cRef)" />
        </xsl:if>
        <xsl:apply-templates />
    </a>
</xsl:template>

<xsl:template match="tei:note[@type='commentary'] | tei:note[@type='comment']">
    <span class="note-commentary register-lookup" title="Kommentar anzeigen">
        <xsl:variable name="comment-content">
            <xsl:apply-templates />
        </xsl:variable>
        <xsl:attribute name="data-popup-content">
            <!-- Serialize the templates result to a string so it can be passed to innerHTML.
                 Method xml/xhtml is safer here to preserve tags inside the attribute. -->
            <xsl:value-of select="serialize($comment-content, map{'method':'xhtml', 'omit-xml-declaration':true()})" />
        </xsl:attribute>
        <xsl:text> ⓘ</xsl:text>
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
    <xsl:variable name="quote" select="ancestor::tei:quote[1]" />
    <xsl:variable name="sourceLink" select="if ($quote) then tei:resolve-cRef($quote/@source) else ()" />
    <span class="ann foreign">
        <xsl:if test="@xml:lang or @lang">
            <xsl:attribute name="title">Foreign (<xsl:value-of select="(@xml:lang, @lang)[1]" />)</xsl:attribute>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$sourceLink">
                <xsl:variable name="pretty-source" select="tei:pretty-cRef($quote/@source)" />
                <a href="{$sourceLink}" class="foreign-link" target="_blank" title="{if ($pretty-source) then concat('Quelle aufrufen: ', $pretty-source) else concat('Quelle aufrufen: ', $quote/@source)}">
                    <xsl:apply-templates />
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates />
            </xsl:otherwise>
        </xsl:choose>
    </span>
</xsl:template>
<xsl:template match="tei:date">
    <xsl:variable name="when"
                  select="string(@when)" />
    <time class="ann date { if ($when != '') then 'register-lookup' else '' }">
        <xsl:attribute name="title" select="if ($when != '') then $when else 'Datum'" />
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
<xsl:template match="tei:ptr">
    <a href="{@target}" target="_blank">
        <xsl:value-of select="@target" />
    </a>
</xsl:template>
<xsl:template match="text()">
    <xsl:value-of select="." />
</xsl:template>
<xsl:template match="*">
    <xsl:apply-templates />
</xsl:template>
</xsl:stylesheet>
